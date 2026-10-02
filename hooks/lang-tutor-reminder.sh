#!/usr/bin/env bash
# UserPromptSubmit and SessionEnd hook for lang-tutor.
#
# Codex tracks activation in PLUGIN_DATA by session_id instead of parsing its
# unstable transcript format. Claude Code keeps using the transcript marker.
# Reminders are silent until the user explicitly activates $lang-tutor.
set -uo pipefail

input="$(cat)"

# Extract fields from the hook's stdin JSON (jq if available, sed fallback
# so the hook works on machines without jq).
json_field() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$input" | jq -r --arg k "$1" '.[$k] // empty'
  else
    printf '%s' "$input" | sed -n "s/.*\"$1\":[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -1
  fi
}

event="$(json_field hook_event_name)"
session_id="$(json_field session_id)"
prompt="$(json_field prompt)"

# SessionEnd only manages Codex's plugin-local activation marker.
if [ "$event" = "SessionEnd" ] && [ -z "${PLUGIN_DATA:-}" ]; then
  exit 0
fi

# Codex provides PLUGIN_DATA and a session_id. Keep activation state scoped to
# that conversation; do not rely on Codex's non-stable transcript format.
if [ -n "${PLUGIN_DATA:-}" ] && [ -n "$session_id" ]; then
  # Keep the session id inside the plugin's state directory when used as a path.
  safe_session_id="${session_id//[^a-zA-Z0-9_-]/_}"
  state_dir="${PLUGIN_DATA}/lang-tutor/sessions"
  state_file="$state_dir/$safe_session_id.active"

  if [ "$event" = "SessionEnd" ]; then
    rm -f "$state_file"
    exit 0
  fi

  case "$prompt" in
    '$lang-tutor'|'$lang-tutor '*|'$lang-tutor:lang-tutor'|'$lang-tutor:lang-tutor '*|'[$lang-tutor:lang-tutor]'*)
      if mkdir -p "$state_dir" 2>/dev/null; then
        : > "$state_file"
      fi
      ;;
  esac

  [ -f "$state_file" ] || exit 0
else
  # Claude Code exposes the transcript marker after loading the skill.
  transcript="$(json_field transcript_path)"
  [ -n "$transcript" ] && [ -f "$transcript" ] || exit 0
  grep -q 'Language Tutor Mode' "$transcript" 2>/dev/null || exit 0
fi

# Preferences are shared by both supported hosts; do not use Claude auto-memory.
prefs=""
if [ -f "$HOME/.lang-tutor/prefs.md" ]; then
  prefs="$(tr '\n' ' ' < "$HOME/.lang-tutor/prefs.md")"
fi

printf 'Reminder: lang-tutor mode is active in this session. Before handling this message, apply the lang-tutor skill: detect the message language, use the loaded guides (languages/_common.md plus the target language guide), give concise feedback in Traditional Chinese, then handle the request normally. If the guide contents are no longer available in context, read them from the installed skill. %s\n' "${prefs:+Saved preferences: $prefs}"
exit 0
