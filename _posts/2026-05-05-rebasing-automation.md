---
layout: post
title: "Git commits rebasing automation"
author: "Daniil"
tags: git commit rebase conflict ci cd workflow pipeline
excerpt_separator: <!--more-->
---

Just wanted to share some ideas on the automation of such a boring recurrent
manual work in programmings as "rebasing". Be prepared for some dense theory
with examples.

<!--more-->

# The general idea

So, some time ago I was asked to figure out a rebase automation to reduce amount
of outdated forks and downstream branches in company by continuesly rebasing it
on top of the newest upstream. The idea was simple: add an automation that will
try to rebase on top of the upstream **periodically** (like once per week, or
once per day in case of some really active upstream branches) so the company
will reduce one of the reasons of the outdated forks: **when the fork developers
forget or do not have time** to even check whether the upstream has updates and
whether rebasing on top of these updates will introduce any conflicts.

So, the automation should have the following inputs:

1. The the downstream repository (supposed but not required to be a fork of the
  upstream repository).
2. The downstream branch in the downstream repository that should be rebased.
3. The upstream repository.
4. The upstream branch in the upstream repository on top of which the downstream
  changes should be rebased on.

And the automation should produce the following outputs:

1. A rebased on top of the upstream branch downstream branch in case there is no
  conflicts.
2. A set of data about the conflict in case the automated rebase met a conflict.

As you can see, the automation should not try to resolve the conflict by itself.
Instead it should stop and provide a sufficient set of data for a human or
another automation to resolve the conflict. So, the logic can be described by
the following diagram:

![general-idea]({{ site.baseurl }}/assets/images/2026-05-05-rebasing-automation/general-idea.svg)
_The general idea diagram_

# The additional requirements

I had the following additional requirements:

1. The solution **must not depend on CI&CD technologies** (e.g., GitHUB Actions,
Woodpecker, etc.) so it will be possible to use it outside of the CI&CDs.
2. The solution should not depend on tools and projects that have huge codebases,
  or are unstable in terms of maintanance and license conditions.

For more about these requirements I strongly reccomend you to read the
[Stop rewriting your pipelines - achieving CI portability with Docker and
Taskfile](https://blog.3mdeb.com/2026/2026-04-27-stop-rewriting-your-pipelines/)
blog post posted by 3mdeb and Maciej Pijanowski.

# The existing solutions

# The additional problems
Lets take a brief look on what I have found during my quick research.

* [auto-rebase](https://github.com/marketplace/actions/auto-rebase):
  * This one depends on GitHub - it rebases PRs. Might be very hard to port to
    some other technology.
  * It is a GitHub action. Hence it does not meet the first requirement from
    the [list with additional requirements](#the-additional-requirements).
* [automatic-rebase](https://github.com/marketplace/actions/automatic-rebase):
  * The counterarguments are the same as for the `auto-rebase`.
* [git_rebase_helper](https://github.com/andoriyaprashant/git_rebase_helper).
  * As it's name suggests - it is a tool that helps during rebase, that seems
    more like extention to `git`.
  * The option `resolve` that is said to "Automatically resolve common rebase
    conflicts." might be interesting when I will be considering a tool for
    automated conflict resolution.
* [Jujutsu](https://github.com/jj-vcs/jj).
  * This tool is huge and is actually a separate version control system.
  * The rebase functionalities of that tool are interesting. But I have not
    found the needed functionalities. This seems to be a replacement for `git`,
    and not a one-line call tool for the idea I persue.
* [rizzler](https://github.com/ghuntley/rizzler).
  * As it's readme says, it is a tool for automated conflict resultion. This
    might be interestinga later.
* [AutoMergeTools](https://github.com/xgouchet/AutoMergeTool).
  * The same as for the `rizzler`, but seems to not use AI to solve the
    conflicts.
* [Sampling](https://sapling-scm.com/).
  * The notes are similar as for the `Jujutsu` - it is rather a replacement for
    `git`.
* [git-imerge](https://github.com/mhagger/git-imerge).
  * This one is interesting. In short, it is a collection of advanced rebase and
    merge strategies for complex rebase and merge cases. That is not the tool I
    need.
* [rebase-helper](https://github.com/rebase-helper/rebase-helper).
  * This is an interesting tool for RPM package rebase automation. The tool
    checks the `.spec.in` file, apply the patches from the `.spec.in` file to
    the source of some component via `git` and the rebase the applied patches on
    top of new upstream using `git`. Not my use case, but might be useful for
    RPM rebases.
* [chrisledet/rebasebot](https://github.com/chrisledet/rebasebot).
  * Seems to be too tied to GitHub and GitHub's webhooks.
  * The last commit was 10 years ago.
* [git-rebase-all](https://github.com/nornagon/git-rebase-all).
  * Not quite what I need. But interesting idea of rebasing several branches at
    once.
  * The last commit was 10 years ago too.
* [rebase-upstream-action](https://github.com/imba-tjd/rebase-upstream-action).
  * Yet another GitHub action.
* [rbt](https://github.com/jacobsee/rbt).
  * Not qiet what I need.
  * The tool might be very usefull for complex projects and rebases beaceuse of
    its upstream status visualisation and the comparison of the same commit but
    from two branches.
* [merge-bot](https://github.com/shiftstack/merge-bot).
  * Interesting tool, but for merges automation only.
  * No options to test it on local repositories.
* [openshift-eng/rebasebot](https://github.com/openshift-eng/rebasebot).
  * That one seems to handle automatic rebase, at least the readme says so.
  * After a quick look in its source code I have actually found the function
    responsible for the rebase:

      ```python
      def _do_rebase(
          *,
          gitwd: git.Repo,
          source: GitHubBranch,
          dest: GitHubBranch,
          source_repo: Repository,
          tag_policy: str,
          conflict_policy: str = "auto",
          bot_emails: list,
          exclude_commits: list,
          update_go_modules: bool,
      ) -> None:
          logging.info("Performing rebase")

          allow_bot_squash = len(bot_emails) > 0
          if allow_bot_squash:
              logging.info("Bot squashing is enabled.")

          downstream_commits = _identify_downstream_commits(gitwd, source, dest)

          commits_to_squash = defaultdict(list)

          for commit_line in downstream_commits.splitlines():
              # Commit contains the message for logging purposes,
              # trim on the first space to get just the commit sha
              sha, commit_message, committer_email = commit_line.split(" || ", 2)

              if _in_excluded_commits(sha, exclude_commits):
                  logging.info("Explicitly dropping commit from rebase: %s", sha)
                  continue

              (...)

              logging.info("Picking commit: %s - %s", sha, commit_message)

              _safe_cherry_pick(
                  gitwd=gitwd,
                  sha=sha,
                  source_branch=source.branch,
                  conflict_policy=conflict_policy,
                  commit_description=f"{sha} - {commit_message}",
              )

              (...)
      ```

    And it can even handle dropping some commits!

  * The tool seems to be completely vibecoded. I have already spottet some
    inconsistencies that confused me.

So it seems, out of everything I have found so far, the `rebasebot` is the only
tool that has a potential to be used in the planned flow.

But we have switched from a high-level flow right to the specific
implementations without analysing the implementation problems that need to be
solved by the tools. So lets analyze how the implementation should look like,
and what are the main implementation challanges here. Then we will check whether
the `rebasebot` solves the challanges.

# The conclusions


