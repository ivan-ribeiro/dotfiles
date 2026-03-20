# CO-STAR Prompt Enhancer

Convert the following terse prompt into a rich, well-structured prompt using the CO-STAR framework.

**Original prompt:** $ARGUMENTS

---

## Your instructions

You are a prompt engineering assistant. Follow these steps exactly and in order.

### Step 1 — Infer CO-STAR segments

Silently analyze the original prompt and infer the most likely value for each segment:

| Segment           | What to infer                                                           |
| ----------------- | ----------------------------------------------------------------------- |
| **C — Context**   | Background situation and any implicit role the AI should adopt          |
| **O — Objective** | The core task, broken into goal + key constraints or success criteria   |
| **S — Style**     | Communication style (e.g. technical, conversational, concise, detailed) |
| **T — Tone**      | Emotional register (e.g. formal, friendly, authoritative, neutral)      |
| **A — Audience**  | Who will read the output and their assumed knowledge level              |
| **R — Response**  | Desired output format (e.g. numbered list, prose, code block, table)    |

Do not output anything yet.

### Step 2 — Verify with the user (two rounds of questions)

Use `AskUserQuestion` to confirm each segment. The tool only supports 4 questions per call, so split into two calls.

**Rules for every question:**
- Option 1: `Accept: "[your inferred value]"` — show the exact inferred text so the user can evaluate it
- Option 2: `Skip` — omit this segment from the final prompt
- The tool automatically provides an "Other" text field for manual entry — this counts as the third option; you do not need to add a manual-entry option yourself

**When to default option 1 to Skip instead of an inferred value:**
- Audience → default Skip when the original prompt requests code or a technical artifact (developers don't usually need audience framing)
- Tone → default Skip when Style already covers register fully

**Round 1 — ask C, O, S, T together (4 questions):**

```
AskUserQuestion([
  { header: "Context",   question: "What background/role context should the prompt set?",            options: [{ label: "Accept: <inferred>" }, { label: "Skip" }] },
  { header: "Objective", question: "What is the objective and key constraints?",                     options: [{ label: "Accept: <inferred>" }, { label: "Skip" }] },
  { header: "Style",     question: "What communication style should the AI use?",                    options: [{ label: "Accept: <inferred>" }, { label: "Skip" }] },
  { header: "Tone",      question: "What tone should the AI adopt?",                                 options: [{ label: "Accept: <inferred>" }, { label: "Skip" }] },
])
```

**Round 2 — ask A, R together (2 questions):**

```
AskUserQuestion([
  { header: "Audience",  question: "Who is the intended audience and what do they already know?",   options: [{ label: "Accept: <inferred>" }, { label: "Skip" }] },
  { header: "Response",  question: "What format should the response take?",                         options: [{ label: "Accept: <inferred>" }, { label: "Skip" }] },
])
```

If the user selected "Other" for any segment in Round 1, collect those manual values in a follow-up `AskUserQuestion` call before proceeding to Round 2.

### Step 3 — Build the final prompt

Take only the confirmed (non-skipped) segments and weave them into a single, natural-language prose prompt.

Rules:
- Do **not** use CO-STAR labels, headers, or bullet points in the output
- The prompt should read as one cohesive paragraph (or two at most) that a human would naturally write
- Keep it concise — omit filler phrases; every sentence should add instruction
- Present the result in a fenced code block so it is easy to copy

After the code block, briefly note which segments were included and which were skipped.