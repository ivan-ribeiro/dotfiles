# Impact Analyze

Analyze the codebase impact of an approved spec.

## Usage
`/impact-analyze <feature-name>`

## Instructions

You are a senior engineer performing a pre-change impact analysis. Your job is to read the approved spec and thoroughly analyze the existing codebase to produce an `impact-analysis.md`.

**Arguments:**
- `$FEATURE_NAME` — must match an existing spec at `.claude/specs/$FEATURE_NAME/spec.md`

**Steps:**
1. Read `.claude/specs/$FEATURE_NAME/spec.md`. If it doesn't exist, stop and tell the user.
2. Explore the codebase relevant to the spec — read files, trace imports, find callers.
3. You MAY spawn subagents to investigate specific areas in parallel.
4. Generate the impact analysis document using the template below.
5. Save to `.claude/specs/$FEATURE_NAME/impact-analysis.md`.
6. **STOP. Do not generate the change manifest.** Tell the user:
   > "✅ `impact-analysis.md` saved. Review it at `.claude/specs/$FEATURE_NAME/impact-analysis.md`.
   > When you're ready, run `/manifest-generate $FEATURE_NAME` to continue."

---

## impact-analysis.md Template

```markdown
# Impact Analysis: {{FEATURE_NAME}}

**Created:** {{DATE}}
**Spec:** [spec.md](./spec.md)
**Status:** Draft

---

## Affected Files

| File | Type of Change | Reason |
|------|---------------|--------|
| `path/to/file.ts` | Modify | ... |

## Downstream Dependencies

<!-- What calls, imports, or depends on the files above? -->

-

## Risk Areas

<!-- Race conditions, breaking API surfaces, shared state, auth boundaries, etc. -->

| Risk | Severity | Notes |
|------|----------|-------|
| | Low / Med / High | |

## Test Coverage Gaps

<!-- What does this change touch that has no current test coverage? -->

-

## Estimated Complexity

- [ ] S — straightforward, well-understood change
- [ ] M — moderate, a few moving parts
- [ ] L — significant, multiple systems involved
- [ ] XL — high complexity, consider breaking into smaller specs

## Notes
```