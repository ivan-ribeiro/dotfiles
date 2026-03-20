---
description: Start work on a Jira ticket. Fetches ticket details, creates a branch, moves the ticket to In Progress, and writes a summary file. Usage: /start-ticket DSY-123
---

# Start Ticket: $ARGUMENTS

You are starting work on Jira ticket **$ARGUMENTS**. Follow these steps exactly.

## Step 1: Fetch the Ticket

1. Call `getAccessibleAtlassianResources` to get the cloudId.
2. Call `getJiraIssue` with the ticket number `$ARGUMENTS` and request these fields: `summary`, `description`, `issuetype`, `status`, `priority`, `labels`.

## Step 2: Determine the Branch Prefix

Map the Jira issue type to a git branch prefix using this table:

| Jira Issue Type | Prefix |
|---|---|
| Bug, Defect, Incident | `fix` |
| Story, Feature, Improvement, Enhancement, New Feature | `feat` |
| Epic | `feat` |
| Documentation, Doc | `docs` |
| Task, Sub-task, Sub-Task | `chore` (unless title/description contains "doc" → use `docs`) |
| Refactor | `refactor` |
| Test | `test` |

If the issue type doesn't match, default to `chore`.

**Show the user** the detected prefix and give them the option to change it before continuing.

## Step 3: Derive the Short Branch Description

From the ticket **summary** (title), create a short kebab-case slug:
- 3–5 meaningful words maximum
- Lowercase, hyphens only (no special characters)
- Strip articles (a, an, the), prepositions, and filler words
- Example: "Migrate hooks documentation to new site" → `migrate-hooks-docs`

## Step 4: Assess Ticket Detail

Evaluate whether the ticket has enough detail to work from:
- **Sufficient**: Has a non-trivial description (more than one sentence of real content)
- **Insufficient**: Description is empty, just a title repeat, or fewer than ~30 words of actual content

If **insufficient**, ask the user: *"The ticket is light on details. Can you tell me more about what needs to be done?"* Wait for their answer before continuing.

## Step 5: Create the Branch

Construct the branch name:
```
{prefix}/{ticket-lowercase}-{short-description}
```

Example: `docs/dsy-51-migrate-hooks-docs`

- Ticket number must be **lowercase** (e.g., `DSY-51` → `dsy-51`)
- Branch off the **current HEAD** (do not switch to main first)

Run:
```bash
git checkout -b {branch-name}
```

## Step 6: Move Ticket to In Progress

1. Call `getTransitionsForJiraIssue` with the ticket number to get available transitions.
2. Find the transition whose name matches "In Progress" (case-insensitive).
3. Call `transitionJiraIssue` with that transition ID to move the ticket to "In Progress".

If no "In Progress" transition is found, skip this step silently and note it in the confirmation (Step 8).

## Step 7: Write the Ticket Summary File

Create `docs/tickets/{ticket-lowercase}.md` (e.g., `docs/tickets/dsy-51.md`).

Create the `docs/tickets/` directory if it doesn't exist.

**File content:**
- **Title**: The Jira ticket number and summary as a heading (e.g., `# DSY-51: Migrate hooks documentation`)
- **Jira link**: A link to the ticket at `https://workwave.atlassian.net/browse/{TICKET}`
- **Summary paragraph**: 1 concise paragraph describing what needs to be done and why. Distil the ticket content — do not dump the raw description. If the user provided extra detail in Step 4, incorporate it here.
- **Acceptance criteria** (if the ticket has them): a short bullet list

Do **not** include comments, metadata, timestamps, or anything else — keep it minimal.

## Step 8: Confirm

Tell the user:
- The branch that was created
- The ticket summary file path
- Whether the ticket was moved to "In Progress"
- A one-line summary of what the ticket asks for
