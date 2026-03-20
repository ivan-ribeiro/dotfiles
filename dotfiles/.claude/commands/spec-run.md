# Spec Run (Master Orchestrator)

Run the full Spec → Impact Analysis → Change Manifest workflow with approval gates.

## Usage
`/spec-run <feature-name> "<brief description>"`

## Instructions

You are the workflow orchestrator. Guide the developer through all three phases of spec-driven development, pausing for explicit approval at each gate before proceeding.

**Arguments:**
- `$FEATURE_NAME` — slug for this feature
- `$DESCRIPTION` — brief description of the feature or change

---

## Phase 1: Spec

1. Check if `.claude/specs/$FEATURE_NAME/spec.md` already exists.
   - **If it exists** (seeded by `/bridge`): read it, summarize the pre-filled requirements to the user, and skip to Gate 1 immediately. Do NOT overwrite it.
   - **If it does not exist**: run the `/spec-create` flow for `$FEATURE_NAME` using `$DESCRIPTION` to generate it.
2. Once `spec.md` is confirmed, **STOP and present Gate 1:**

> ---
> ## 🔵 Gate 1: Spec Review
> `spec.md` is ready at `.claude/specs/$FEATURE_NAME/spec.md`
> _(source: auto-seeded from Bridge report | freshly generated)_
>
> Please review it and reply with one of:
> - **`approve`** — proceed to Impact Analysis
> - **`revise: <your feedback>`** — I'll update the spec and re-present this gate
> ---

3. If the user says `revise`, apply their feedback to `spec.md` and re-present Gate 1.
4. Only proceed when the user explicitly says `approve`.

---

## Phase 2: Impact Analysis

5. Run the `/impact-analyze` flow for `$FEATURE_NAME`.
6. Once `impact-analysis.md` is saved, **STOP and present Gate 2:**

> ---
> ## 🟡 Gate 2: Impact Analysis Review
> `impact-analysis.md` has been saved to `.claude/specs/$FEATURE_NAME/impact-analysis.md`
>
> Please review it and reply with one of:
> - **`approve`** — proceed to Change Manifest
> - **`revise: <your feedback>`** — I'll update the analysis and re-present this gate
> ---

7. If the user says `revise`, apply their feedback and re-present Gate 2.
8. Only proceed when the user explicitly says `approve`.

---

## Phase 3: Change Manifest

9. Run the `/manifest-generate` flow for `$FEATURE_NAME`.
10. Once `change-manifest.md` is saved, **STOP and present Gate 3:**

> ---
> ## 🟢 Gate 3: Change Manifest Review
> `change-manifest.md` has been saved to `.claude/specs/$FEATURE_NAME/change-manifest.md`
>
> All three planning documents are complete. Review the manifest and when ready to execute:
> - Run `/manifest-execute $FEATURE_NAME` to begin implementation
> - Or **`revise: <your feedback>`** to adjust the manifest first
> ---

**The orchestrator's job ends here.** Execution is a separate, explicit step.