---
name: lang-tutor-review-test
description: Drill what lang-tutor has taught you — picks one weakness from your feedback log and quizzes you on it, one question at a time, in workplace situations.
user-invocable: true
argument-hint: "[category] [easy|hard] [all]"
---

# Language Tutor Review Test

The practice half of the review. `lang-tutor-review` reads the log and explains; this skill takes one thing from it and makes the user produce the correct form themselves.

## Step 1: Read the Log and the Arguments

Files are monthly: `~/.lang-tutor/log-<YYYY-MM>.md`. Read the current month and the previous month by default; read every `log-*.md` when `all` is given.

Also read `~/.lang-tutor/prefs.md` for the target language, native language, and level, plus `languages/_common.md` and the target language's guide.

Arguments, in any order:

- **A category** — a topic in the user's words (`助動詞`, `冠詞`, `時態`, `phrasal verb`). Drill that and nothing else. Match it loosely against what the log actually contains; if nothing in the log fits, say so and offer the categories that do exist rather than inventing material.
- **`easy` / `hard`** — see Difficulty below. Default is `easy`.
- **`all`** — widen the log to every month.

**If the log has fewer than 3 entries**, say so and stop. There is not enough of the user's own material to build questions from, and inventing some defeats the purpose.

## Step 2: Pick the Target

With no category argument, choose one yourself: the weakness whose repair unlocks the most. Prefer mistakes that stall a reader over ones that merely sound stiff, and prefer a root cause that several log entries share over a one-off slip.

State it in one sentence in Chinese before the first question, plus one line on the rule being drilled. Three lines total — this skill is the practice, not the lecture. The full explanation is `lang-tutor-review`'s job.

## Step 3: Difficulty

**`easy` (default)** — one thing wrong per question, and the question says which kind of thing it is.

- Give the user's own sentence back with a single error in it, and name the category: "這句的助動詞有問題，改一下"
- Or give a fill-in-the-blank where only the target form is missing: "___ these scripts been verified to work?"
- Multiple choice is fine here — three options, one right
- Never more than one error to find per question

**`hard`** — the full sentence as the user originally wrote it, all errors present, no hint about how many or what kind. This is what the first version of this skill did, and it is genuinely hard; only use it when asked for.

If the user struggles twice in a row at `hard`, drop to `easy` for the rest of the session and say so in one line.

## Step 4: Ask

Ask **3-5 questions, one at a time**, and wait for each answer before moving on. Never show the next question alongside feedback for the previous one.

Questions are written in the target language; everything you say about them is in the user's native language.

Match the question to the entry kind:

| Kind | Question |
|---|---|
| `error` | **改錯** — their sentence back, with the error to fix |
| `upgrade` | **換句話說** — the stiff-but-correct version, ask for the natural one |
| `vocab` | **造句** — a situation, ask for a sentence using the word |

Set every question in a workplace situation, rotating among: daily stand-up, code review and design discussion, MR or ticket descriptions, casual team chat. Reuse the user's own domain when the log shows it.

**Hints.** If the user asks for a hint, give one that narrows the search without supplying the answer — name the part of the sentence, or ask a question that leads to the rule. Never reveal the corrected form as a hint; if they ask twice, give the answer with the rule and move on rather than dragging it out.

## Step 5: Mark Each Answer

- Say whether it is right, first, in one word
- Correct what is wrong, with the rule behind it — one or two lines
- If it is correct but stilted, give the phrasing a native speaker would use
- Name one thing they did well, specifically

When the user gets right the very thing they have repeatedly got wrong in the log, say so plainly. That is the moment this skill exists for.

## Step 6: Close

- One line naming the rule, phrased so they can catch themselves mid-sentence
- What to watch for in their next few messages
- Whether this category now looks solid enough to drop

## Tone

Concise and direct. No encouragement padding, no praise that was not earned. The user is an engineer practising between real tasks — respect the interruption.

## Never

- Never ask more than one question at a time
- Never invent quiz material that is not grounded in the log
- Never write to the log files — this skill is read-only
- Never quote code, file paths, or work content from the user's projects
