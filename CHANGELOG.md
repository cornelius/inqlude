# Change log of Inqlude

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
