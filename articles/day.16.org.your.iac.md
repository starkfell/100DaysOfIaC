# Day 16 - Infrastructure-as-Code Strategies and Best Practices

In Infrastructure-as-Code (IaC), we use templates and scripts and other artifacts to describe a desired environment in a manner that is declarative and idempotent and hopefully, fully automated. Best practices are important for managing IaC efficiently, and seldom do we see all the small details addressed. Today is the day we try to cover a few of these small details.

[Codify your IaC](#codify-your-iac)<br/>
[Version your IaC](#version-your-iac)<br/>
[The Repository](#the-repository)<br/>
[How many Git repos do you need for IaC?](#how-many-git-repos-do-you-need-for-iac)<br/>
[Test Integration](#test-integration)<br/>
[Branching Strategy](#branching-strategy)<br/>
[Next Steps?](#next-steps)<br/>

## Codify your IaC

Use code to describe the infrastructure everywhere you can. In Azure, this means everything from VMs and containers, to firewalls and load balancers, and the myriad PaaS components in the cloud. However, it also means all the services and configurations around it, like DNS, antivirus, disk encryption, etc.

If I can take all the manual steps out of an infrastructure deployment down to creating DNS records for the user-facing endpoints, I do it.

## Version your IaC

All the infrastructure you express as code should be versioned. This means not just build artifacts (like ARM templates and scripts), but binary artifacts as well, and we'll do it all in Git.

We can use the [tagging feature in Git](https://git-scm.com/book/en/v2/Git-Basics-Tagging) to mark our releases with version numbers (v1.0, v 1.5, etc). Git includes **lightweight tags**, and **annotated tags**. I prefer annotated tags, because they're full objects in the DB, they have a checksum, tagger's name, email, and date. A solid history we can reference when memory fails us.

For example:

**I can create a tag:**

`git tag -a v1.0 -m "my APIM instance 1.0`

The -m is a message stored with the tag. When you use annotated tags (specified by the -a) and forget to add a message, Git will prompt you.

**I can show a tag**

Here, I see tag data along with the commit:

```bash
$ git show v1.0
tag v1.0
Tagger: Pete Zerger <pete@gmail.com>
Date:   Thu Sep 26 03:15:00 2019 -0600

IaC version 1.0

commit ca82a6dlkjrgec66f44342007202690a78963945
Author: Ryan Irujo <starkfell@gmail.com>
Date:   Thu Sep 26 03:15:00 2019 +0100
```

## How many Git repos do you need for IaC?

The answer is "one". I highly recommend one Git repository per organization. In my experience, one infrastructure as code repository is enough for an org of just about any size and scale. This repository acts as the central reference for your IaC implementation. With that in mind, you can always modularize your IaC implementation and take the "one repository" concept to another level of granularity using **submodules**.

The problem solved by submodules is best described by [Lorna Mitchell](https://dzone.com/articles/git-submodules-dependent-or). 

"*Git's submodule feature allows you to have one repo which has another repo as a subdirectory. This is useful for code which is either common to multiple projects, or which is a library you're using in this project but which is still under active development - you know it will change, and you may make those changes within the project you're working on.*"

If you're new to submodules, I recommend you bookmark the link behind her name above and read that article.

## Test Integration

As demonstrated in [Day 12](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.12.contin.integration.md), testing your IaC is part of the process. Integrating testing into the CI/CD process catches bugs before you get to production. By taking a test-driven approach to IaC, initially you will implement a bunch of small tests (unit tests), that will vary based on the tech you're working with. For example:

- For ARM templates, you might start with the template validation process demonstrated in [Day 12](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.12.contin.integration.md).
- For PowerShell scripts, you'll use **Pester**.
- For Bash (like Azure CLI), you might use [BATS](https://github.com/sstephenson/bats) or [Scriptkeeper](https://www.originate.com/thinking/stories/testing-bash-scripts-with-scriptkeeper/)

![Use Pester](../images/day16/use.pester.jpg)

I tend to follow a strategy that aligns with the test-driven development methodology, but don't get hung up on philosophies at this point. Just know that in IaC, testing is your responsibility, just like security is your responsibility. Over time, you'll progress from unit tests, into regression tests and acceptance tests and so on.

>**NOTE**: Testing in IaC will be covered more than once as the series progresses.


## Branching Strategy

In [Day 10](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.10.cicd.iac.bldg.blocks.md), we talked about an environment-based branching strategy that incorporated **Master** and **Develop**. I suggest you start there and expand from there if needed.

## Next Steps?

In the words of Nike, "just do it". If I had a dollar for every Dev or Ops engineer that said "*I know branching*", but then developed everything in Master, I would have several dollars. If I had another dollar for every engineer who said "*I know how to build unit tests*" and then didn't, I would have a quite a few dollars more. Add the topic of security in there, and I'd have enough money to buy dinner for us all.

Bottom line, start simply, and improve and grow in your maturity in small increments over time, but start today.