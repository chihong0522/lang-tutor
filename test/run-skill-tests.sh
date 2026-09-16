#!/usr/bin/env bash
# Automated smoke tests for the lang-tutor skill.
#
# Each test runs a fresh headless Claude Code session that loads THIS repo as
# a plugin (--plugin-dir) and invokes the namespaced skill /lang-tutor:lang-tutor,
# so the tests always exercise the repo's current skill content — even if you
# also have lang-tutor installed at user level (~/.claude/skills).
#
# Isolation:
#   - each test runs in a temp project dir, and auto-memory is per-project,
#     so tests get a blank MEMORY.md — your real preferences are never touched
#   - uses your normal login; transcripts for the temp projects accumulate
#     under ~/.claude/projects/ (tiny, safe to delete)
#
# Usage:
#   ./test/run-skill-tests.sh                # run all tests
#   ./test/run-skill-tests.sh routing memory # run specific tests
#
# Env:
#   LANG_TUTOR_TEST_MODEL  model for test runs (default: haiku, cheapest)
#
# Available tests: routing, alias, unsupported, modes, memory

set -uo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SKILL_DIR="$REPO_DIR/skills/lang-tutor"
SKILL="/lang-tutor:lang-tutor"
MODEL="${LANG_TUTOR_TEST_MODEL:-haiku}"
PASS=0
FAIL=0
TOTAL_COST=0

command -v claude >/dev/null 2>&1 || { echo "error: claude CLI not found on PATH" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "error: jq is required (brew install jq)" >&2; exit 1; }

# --- harness -----------------------------------------------------------------

new_env() {
  TMP="$(mktemp -d /tmp/lang-tutor-test.XXXXXX)"
  PROJECT="$TMP/project"
  mkdir -p "$PROJECT"
  cd "$PROJECT" || exit 1
}

# run_claude <prompt> [session-id-to-resume]
# Streams events to $OUT; sets SESSION_ID and RESULT_TEXT.
run_claude() {
  OUT="$TMP/run-$RANDOM.jsonl"
  claude -p "$1" \
    --model "$MODEL" \
    --plugin-dir "$REPO_DIR" \
    --add-dir "$SKILL_DIR" \
    --output-format stream-json --verbose \
    --allowedTools "Read,Write,Edit" \
    --permission-mode acceptEdits \
    ${2:+--resume "$2"} >"$OUT" 2>"$OUT.err"
  if [ $? -ne 0 ]; then
    echo "  ! claude run failed; stderr tail:"
    tail -5 "$OUT.err" | sed 's/^/    /'
    return 1
  fi
  SESSION_ID="$(jq -r 'select(.session_id != null) | .session_id' "$OUT" | head -1)"
  RESULT_TEXT="$(jq -r 'select(.type == "result") | .result // empty' "$OUT")"
  COST="$(jq -r 'select(.type == "result") | .total_cost_usd // 0' "$OUT")"
  TOTAL_COST="$(echo "$TOTAL_COST + ${COST:-0}" | bc)"
}

