# Enterprise Linux lab assignment

This document contains some background information about this assignment, prerequisite knowledge, etc.

## Learning goals

The most important learning goals of this assignment are to:

- being able to set up common network services in Linux using a configuration management system (Ansible)
- focus on the automation of repeatable system administration tasks ("Infrastructure as Code")
- adopt an attitude of systematic (automated) testing of your infrastructure ("Test Driven Infrastructure")
- being able to find documentation that is applicable to your own specific environment

## Prerequisite knowledge

Students are expected to:

- have basic experience with Linux, i.e. users, file permissions, Bash scripting
- know how to use Git (add, commit, push, pull, etc.)
- be able to install and configure software on your own computer (be it either Windows, MacOS, or Linux)

## Completing the assignments

To complete the assignments, this is the general process:

- First, read the assignment.
- Look at the provided external resources in each assignment, consisting of manuals, screencasts, etc. Make yourself acquainted with the contents relevant for the assignment.
- Create a document for your report, based on the provided template (in the `reports/` directory). See below on guidelines for your reports.
- Start working on the assignment, and complete your report. Validate your solution by running the acceptance tests. Commit all changes in your Git repository!
- In order to be graded for finishing the assignment, you need to provide all the following deliverables:
    - Complete and updated source code in your personal Git repository;
    - Complete lab report, also committed to your Git repository;
    - Live demo of the completed system, including running the acceptance tests.

To actually get started, go to the [first assignment](00-development-environment.md).

## Lab reports

When you are learning a new skill, it is important to keep notes for later reference. With every assignment, you should write a personal report on how you tackled it. What resources have you used (besides the ones provided in the assignment)? What problems have you encountered and how exactly did you solve them? Which commands did you use for troubleshooting issues? What new insights did you gain by completing the assignment?

The "native" format for documentation on Github (and similar online Git repositories like Bitbucket and Gitlab) is Markdown. It is a structured text format that can be easily rendered to a nicely formatted web page. Make yourself familiar with the format and use it for writing your reports. Be sure to look at your report on Github to see if it's formatted correctly! Markdown is easy, but you do need to apply the formatting syntax correctly. The following links should get you started:

- John Gruber, Markdown, <https://daringfireball.net/projects/markdown/>
- Mastering Markdown, <https://guides.github.com/features/mastering-markdown/>
- Writing on Github, <https://help.github.com/categories/writing-on-github/>

Lab reports are stored in the `report/` directory. It already contains a template that you can reuse. First, fill out the basic information that has to be present in each report. For each assignment, copy the template to a new file named `NN-report.md`, and add it to Git. `NN` is the number of the assignment.

While you're learning about Linux, Vagrant, Ansible, etc. you will regularly encounter new commands. Memorizing them all is pretty hard (if not impossible), and constantly having to look them up on the Internet will make you lose a lot of time. To help you commit these new commands to your long term memory, *keep a cheat sheet*. The same goes for checklists and procedures for repeated system administration tasks or troubleshooting. An example is already provided in the `report/` directory, you are expected to add to it yourself throughout the semester. You can take a look at <https://github.com/bertvv/cheat-sheets> for some more extended examples and inspiration (be sure to read the README!) It is futile to reuse someone else's cheat sheets, or to copy/paste long lists of commands into your cheat sheet. You won't be able to remember new commands that way and it makes your document less clear. Commands that you have memorized at a certain point can be removed. Keep a clear overview by structuring the document into sections by topic. If your cheat sheet grows in size, you can split it up into separate documents.

## Hard- and software requirements

To work on these assignments, it is essential to have a sufficiently powerful computer. A few recommendations:

- Processor: Intel i7 or equivalent (an i5 may be sufficient)
- Memory: 8 GiB RAM (4 GiB may be sufficient for most individual assignments, but probably not for running the entire network)
- Hard disk: 40 GB free hard disk space
- Operating system: you should be able to complete these assignments on either Linux, MacOS, or Windows.

The software you need is listed below. Ensure you have installed the latest stable version. If you have already installed some of the applications below, upgrade them!

- A **good** text editor: e.g. [Sublime Text](https://www.sublimetext.com/), [Notepad++](https://notepad-plus-plus.org/), Vim, etc.
    - **Windows notepad is not a good text editor!** It has no syntax coloring, doesn't do indenting, etc. **Do not use it!**
    - **Remark**! Configure your editor so text indents with **spaces** instead of tab characters and use indentation length of 2.
    - You may optionally want to install a Markdown editor that immediately shows the rendered HTML. E.g. [MarkdownPad](http://markdownpad.com/), [Texts](http://www.texts.io/), etc.
- [VirtualBox](https://virtualbox.org/), desktop virtualization software
- [Vagrant](http://vagrantup.com/), an automation tool for setting up virtual machines from the command line and provision them with scripts or a configuration management system
- A client for [Git](https://git-scm.com/downloads). Optionally, you can install a graphical Git client, e.g. [Github Desktop](https://desktop.github.com/) or [SourceTree](https://www.sourcetreeapp.com/).
- A Bash shell. On Windows, a Bash shell is provided by Git. You should specify during installation that you want to include the Bash shell.
- The [Ansible](https://docs.ansible.com/ansible/intro_installation.html) configuration management system. This only applies to users of Linux or MacOS. Ansible is not supported on Windows, it will be run through a workaround.
- The virtual machines we're going to set up are based on CentOS Linux. However, it is not necessary to download installation ISO's. The Vagrant environment automates this.
