# Change log of Inqlude

## Version 0.10.0

* Add `linux` attribute for `packages` section for generic links to generic Linux binaries

## Version 0.9.0

* Put out progress when creating release manifests
* Prototype for new layout of the website as alternative view template
* Better error when view templates directory does not exist
* Show topics in view
* Add validation for display_name attribute
* Gracefully fail in --version when Qt is not installed

## Version 0.8.0

* Add topic attribute to manifest specification and adapt validator to allow topic attribute as an optional parameter. The validator reports missing topics as a warning for each manifest which does not have a topic attribute, but not fail.
As a result, libraries can be categorized under multiple topics. The validator reports an error for each manifest with invalid topics attribute. As a result, the list of topics is kept small and typographical errors are prevented.
* Initialize distro only when needed. This should remove "distro not recognized" warnings in cases where the distro is not needed
* Clarify documentation of `vcs` URL

## Version 0.7.4

* Support links to OS X packages in manifests
* Fix search and comments on created web page

## Version 0.7.3

* Fix exit code when `inqlude verify` exits with errors
* Fix checking for branches in `inqlude review` command
* Settle on "OS X" as the canonical name

## Version 0.7.2

* `create_kde_frameworks` command:

    * Read summary for KDE Frameworks from metainfo.yml
    * Use API docs as home page for KDE Frameworks
    * Only parse actual checkouts of KDE Frameworks

* `release_kde_frameworks` command:

    * Support `--offline` option for

## Version 0.7.1

* `create_kde_frameworks` command:

    Generate links from name

    The standard links for frameworks such as home page, mailing list,
    git repository always follow the same scheme. So instead of parsing
    them from the README.md generate them from the name of the framework.

    This is more flexible, allows to change all links at once, and is
    compatible with the frameworks where the links have been removed from
    the READMEs.

* Accept windows and ubuntu as package category
* Implement `inqlude download`
* Generate inqlude-all.json on Inqlude website

## Version 0.7.0

* First alpha release
