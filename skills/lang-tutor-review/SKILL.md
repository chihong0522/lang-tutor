---
name: lang-tutor-review
description: Go over what lang-tutor has taught you — reads your feedback log, groups the mistakes into categories, and writes a study digest you can read straight through. No quiz.
---

# Language Tutor Review

The user wants to go back over the corrections and suggestions lang-tutor has given them. The material lives in `~/.lang-tutor/`, written one entry at a time by the feedback blocks (see `Persisting What You Teach` in `lang-tutor/languages/_common.md`).

**This skill does not quiz.** It reads, sorts, and explains — the output is a digest the user reads straight through with no questions to answer and nothing to reply to. Practice lives in the separate `lang-tutor-review-test` skill; this one ends by pointing at it.

This edition is for Traditional Chinese (zh-TW) speakers. Ignore any legacy native-language setting; explanations and quiz hints always use Traditional Chinese. Only English and Japanese are supported learning targets. Validate saved preferences using the target aliases in `../lang-tutor/SKILL.md` before loading `../lang-tutor/languages/_common.md` and the English or Japanese guide. If the saved target is unsupported, explain the restriction and direct the user to activate `$lang-tutor English` or `$lang-tutor Japanese` in Codex, or `/lang-tutor English` or `/lang-tutor Japanese` in Claude Code; stop without changing preferences or logs. Filter legacy logs to entries in the selected target language; ignore unrelated or ambiguous entries. Apply the empty-log or minimum-entry rule after filtering.

## Step 1: Read the Log

Files are monthly: `~/.lang-tutor/log-<YYYY-MM>.md`.

- **No argument** — read the current month and the previous month.
- **`all`** — read every `log-*.md` file present.

Each entry is three lines: date, kind (`error` / `upgrade` / `vocab`), the before/after pair, and a teaching point written in Traditional Chinese.

Also read `~/.lang-tutor/prefs.md` for the target language, native language, and level, and load `../lang-tutor/languages/_common.md` plus the target language's guide — the same two guides the tutor itself uses. The digest is written at the level recorded there.

**If the log is empty**, say so, tell the user to keep writing in their target language so the tutor can collect some, and stop. With even a couple of entries a digest is still worth writing — there is no minimum, because nothing here depends on having enough material to quiz from.

## Step 2: Group the Entries

Sort the entries into categories **you derive from the material**, not from a fixed list. A category is a cause, not a label: "疑問句的助動詞" is a category; "grammar" is not.

Rules for good categories:

- **Group by root cause, not by surface symptom.** A missing `do` in a direct question and an over-inverted embedded question belong together — one rule, two ways of getting it wrong. Say that explicitly when it happens; it is the most useful thing this skill produces.
- **Three to six categories** for a typical log. If you have more, you are labelling symptoms; merge them. If you have one, you are being too coarse; split it.
- **Name each category in Traditional Chinese**, in the words the user would use to catch themselves mid-sentence.
- **Order by cost, not by count.** A mistake that stalls the reader outranks one that merely sounds stiff, even if the stiff one appears more often.
- `upgrade` and `vocab` entries get their own categories at the end — they are things to start using, not holes to plug.

## Step 3: Write the Digest

For each category, in order:

1. **The category name** and how many entries fall under it
2. **What the rule actually is** — one or two lines, phrased as something checkable while typing, not as grammar theory
3. **Why it happens to this learner** — name the native-language interference where there is one
4. **The user's own examples**, wrong form and right form side by side, taken verbatim from the log. Never invent examples; the point is that they recognise their own sentences

Then close the digest with:

- **已經在改善的** — anything that appears early in the log and stops appearing later. Say it plainly; this is the only evidence of progress the user has.
- **還沒自己用過的** — `upgrade` phrasings and `vocab` items that the tutor has offered but the user has never produced themselves. List them as a watch-list, not as a failure.
- **下一步** — name the single category most worth working on, in one sentence, and tell the user they can drill it with `/lang-tutor-review-test`, optionally naming that category as the argument.

## Format

Write in Traditional Chinese (zh-TW). Use headings and tables where they compress; the user reads terminal output and prefers scanning to prose.

Put each category's examples in a table so the wrong and right forms line up:

| ❌ 你寫的 | ✅ 正確 |
|---|---|
| ... | ... |

Keep the whole digest scannable in one screen per category. No encouragement padding, no restating the same rule in three ways.

## Tone

Concise and direct. The user is an engineer who wants their language to stop getting in the way — not a student who needs reassurance.

## Never

- Never ask the user a question or wait for an answer — this skill produces a document, not a conversation
- Never invent entries, examples, or categories that are not grounded in the log
- Never write to the log files — this skill is read-only
- Never quote code, file paths, or work content from the user's projects; the log holds language material only