# assert_read <path-fragment> — the session must contain a SUCCESSFUL Read of a
# file whose path contains the fragment. (Plain grep on the stream would
# false-positive: SKILL.md's own text lists the guide filenames; and a Read
# attempt that errored doesn't count.)
assert_read() {
  local ids id
  ids="$(jq -r --arg frag "$1" '
    select(.type == "assistant")
    | .message.content[]?
    | select(.type == "tool_use" and .name == "Read")
    | select(.input.file_path // "" | contains($frag))
    | .id' "$OUT" 2>/dev/null)"
  for id in $ids; do
    if jq -e --arg id "$id" '
      select(.type == "user")
      | .message.content[]?
      | select(.type == "tool_result" and .tool_use_id == $id and (.is_error != true))' \
      "$OUT" >/dev/null 2>&1; then
      echo "  ok: read $1"
      return 0
    fi
  done
  echo "  FAIL: expected a successful Read of $1"
  echo "  reads seen:"
  jq -r 'select(.type == "assistant") | .message.content[]? | select(.type == "tool_use" and .name == "Read") | .input.file_path' "$OUT" 2>/dev/null | sed 's/^/    /'
  return 1
}

# assert_response_contains <string> — checks ALL assistant text in the turn,
# not just the final message (the feedback block often precedes tool use).
assert_response_contains() {
  if jq -r 'select(.type == "assistant") | .message.content[]? | select(.type == "text") | .text' "$OUT" 2>/dev/null | grep -qi "$1"; then
    echo "  ok: response contains \"$1\""
  else
    echo "  FAIL: response missing \"$1\""
    printf '%s' "$RESULT_TEXT" | head -10 | sed 's/^/    /'
    return 1
  fi
}

run_test() {
  local name="$1"
  echo "=== $name ==="
  if "test_$name"; then
    PASS=$((PASS + 1))
    rm -rf "$TMP"
  else
    FAIL=$((FAIL + 1))
    echo "  (artifacts kept at $TMP)"
  fi
  cd "$REPO_DIR" || exit 1
}

# --- tests -------------------------------------------------------------------

# Explicit args route to the right language guide, and the shared spine loads
# alongside it. Both files are required: _common.md carries the feedback block
# formats, the deep-dive rotation, and the Irregularity Watch, so a skill that
# loaded only the language guide would look correct here but tutor incorrectly.
test_routing() {
  new_env
  run_claude "$SKILL English Beginner" || return 1
  assert_read "languages/_common.md" || return 1
  assert_read "languages/english.md" || return 1
}

# Language-name aliases normalize ("日本語" -> japanese.md).
test_alias() {
  new_env
  run_claude "$SKILL 日本語 Beginner" || return 1
  assert_read "languages/_common.md" || return 1
  assert_read "languages/japanese.md" || return 1
}

# Unsupported targets must not activate tutoring or alter saved preferences.
test_unsupported() {
  new_env
  mkdir -p "$(dirname "$PREFS_FILE")"
  printf 'Target language: English\nNative language: Traditional Chinese (zh-TW)\nProficiency level: beginner\n' > "$PREFS_FILE"
  cp "$PREFS_FILE" "$TMP/prefs-before.md"
  run_claude "$SKILL Swahili Beginner" || return 1
  assert_response_contains "English\|英文\|英語" || return 1
  assert_response_contains "Japanese\|日文\|日本語" || return 1
  cmp -s "$PREFS_FILE" "$TMP/prefs-before.md" || { echo "FAIL: unsupported target changed preferences"; return 1; }
}

# Both feedback modes fire on follow-up turns in the same session.
test_modes() {
  new_env
  run_claude "$SKILL English Beginner" || return 1
  run_claude "I wants to learn English" "$SESSION_ID" || return 1
  assert_response_contains "語言回饋" || return 1
  run_claude "請解釋這個指令的用途" "$SESSION_ID" || return 1
  assert_response_contains "關鍵字彙" || return 1
}

# Preferences persist to the dedicated prefs file and a bare invocation reloads them.
test_memory() {
  new_env
  run_claude "$SKILL English Beginner" || return 1
  if [ ! -f "$PREFS_FILE" ] || ! grep -qi "english" "$PREFS_FILE"; then
    echo "  FAIL: preferences not saved to $PREFS_FILE"
    return 1
  fi
  if grep -rqi "Language Tutor Preferences" "$(jq -r 'select(.type == "system" and .subtype == "init") | .memory_paths.auto // empty' "$OUT" | head -1)" 2>/dev/null; then
    echo "  FAIL: preferences leaked into the project's auto-memory"
    return 1
  fi
  echo "  ok: preferences saved to $PREFS_FILE, auto-memory untouched"
  # New session (no resume), bare invocation: must load saved prefs and
  # read both the spine and the English guide again.
  run_claude "$SKILL" || return 1
  assert_read "languages/_common.md" || return 1
  assert_read "languages/english.md" || return 1
}

# --- main --------------------------------------------------------------------

ALL_TESTS="routing alias unsupported modes memory"
TESTS="${*:-$ALL_TESTS}"

# The skill writes preferences to a fixed path under $HOME, so a test run would
# otherwise overwrite the real user's settings. Snapshot and restore them.
PREFS_FILE="$HOME/.lang-tutor/prefs.md"
PREFS_BACKUP="$(mktemp /tmp/lang-tutor-prefs-backup.XXXXXX)"
if [ -f "$PREFS_FILE" ]; then
  cp "$PREFS_FILE" "$PREFS_BACKUP"
  restore_prefs() { cp "$PREFS_BACKUP" "$PREFS_FILE"; rm -f "$PREFS_BACKUP"; }
else
  restore_prefs() { rm -f "$PREFS_FILE" "$PREFS_BACKUP"; }
fi
trap restore_prefs EXIT

echo "model: $MODEL"
for t in $TESTS; do
  if ! declare -f "test_$t" >/dev/null; then
    echo "unknown test: $t (available: $ALL_TESTS)" >&2
    exit 1
  fi
  run_test "$t"
done

echo
echo "passed: $PASS  failed: $FAIL  (approx cost: \$$TOTAL_COST)"
[ "$FAIL" -eq 0 ]
