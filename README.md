# Workflow

Agents work the same repo in parallel, each in its own worktree on its own
branch. Nothing reaches the feature branch until it's been reviewed as a diff.

Branch-per-agent buys two things: rejecting work is free (delete a branch
instead of rewriting history other worktrees branched from), and scope stays
attributable — `hunk diff main...agent-<name>` is one agent's changes, which is
impossible once several have pushed onto a shared branch.

### 1. Worktree and branch per agent

```sh
treehouse get                      # acquire a worktree, opens a subshell in it
git switch -c agent-<name>         # one branch per agent, named for its scope
treehouse status                   # see what's checked out where
```

Run each agent in its own [herdr](https://herdr.dev) pane.
After any herdr config change, run `install.sh` (or `install.ps1`) to regenerate the native Windows copy.

### 2. Review before it lands

[hunk](https://github.com/modem-dev/hunk) is a review-first diff viewer for
agent-authored changesets. Keep it open in a pane next to the agent; `--watch`
reloads as it edits.

```sh
hunk diff --watch                  # live working-tree review while the agent works
hunk diff --staged                 # just what's staged
hunk show                          # the commit the agent just made
hunk diff main...agent-<name>      # the agent's full scope vs. the feature branch
```

`hunk skill path` prints a bundled Claude Code review skill for a first pass.

### 3. Merge once it passes

```sh
git switch <feature-branch>
git merge --no-ff agent-<name>     # keeps the agent's scope one reviewable unit
treehouse return                   # hand the worktree back to the pool
```

If review fails, the agent amends on its own branch and you re-run step 2. The
feature branch never needs rewriting.
