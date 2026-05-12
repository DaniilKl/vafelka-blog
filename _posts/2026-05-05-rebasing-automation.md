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

# The implementation challanges

Lets discuss the challenges by going through every component from the "The
general idea diagram." I presented in [the chapter above](#the-general-idea). I
will reference the components by their IDs from the diagram (e.g., the `S1`, or
`D1`).

But I want to go through the `S4.1` and `S4.2` before touching the `S3`, as the
way the results of the automatic rebase attempt are stored will effect the `S3`.

## S1 and D1

The D1 component represents the format and place where the downstream changes
are stored. For my case it was `git` commits and `git` repository. But for the
cases when the automation will be lauched in CI/CDs it might be usefull to add
support for both: local and remote repositories (e.g., GitHub, Gitea). This
would make the automation more self-contained and will satisfy the first
requirement from the [The additional requirements
chapter](#the-additional-requirements).

So, the activity diagram should be the following:

![fetching and preparation]({{ site.baseurl }}/assets/images/2026-05-05-rebasing-automation/fetching-and-preparation-downstream.png)
_S1 action diagram_

## S2 and D2

These are actually similar to the `S1` and the `D1`:

![fetching and preparation]({{ site.baseurl }}/assets/images/2026-05-05-rebasing-automation/fetching-and-preparation-upstream.png)
_S2 action diagram_

The adding the upstream repository as a remote is needed to use `git rebase`
command.

## S4.1 and D3.1

As I have mentioned for the `S1` and `S2` - the changes will be prepared for the
rebase as `git` commits and `git` repositories. So the outputs should adhere to
the same format so the automation could be called in loop without surplus
conversion between the inputs and outputs format or some other automation that
understands the `git` could, without any conversions, consume the result of this
automation. Why the loop? Well, I will get to it later.

The question is, how to store the data from the `D3.1` block using only the
`git` refs? For the `D3.1` the solution is simple and is the result of the
following facts:

1. We are rebasing `git` commits.
2. `git` commits must be assigned to some `git` ref. to be able to exist in
  `git` tree.
3. The `git` ref. can be easily pushed to remote later.

Because we are rebasing the branches - it would be logical to create **a new**
branch with rebased commits. Then we can push the new branch to remote if
needed.

I am highlighting the "a new" here, because for me it is important the
rebase automation should never force push (hence, ovewrite) somebody's commits.
The reason: even if the rebase has completed without conflicts - it does not
mean the result will work (will build, launch, pass tests, etc.) as expected,
because most of the tools used for rebase (e.g., `git`) do not understand the
semantics of the code they operate on, and work mostly on such categories as
filesystem structures (e.g., the placement of file and directories in a
repository), the files contents, and the differences between two filesystem
structures and files contents.

Well, unless you will find a semantic version controll system that will do the
automatic rebase - the entity, that should decide whether the rebase was
successful should be either a human or another automation that either understand
the semantics somehow or will confirm the correctness of the rebase via some
empirical experiment (e.g., a set of automatic tests perfomed on the target
system using the rebased software).

So, the `S4.1` should look like this:

![fetching and preparation]({{ site.baseurl }}/assets/images/2026-05-05-rebasing-automation/pushing-rebase-result.png)
_S4.1 action diagram_

Note, that you can encode whatever you want into the name of the branch that
will caontain the rebased commits. For my needs the name of the downstream
branch was enogh. And the `-rebased` postfix is for identification purposes.
E.g., you can consider encoding the hash of the top commit of the new base, if
it is useful for you.

The policy for not using the force pushes will not only protect the original
downstream branch but the branches with the same name as the newly created
branch that were created by somebody else or by the previous automated rebase
attempt. So it is a win-win design.

## S4.2 and D3.2

Before diving into the logic for the `S4.2` we need to aswer the question what
is the "Conflict data" that should be stored in `D3.2`? The are two answers
depending on which abstraction level one wants to look:

1. The rebased code level. This means this is the data that describes which line
  in which file caused the conflict. E.g., when `git rebase` faces a conflict
  and leaves the repository in the state when some file contains the `git`
  conflict markers, for example:

    ```text
    feature 1
    <<<<<<< feature-2
    feature 2
    =======
    feature 1.2
    >>>>>>> feature-1.2
    ```

    This data describes the actual conflict, but does not provide the
    information which commit and when caused the conflict. This would be usable
    as a direct inptu to some conflict resolution tool.

2. The `git` refs and commits data level. E.g., when `git` reports you that a
  conflict has been faced, for example:

    ```bash
    λ git rebase feature-1.2 feature-2
    Auto-merging feature-file
    CONFLICT (content): Merge conflict in feature-file
    error: could not apply b175ce38688b... feature 2 commit
    hint: Resolve all conflicts manually, mark them as resolved with
    hint: "git add/rm <conflicted_files>", then run "git rebase --continue".
    hint: You can instead skip this commit: run "git rebase --skip".
    hint: To abort and get back to the state before "git rebase", run "git rebase --abort".
    hint: Disable this message with "git config set advice.mergeConflict false"
    Could not apply b175ce38688b... # feature 2 commit
    ```

    As you can see we can get the following information:

    a. When the conflict was faced: when rebasing the branch `feature-2` on top
      of the `feature-1.2`.
    b. What commit introduced the conflict: the commit with hash `b175ce38688b`.

Considering the idea of the automation is to only check for the conflicts, and
not resolve them or directly launch a tool that will resolve the conflict in
place - the data provided on the `git` refs and commits data level will be more
appropriate here, because:

1. The data still has the format of the `git` commits and `git` refs. This will
  be consistent with the `D3.1`.
2. This is the sufficient amount of data for some other tool (e.g., a tool for
  automatic conflict resolution) to reproduce the conflict.

Ok, now we know what we need to store. The next question is how to store it? The
ideas:

1. Just redirect it to `STDOUT` as logs.
    * Pros:
        1. The simplest solution possible. One can simply let the `git` print
          the information.
        2. The `STDOUT` can be considered as a generic channel.
    * Cons:
        1. One would need to implement a solution to save and redirect the logs,
          as the logs are not always saved or are not always automatically
          redirected (e.g., moving the logs between the GitHub Actions jobs).
        2. Possible integration problems. As one will need to teach the
          consecutive automation step how to parse the logs.
2. Redirect somewhere else instead of `STDOUT`.
    * Pros:
        1. Easy integration with the technologies that understand the channel
          where one redirects the data out of the box.
    * Cons:
        1. One will need to maintain either a channel or a place where the data
          will be redirected.
        2. Dependency on some non-generic channel or place.
        3. Not easy integration with the technologies that do not understand
          the channel where one redirects the data out of the box.
3. Encode the information to some temporary `git` ref.
    * Pros:
        1. Consistency with other steps in this automation: all outputs are
          stored as a `git` ref.
        2. `git` refs can be considered a generic channel.
    * Cons:
        1. The `git` refs [are
        limited](https://stackoverflow.com/questions/60045157/what-is-the-maximum-length-of-a-github-branch-name)
        in terms of amout of the information they can contain.
        2. One will need to add an additional ref to save the data.

For me the third option seems to be the most optimal. More than that, instead of
creating some ref on some random commit - I can create a ref on the last
successfully-rebased commit. This approach has three additional advanteges:

1. This is a way to save the rebase state even if the rebase was performed
  automatically in a CI&CD.
2. Instead of encoding the names of two branches (the upstream and downstream)
  and a commit hash I can leave only the name of the donwstream branch and the
  commit hash.
3. To reproduce the conflict one will only need to do one custom command:
  extract the commit hash from the ref name. Then the commit can be
  cherry-picked on the ref with the current rebase state.

So, the `S4.2` should look like this:

![fetching and preparation]({{ site.baseurl }}/assets/images/2026-05-05-rebasing-automation/pushing-conflict-result.png)
_S4.2 action diagram_

As you can see, the flow is pretty similar to the `S4.1`.

## S3

Lets get to the core component, the step that is responsible for the rebases.
One would say, just add the following as the `S3`:

![rebasing-raw]({{ site.baseurl }}/assets/images/2026-05-05-rebasing-automation/rebase-raw.png)

But I will say no. Remember the idea, that this automation should be launched
periodically? This periodical launch can cause two problems:

1. The downstream repository can be polluted with the `-conflict` branches, in
  three cases:

    1. The conflict commit hash which is a part of the `-conflict` branch name
      has changed without resolving the actual conflict. In such case the next
      call of the automation will result in creation of another `-conflict`
      branch with different name because of the different conflict commit hash
      but with the same actual conflict.
    2. The entire downstream branch history has been rewritten, but the
      developers have forgotten to delete the `-conflict` branches.
    3. The developers have forgotten to delete the `-conflict` branch after
      resolving the conflict.

2. The automation will fail every time it will try to rebase but will not be
  able to force push the `-conflict` branch if it does already exist. But it
  will fail with inapropriate message that it cannot force-push, instead of
  kicking the lasy developers in ass so the solve the conflict.

Hence, taking into account the above problems, the optimal solution for the `S3`
will be:

![rebasing-raw]({{ site.baseurl }}/assets/images/2026-05-05-rebasing-automation/rebase.png)
_S3 action diagram_

## Some other notes

The content I have provided above is not the final solution, it is only the
logic that comes out of my experience. To turn it into the final solution you
will need:

1. Turn the logic into code.
2. Add error handling, output values, logs, etc.
3. Add information what a developr should do for every result produced by the
  automation (I have written instructions for devs. as logs for local rebases,
  and as PRs for remote ones).
4. Cover it with tests.
5. And many more.

# The conclusions


