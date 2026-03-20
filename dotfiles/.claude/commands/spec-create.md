# Spec Create

Generate a specification document for a new feature or change.

## Usage
`/spec-create <feature-name> "<brief description>"`

## Instructions

You are a requirements specialist. Your job is to generate a thorough `spec.md` for the feature described.

**Arguments:**
- `$FEATURE_NAME` — the slug for this feature (e.g. `user-auth`)
- `$DESCRIPTION` — the brief provided by the developer

**Steps:**
1. Ask the user up to 3 clarifying questions if the description is ambiguous. Wait for answers before proceeding.
2. Generate the spec document using the template below.
3. Save the file to `.claude/specs/$FEATURE_NAME/spec.md`.
4. Print a summary of what was written.
5. **STOP. Do not proceed to impact analysis.** Tell the user:
   > "✅ `spec.md` saved to `.claude/specs/$FEATURE_NAME/spec.md`.
   > Review it and when ready run `/impact-analyze $FEATURE_NAME` to continue."

---

## spec.md Template

```markdown
# Spec: [Feature Name]

| Field | Value |
| :---- | :---- |
| **Status** | draft |
| **Branch** | `feat/[feature-name]` |
| **Created** | YYYY-MM-DD |
| **Updated** | YYYY-MM-DD |

## Summary / Description

What this spec accomplishes and relevant context for its execution.

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Unanswered Questions

| # | Question | Answer | Resolved |
| :---- | :---- | :---- | :---- |
| 1 | Example: Should this support mobile? | | ☐ |
| 2 | | | ☐ |

## Plan

### Step 1: [Description]

What this step accomplishes and how.

**Commit:** `feat: [feature-name] - step 1 description`

### Step 2: [Description]

What this step accomplishes and how.

**Commit:** `feat: [feature-name] - step 2 description`

## Execution Log

*The AI Agent will update the following sections after every step has been completed.*

### Step 1 - Pending

- Started: —
- Notes: —

### Step 2 - Pending

- Started: —
- Notes: —

## Files Changed

<!-- Agent populates this section during execution -->

## Testing

- Automated tests added/updated:
- Manual testing performed:
- Edge cases verified:

## Final Notes

<!-- Agent populates after all steps complete -->
```

---

## Execution Log Rules

The agent **must** follow these rules when updating the Execution Log during `/manifest-execute`:

- When a step **starts**: update its entry to `### Step N - In Progress` and set `Started: YYYY-MM-DD HH:MM`
- When a step **completes**: update to `### Step N - Complete ✓` and set `Completed: YYYY-MM-DD HH:MM` plus any notes
- When a step **fails**: update to `### Step N - Failed ✗`, record `Failed: YYYY-MM-DD HH:MM` and a clear reason
- After all steps: populate `## Files Changed`, `## Testing`, and `## Final Notes`
- Update the `**Updated**` field in the header table on every write
- Never skip updating the log — it is the live record of execution