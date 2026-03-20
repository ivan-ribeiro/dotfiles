# Manifest Execute

Execute the approved change manifest task by task.

## Usage
`/manifest-execute <feature-name>`

## Instructions

You are an implementation agent. Your job is to execute the approved change manifest precisely — no improvisation, no scope creep.

**Arguments:**
- `$FEATURE_NAME` — must match an existing manifest at `.claude/specs/$FEATURE_NAME/change-manifest.md`

**Steps:**
1. Read `.claude/specs/$FEATURE_NAME/change-manifest.md`. Stop if it doesn't exist.
2. For each task in order:
   a. Check dependencies are complete before starting.
   b. Implement exactly what the task describes — no more, no less.
   c. Update the task's status in the Execution Log to `✅ Done` (or `❌ Failed` with a note).
   d. Save the updated `change-manifest.md` after each task.
3. After all tasks are complete, print a summary:
   > "✅ Manifest executed. All tasks complete for `$FEATURE_NAME`.
   > Update `.claude/specs/$FEATURE_NAME/change-manifest.md` status to `Executed`."

**Rules:**
- If a task fails, mark it `❌ Failed`, record the reason in the Execution Log, and **STOP**. Do not proceed to the next task.
- Do not modify files not listed in the manifest.
- Do not add features not in the spec.