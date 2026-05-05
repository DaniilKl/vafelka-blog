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
of outdated forks in company by continuesly rebasing it on top of the newest
upstream. The idea was simple: add an automation that will try to rebase on top
of the upstream **periodically** so the company will reduce one of the reasons
of the outdated forks: **when the fork developers forget or do not have time**
to even check whether the upstream has updates and whether rebasing on top of
these updates will introduce any conflicts.

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

I had the following additional requirements

* Easy integration into CI&CD.
* Possibility of local launch via CLI.
* Easy containerisation.
* A minimal list of generic dependencies.

Let me break down the impact of these requirements.

## Easy integration into CI&CD

## Possibility of local launch via CLI

## Easy containerisation

## A minimal list of generic dependencies

# The existing solutions

# The additional problems

# The conclusions


