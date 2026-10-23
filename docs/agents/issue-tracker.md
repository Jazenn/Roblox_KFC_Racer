# Issue tracker: GitHub

Issues and specs live in GitHub Issues for Jazenn/Roblox_KFC_Racer.
Use the gh CLI from this repo.

## Conventions

- Create: gh issue create --title "..." --body-file <file>
- Read: gh issue view <number> --json number,title,body,labels,comments
- List: gh issue list --state open --json number,title,body,labels
- Comment: gh issue comment <number> --body-file <file>
- Apply labels: gh issue edit <number> --add-label "<label>"
- Remove labels: gh issue edit <number> --remove-label "<label>"
- Close: gh issue close <number> --comment "..."

For multiline bodies, write the text to a temporary file and use --body-file.
Infer the repository from the Git remote.

When a skill says "publish to the issue tracker", create a GitHub issue.
When it says "fetch the relevant ticket", read the GitHub issue.

## Related issues

Link child issues through GitHub sub-issues when supported.
Otherwise, put "Part of #<parent>" in each child and maintain a task list
in the parent.

Use native GitHub issue dependencies for blockers when available.
Otherwise, add "Blocked by: #<number>" to the issue body.
An issue is unblocked when all its blockers are closed.

## Pull requests as a triage surface

PRs as a request surface: no.
