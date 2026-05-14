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
of outdated forks and downstream branches in company by continuously rebasing it
on top of the newest upstream. The idea was simple: add an automation that will
try to rebase on top of the upstream **periodically** (like once per week, or
once per day in case of some really active upstream branches) so the company
will reduce one of the reasons of the outdated forks: **when the fork developers
forget or do not have time** to even check whether the upstream has updates and
whether rebasing on top of these updates will introduce any conflicts.

So, the automation should have the following inputs:

1. The downstream repository (supposed but not required to be a fork of the
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

1. The solution **must not depend on CI&CD technologies** (e.g., GitHub Actions,
Woodpecker, etc.) so it will be possible to use it outside of the CI&CDs.
2. The solution should not depend on tools and projects that have huge codebase,
  or are unstable in terms of maintenance and license conditions.

For more about these requirements I strongly recomend you to read the
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
    more like extension to `git`.
  * The option `resolve` that is said to "Automatically resolve common rebase
    conflicts." might be interesting when I will be considering a tool for
    automated conflict resolution.
* [Jujutsu](https://github.com/jj-vcs/jj).
  * This tool is huge and is actually a separate version control system.
  * The rebase functionalities of that tool are interesting. But I have not
    found the needed functionalities. This seems to be a replacement for `git`,
    and not a one-line call tool for the idea I pursue.
* [rizzler](https://github.com/ghuntley/rizzler).
  * As it's readme says, it is a tool for automated conflict resolution. This
    might be interesting later.
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
  * Not quite what I need.
  * The tool might be very useful for complex projects and rebases because of
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

  * The tool seems to be completely vibecoded. I have already spotted some
    inconsistencies that confused me. <!-- TODO: I should think whether this
    sentence is appropriate.  -->

So it seems, out of everything I have found so far, the `rebasebot` is the only
tool that has a potential to be used in the planned flow.

But we have switched from a high-level flow right to the specific
implementations without analysing the implementation problems that need to be
solved by the tools. So lets analyze how the implementation should look like,
and what are the main implementation challenges here. Then we will check whether
the `rebasebot` solves the challenges.

# The implementation challenges

Lets discuss the challenges by going through every component from the "The
general idea diagram." I presented in [the chapter above](#the-general-idea). I
will reference the components by their IDs from the diagram (e.g., the `S1`, or
`D1`).

But I want to go through the `S4.1` and `S4.2` before touching the `S3`, as the
way the results of the automatic rebase attempt are stored will effect the `S3`.

## S1 and D1

The D1 component represents the format and place where the downstream changes
are stored. For my case it was `git` commits and `git` repository. But for the
cases when the automation will be launched in CI/CDs it might be useful to add
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
rebase automation should never force push (hence, overwrite) somebody's commits.
The reason: even if the rebase has completed without conflicts - it does not
mean the result will work (will build, launch, pass tests, etc.) as expected,
because most of the tools used for rebase (e.g., `git`) do not understand the
semantics of the code they operate on, and work mostly on such categories as
filesystem structures (e.g., the placement of file and directories in a
repository), the files contents, and the differences between two filesystem
structures and files contents.

Well, unless you will find a semantic version control system that will do the
automatic rebase - the entity, that should decide whether the rebase was
successful should be either a human or another automation that either understand
the semantics somehow or will confirm the correctness of the rebase via some
empirical experiment (e.g., a set of automatic tests performed on the target
system using the rebased software).

So, the `S4.1` should look like this:

![fetching and preparation]({{ site.baseurl }}/assets/images/2026-05-05-rebasing-automation/pushing-rebase-result.png)
_S4.1 action diagram_

Note, that you can encode whatever you want into the name of the branch that
will contain the rebased commits. For my needs the name of the downstream
branch was enough. And the `-rebased` postfix is for identification purposes.
E.g., you can consider encoding the hash of the top commit of the new base, if
it is useful for you.

The policy for not using the force pushes will not only protect the original
downstream branch but the branches with the same name as the newly created
branch that were created by somebody else or by the previous automated rebase
attempt. So it is a win-win design.

## S4.2 and D3.2

Before diving into the logic for the `S4.2` we need to answer the question what
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
successfully-rebased commit. This approach has three additional advantages:

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
  will fail with inappropriate message that it cannot force-push, instead of
  kicking the lazy developers in ass so they solve the conflict.

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
3. Add information what a developer should do for every result produced by the
  automation (I have written instructions for devs. as logs for local rebases,
  and as PRs for remote ones).
4. Cover it with tests.
5. And many more.

# The openshift-eng/rebasebot

Lets check whether the
[openshift-eng/rebasebot](https://github.com/openshift-eng/rebasebot) have the
described functionalities or if it has something else to propose to cover the
use case.

> Note, that I am checking the openshift-eng/rebasebot after I have already
> implemented the logic I have described here. So happened that I have found out
> about this bot just when writing this blog post. Sometimes I dream of ability
> to know everything in this world :/.

## The testbench

Firstly, let me introduce the testbench. For testing I will be using two local
repositories that have remote counterparts on my GitHub profile. The donwstream
repository with name `auto-rebase-script-tests` has the following downstream
branch:

```bash
danik in ~/Repos/auto-rebase-script-tests on feature λ git lol
* 68bd7e88b1b1 (HEAD -> feature) C7: feature edits line2 again
* 9a9fcbb6c12f C6: some empty feature commit
* 6bf2a43b8a1c C5: feature edits line2
* 09bd53e925cd C4: feature edits line3
* 3c5a8a05eb87 C3: some feature commit
* 312c0a8a9f40 C2: some feature commit
* 48d1e817815f C1: some feature commit
* a2df0ad56e71 (origin/master, origin/HEAD, master) A: base file
```

The commits edit the only file in the repository with the following content on
the commit `68bd7e88b1b1`:

```bash
danik in ~/Repos/auto-rebase-script-tests on feature λ cat file.txt
line1: shared
line2: FEATURE VERSION2
line3: feature change
line4: feature change
line5: feature change
line6: feature change
line7: feature change
```

The upstream repository with the name `auto-rebase-script-tests-upstream` has
the following upstream branch:

```bash
danik in ~/Repos/auto-rebase-script-tests-upstream on feature-upstream λ git lol
* 9749a2447b0a (HEAD -> feature-upstream, origin/feature-upstream) B: feature edits line2
* a2df0ad56e71 (origin/master) A: base file
```

The commits edit the only file in the repository with the following content on
the commit `9749a2447b0a`:

```bash
danik in ~/Repos/auto-rebase-script-tests-upstream on feature-upstream λ cat file.txt
line1: shared
line2: upstream VERSION
line3: shared
```

The upstream and downstream branches have a common ancestor:

```bash
danik in ~/Repos/auto-rebase-script-tests-upstream on feature-upstream λ git show a2df0ad56e71
commit a2df0ad56e71518d9248ca1afec282d90e599663 (origin/master)
Author: Daniil Klimuk <danik.klimuk13@gmail.com>
Date:   Thu Apr 9 10:49:09 2026 +0200

    A: base file

diff --git a/file.txt b/file.txt
new file mode 100644
index 000000000000..27bb0bbea916
--- /dev/null
+++ b/file.txt
@@ -0,0 +1,3 @@
+line1: shared
+line2: original
+line3: shared
```

The `git rebase feature-upstream feature` should result in two conflicts:

1. When applying the commit `dda06281d86b`:

    ```bash
    danik in ~/Repos/auto-rebase-script-tests on feature ● ● performing a rebase-i λ git diff
    diff --cc file.txt
    index f721a4c5399b,7ccf77245863..000000000000
    --- a/file.txt
    +++ b/file.txt
    @@@ -1,6 -1,6 +1,11 @@@
      line1: shared
    ++<<<<<<< HEAD
     +line2: upstream VERSION
     +line3: shared
    ++=======
    + line2: original
    + line3: feature change
    ++>>>>>>> dda06281d86b (C4: feature edits line3)
      line4: feature change
      line5: feature change
      line6: feature change
    ```

2. And on the commit `6f900d451bc4`:

    ```bash
    danik in ~/Repos/auto-rebase-script-tests on feature ● ● performing a rebase-i λ git diff
    diff --cc file.txt
    index 7d38a0443217,5e058651399f..000000000000
    --- a/file.txt
    +++ b/file.txt
    @@@ -1,5 -1,5 +1,9 @@@
      line1: shared
    ++<<<<<<< HEAD
     +line2: upstream VERSION
    ++=======
    + line2: FEATURE VERSION
    ++>>>>>>> 6f900d451bc4 (C5: feature edits line2)
      line3: feature change
      line4: feature change
      line5: feature change
    ```

After all the conflicts have been resolved and the rebase finishes we should
finish the result should be the following:

```bash
danik in ~/Repos/auto-rebase-script-tests on feature λ git lol
* c453f23a5583 (HEAD -> feature) C7: feature edits line2 again
* 513b6a4110cd C6: some empty feature commit
* 943f8d3a855c C5: feature edits line2
* 7b0e7488a306 C4: feature edits line3
* 33673fea21c2 C3: some feature commit
* 32ee361ee83e C2: some feature commit
* ac84b3568f2b C1: some feature commit
* 9749a2447b0a (upstream/feature-upstream) B: feature edits line2
* a2df0ad56e71 (upstream/master, origin/master, origin/HEAD, master) A: base file
```

So the history is linear and could be used for easy upstreaming of the `C[1-7]`
commits. The file should contain:

```bash
danik in ~/Repos/auto-rebase-script-tests on feature λ cat file.txt
line1: shared
line2: FEATURE VERSION2
line3: feature change
line4: feature change
line5: feature change
line6: feature change
line7: feature change
```

## Using the openshift-eng/rebasebot

I am using the tool from commit `99a09a17af1693c4d7a3782d9d360db60ce2a4e5`.

<details><summary> The first launch logs </summary>

{% markdown %}

{% highlight bash %}
(.venv) danik in ~/Repos/rebasebot on main ● λ rebasebot --source "https://github.com/DaniilKl/auto-rebase-script-tests-upstream:feature-upstream" --dest "DaniilKl/auto-rebase-script-tests:feature" --rebase "DaniilKl/auto-rebase-script-tests:feature" --working-dir "/tmp/for-tests" --github-user-token "./token" --dry-run
INFO - Using working directory: /tmp/for-tests
INFO - Logging to GitHub as a User
INFO - Logging to GitHub as a User
INFO - Destination repository is https://github.com/DaniilKl/auto-rebase-script-tests.git
INFO - rebase repository is https://github.com/DaniilKl/auto-rebase-script-tests.git
INFO - source repository is https://github.com/DaniilKl/auto-rebase-script-tests-upstream.git
INFO - Fetching feature from dest
INFO - Fetching feature-upstream from source
INFO - Fetching all tags from source
INFO - Fetching all branches from source
INFO - Checking out source/feature-upstream
INFO - Checking for existing rebase branch feature in https://github.com/DaniilKl/auto-rebase-script-tests
INFO - Fetching existing rebase branch
INFO - Branches with commit:
  source/feature-upstream
INFO - Preparing rebase branch
INFO - Merging upstream/feature-upstream into feature
INFO - Performing rebase
INFO - Merge base of source/feature-upstream and dest/feature: a2df0ad56e71518d9248ca1afec282d90e599663
INFO - Merges on ancestry-path from merge_base=(a2df0ad56e71518d9248ca1afec282d90e599663) to dest/feature branch:

INFO - Searching for merge commit from previous rebasebot run to identify downstream commits
INFO - Didn't find last rebase merge commit. Likely this is the first upstream rebase for the                     repository. If that's not the case, something is wrong with the last rebase identification.                     Using a2df0ad56e71518d9248ca1afec282d90e599663 as cutoff commit
INFO - Cutoff commits: ['^a2df0ad56e71518d9248ca1afec282d90e599663']
INFO - Phase 2 - other downstream commits (7):
41584bd14d9a05c23a730cecda3ac53515a3bdd3 || C1: some feature commit || danik.klimuk13@gmail.com
b7b0afd48f73e3309b1cc649326a82095eb62bb3 || C2: some feature commit || danik.klimuk13@gmail.com
5025efc20400b84d7d7f1b30c2a5494e9b9128bd || C3: some feature commit || danik.klimuk13@gmail.com
dda06281d86b438c9d1ece5789102145779b24c4 || C4: feature edits line3 || danik.klimuk13@gmail.com
6f900d451bc49c0f9a607fae1ebe4de0a7984dac || C5: feature edits line2 || danik.klimuk13@gmail.com
1a31f61f3cd2485370b7868a5868b05642c75518 || C6: some empty feature commit || danik.klimuk13@gmail.com
3e5034672e4b67fe1a6d49320035d7e69a235010 || C7: feature edits line2 again || danik.klimuk13@gmail.com
INFO - Total downstream commits: 7
INFO - Picking commit: 41584bd14d9a05c23a730cecda3ac53515a3bdd3 - C1: some feature commit
INFO - Picking commit: b7b0afd48f73e3309b1cc649326a82095eb62bb3 - C2: some feature commit
INFO - Picking commit: 5025efc20400b84d7d7f1b30c2a5494e9b9128bd - C3: some feature commit
INFO - Picking commit: dda06281d86b438c9d1ece5789102145779b24c4 - C4: feature edits line3
INFO - Picking commit: 6f900d451bc49c0f9a607fae1ebe4de0a7984dac - C5: feature edits line2
INFO - Picking commit: 1a31f61f3cd2485370b7868a5868b05642c75518 - C6: some empty feature commit
INFO - Picking commit: 3e5034672e4b67fe1a6d49320035d7e69a235010 - C7: feature edits line2 again
INFO - Checking for ART pull request
INFO - Dry run mode is enabled. Do not create a PR.
{% endhighlight %}

{% endmarkdown %}

</details>

<br>

The tool, surprisingly, finishes the rebase without any conflicts, but with the
following branch structure:

```bash
danik in ~/Repos/auto-rebase-script-tests on rebase-first-attemptλ git lol
* 394f65bf797e (HEAD -> rebase-first-attempt, origin/rebase-first-attempt) C7: feature edits line2 again
* 6fef2b0a47aa C6: some empty feature commit
* faef6dd0d65b C5: feature edits line2
* da05a2be5ffa C4: feature edits line3
* 55010e5e1847 C3: some feature commit
* ecf5df19a134 C2: some feature commit
* b0f3cd5a50ca C1: some feature commit
*   9de9c447ea6e merge upstream/feature-upstream into feature
|\
| * 9749a2447b0a (upstream/feature-upstream) B: feature edits line2
* | 3e5034672e4b (origin/feature) C7: feature edits line2 again
* | 1a31f61f3cd2 C6: some empty feature commit
* | 6f900d451bc4 C5: feature edits line2
* | dda06281d86b C4: feature edits line3
* | 5025efc20400 C3: some feature commit
* | b7b0afd48f73 C2: some feature commit
* | 41584bd14d9a C1: some feature commit
|/
* a2df0ad56e71 (upstream/master, origin/master, origin/HEAD, master) A: base file
```

I guess that is how the non-linear history looks like. Lest add a one more
commit to the `feature-upstream` that will cause another conflict:

```bash
danik in ~/Repos/auto-rebase-script-tests on feature-upstream λ git show
commit 0c1435ac701392f5b0a78071a5b5387226cea8d0 (HEAD -> feature-upstream, upstream/feature-upstream)
Author: Daniil Klimuk <danik.klimuk13@gmail.com>
Date:   Tue May 12 21:55:43 2026 +0200

    B1: feature edits line 2 again

    Signed-off-by: Daniil Klimuk <danik.klimuk13@gmail.com>

diff --git a/file.txt b/file.txt
index 765cf070fc65..1aef70e2e93b 100644
--- a/file.txt
+++ b/file.txt
@@ -1,3 +1,3 @@
 line1: shared
-line2: upstream VERSION
+line2: upstream VERSION2
 line3: shared
```

And do the rebase again.

<details><summary> The second rebase logs </summary>

{% markdown %}

{% highlight bash %}
(.venv) danik in ~/Repos/rebasebot on main ● λ rebasebot --source "https://github.com/DaniilKl/auto-rebase-script-tests-upstream:feature-upstream" --dest "DaniilKl/auto-rebase-script-tests:rebase-first-attempt" --rebase "DaniilKl/auto-rebase-script-tests:rebase-first-attempt" --working-dir "/tmp/for-tests" --github-user-token "./token" --dry-run
INFO - Using working directory: /tmp/for-tests
INFO - Logging to GitHub as a User
INFO - Logging to GitHub as a User
INFO - Destination repository is https://github.com/DaniilKl/auto-rebase-script-tests.git
INFO - rebase repository is https://github.com/DaniilKl/auto-rebase-script-tests.git
INFO - source repository is https://github.com/DaniilKl/auto-rebase-script-tests-upstream.git
INFO - Fetching rebase-first-attempt from dest
INFO - Fetching feature-upstream from source
INFO - Fetching all tags from source
INFO - Fetching all branches from source
INFO - Checking out source/feature-upstream
INFO - Checking for existing rebase branch rebase-first-attempt in https://github.com/DaniilKl/auto-rebase-script-tests
INFO - Fetching existing rebase branch
INFO - Branches with commit:
  source/feature-upstream
INFO - Preparing rebase branch
INFO - Merging upstream/feature-upstream into rebase-first-attempt
INFO - Performing rebase
INFO - Merge base of source/feature-upstream and dest/rebase-first-attempt: 9749a2447b0a166c883b8052d72dbf8f7f67c443
INFO - Merges on ancestry-path from merge_base=(9749a2447b0a166c883b8052d72dbf8f7f67c443) to dest/rebase-first-attempt branch:
9de9c447ea6eb3dc198d6f9446a0c83cfaab1ca9 || merge upstream/feature-upstream into feature || danik.klimuk13@gmail.com
INFO - Searching for merge commit from previous rebasebot run to identify downstream commits
INFO - Found merge commit from previous rebase: 9de9c447ea6eb3dc198d6f9446a0c83cfaab1ca9
INFO - Its parent 9749a2447b0a166c883b8052d72dbf8f7f67c443 is on an upstream branch
INFO - Cutoff commits: ['^3e5034672e4b67fe1a6d49320035d7e69a235010', '^9749a2447b0a166c883b8052d72dbf8f7f67c443']
INFO - Could not find rebase PR merge on dest, skipping phase 1
INFO - Phase 2 - other downstream commits (7):
b0f3cd5a50caf4c7d0faa3ffcea4c3261416ed2d || C1: some feature commit || danik.klimuk13@gmail.com
ecf5df19a134c9bd610a4e06b2b3b7b79fc67bd6 || C2: some feature commit || danik.klimuk13@gmail.com
55010e5e18470518a0c0649be195504e62e086f3 || C3: some feature commit || danik.klimuk13@gmail.com
da05a2be5ffa945294a9bda63c0b3f6896fe2832 || C4: feature edits line3 || danik.klimuk13@gmail.com
faef6dd0d65b8ed26910184568ce34bf501b2642 || C5: feature edits line2 || danik.klimuk13@gmail.com
6fef2b0a47aac96620974609cf234aa5b631f754 || C6: some empty feature commit || danik.klimuk13@gmail.com
394f65bf797e29dfa3e940e2ee04dd59ea93c681 || C7: feature edits line2 again || danik.klimuk13@gmail.com
INFO - Total downstream commits: 7
INFO - Picking commit: b0f3cd5a50caf4c7d0faa3ffcea4c3261416ed2d - C1: some feature commit
INFO - Picking commit: ecf5df19a134c9bd610a4e06b2b3b7b79fc67bd6 - C2: some feature commit
INFO - Picking commit: 55010e5e18470518a0c0649be195504e62e086f3 - C3: some feature commit
INFO - Picking commit: da05a2be5ffa945294a9bda63c0b3f6896fe2832 - C4: feature edits line3
INFO - Picking commit: faef6dd0d65b8ed26910184568ce34bf501b2642 - C5: feature edits line2
INFO - Picking commit: 6fef2b0a47aac96620974609cf234aa5b631f754 - C6: some empty feature commit
INFO - Picking commit: 394f65bf797e29dfa3e940e2ee04dd59ea93c681 - C7: feature edits line2 again
INFO - Checking for ART pull request
INFO - Dry run mode is enabled. Do not create a PR.
{% endhighlight %}

{% endmarkdown %}
</details>

<br>

And the branch structure after the second attempt:

```bash
danik in ~/Repos/auto-rebase-script-tests on rebase-second-attempt λ git lol
* ddc7f9264420 (HEAD -> rebase-second-attempt, origin/rebase-second-attempt) C7: feature edits line2 again
* 9633a8ee4d9b C6: some empty feature commit
* 54c98bed5832 C5: feature edits line2
* 0945663de419 C4: feature edits line3
* bf72600daf1e C3: some feature commit
* b8f27430066b C2: some feature commit
* ed73ca24e534 C1: some feature commit
*   37175c178f05 merge upstream/feature-upstream into rebase-first-attempt
|\
| * 0c1435ac7013 (upstream/feature-upstream, feature-upstream) B1: feature edits line 2 again
* | 394f65bf797e (origin/rebase-first-attempt, origin/rebase, rebase-first-attempt, rebase) C7: feature edits line2 again
* | 6fef2b0a47aa C6: some empty feature commit
* | faef6dd0d65b C5: feature edits line2
* | da05a2be5ffa C4: feature edits line3
* | 55010e5e1847 C3: some feature commit
* | ecf5df19a134 C2: some feature commit
* | b0f3cd5a50ca C1: some feature commit
* | 9de9c447ea6e merge upstream/feature-upstream into feature
|\|
| * 9749a2447b0a B: feature edits line2
* | 3e5034672e4b (origin/feature) C7: feature edits line2 again
* | 1a31f61f3cd2 C6: some empty feature commit
* | 6f900d451bc4 C5: feature edits line2
* | dda06281d86b C4: feature edits line3
* | 5025efc20400 C3: some feature commit
* | b7b0afd48f73 C2: some feature commit
* | 41584bd14d9a C1: some feature commit
|/
* a2df0ad56e71 (upstream/master, origin/master, origin/HEAD, master) A: base file
```

I am not sure whether it is a good idea or not to have such history. To me it
seems odd. Can it cause problems when, for example, trying to upstream the
commits from the downstream branch?

# The conclusions


