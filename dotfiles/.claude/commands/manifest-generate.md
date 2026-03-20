# Manifest Generate

Generate a change manifest from an approved spec and impact analysis.

## Usage
`/manifest-generate <feature-name>`

## Instructions

You are a tech lead producing an execution contract. Translate the approved spec and impact analysis into a precise, ordered, atomic task list.

**Arguments:**
- `$FEATURE_NAME` — must match existing files at `.claude/specs/$FEATURE_NAME/`

**Steps:**
1. Read `.claude/specs/$FEATURE_NAME/spec.md` and `.claude/specs/$FEATURE_NAME/impact-analysis.md`. Stop if either is missing.
2. Generate the change manifest using the template below. Tasks must be:
   - **Atomic** — each task is a single reviewable unit of work
   - **Ordered** — dependencies respected, unblocked tasks listed first
   - **File-scoped** — every task names the exact file(s) it touches
   - **Commit-tagged** — every step has a suggested commit message
3. Save to `.claude/specs/$FEATURE_NAME/change-manifest.md`.
4. **STOP. Do not execute any tasks.** Tell the user:
   > "✅ `change-manifest.md` saved to `.claude/specs/$FEATURE_NAME/change-manifest.md`.
   > Review it and when ready run `/manifest-execute $FEATURE_NAME`."

---

## change-manifest.md Template

```markdown
# Manifest: [Feature Name]

| Field | Value |
| :---- | :---- |
| **Status** | draft |
| **Branch** | `feat/[feature-name]` |
| **Created** | YYYY-MM-DD |
| **Updated** | YYYY-MM-DD |
| **Spec** | [spec.md](./spec.md) |
| **Impact Analysis** | [impact-analysis.md](./impact-analysis.md) |

## Summary / Description

What this manifest accomplishes. Reference the spec goal and list the number of tasks.

## Acceptance Criteria

<!-- Mirror the spec's acceptance criteria — these are what done looks like -->
- [ ] Criterion 1
- [ ] Criterion 2

## Unanswered Questions

| # | Question | Answer | Resolved |
| :---- | :---- | :---- | :---- |
| 1 | | | ☐ |

## Plan

### Step 1: [Description]

What this step does and why. List exact files touched.

- **Files:** `path/to/file.ts`, `path/to/other.ts`
- **Why:** Satisfies REQ-001
- **Depends on:** none
- **Rollback:** How to undo

**Commit:** `feat: [feature-name] - step 1 description`

### Step 2: [Description]

What this step does and why.

- **Files:** `path/to/file.ts`
- **Why:** Satisfies REQ-002
- **Depends on:** Step 1
- **Rollback:** How to undo

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

- When a step **starts**: update to `### Step N - In Progress`, set `Started: YYYY-MM-DD HH:MM`
- When a step **completes**: update to `### Step N - Complete ✓`, set `Completed: YYYY-MM-DD HH:MM` plus notes
- When a step **fails**: update to `### Step N - Failed ✗`, set `Failed: YYYY-MM-DD HH:MM` and reason
- After all steps: populate `## Files Changed`, `## Testing`, and `## Final Notes`
- Update the `**Updated**` and `**Status**` fields in the header table on every write
- Set `**Status**` to `executed` once all steps are complete
- Never skip updating the log — it is the live record of execution