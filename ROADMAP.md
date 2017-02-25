# Inqlude roadmap

Inqlude has come along nicely over the years. It has a comprehensive listing
of more or less all third party Qt libraries and displays them on the
[Inqlude web site](https://inqlude.org). The
[inqlude command line client](https://github.com/cornelius/inqlude) provides
the tooling to create the web site. It also has some support for listing,
downloading, and installing libraries targeted towards Qt developers using
libraries as end users. While the web site is pretty mature and stable, the
command line client is more experimental and not very complete.

The main entry point for managing the data of libraries on Inqlude is the
[inqlude-data](https://github.com/cornelius/inqlude-data) git repository. It
contains meta data for all libraries listed on Inqlude in
[JSON format](https://github.com/cornelius/inqlude/blob/master/manifest-format.md).
This data is also used for
[integration](https://github.com/cornelius/inqlude/blob/master/accessing-inqlude-data.md)
with other tools and services. The format of the data and the way how it's
accessed is fairly stable, but it's not set in stone yet, and there are a few
open ends.

Currently we declare Inqlude as alpha to reflect that there are no guarantees
in terms of APIs, functionality, or formats. This might not be the most accurate
declaration as it actually has been quite stable over years now.

So how do we move forward with all this? Here is an outline of the roadmap with
corresponding release milestones. It is tracked on the
[Inqlude issue tracker](https://github.com/cornelius/inqlude/issues).

## 0.12 (Beta) (ready for contributors of meta data, schema stable)

The next step is to actually declare the data format as stable. This will also
be the point where we go from alpha to beta. With this Inqlude is officially
ready for people working on meta data. To achieve it there are a few issues
which need to be fixed, such as stricter checking of meta data values for
licenses and platforms.

As part of this step we'll also consolidate all project tracking using issues
in the [Inqlude project](https://github.com/cornelius/inqlude) on GitHub. This
has proven to be the most effective and accepted way of dealing with issues,
planning, and providing transparency to the community.

Progress on this step will be reflected in releases of the Inqlude command line
tool as Ruby gem using further 0.x releases. Release 0.12 is the next release
in this series and is supposed to have everything required for the beta status.

## 1.0 (ready for end users of the web site)

The next big step is to finish up the web site to make it usable for end users.
There is not much missing from this. With this step we'll declare Inqlude stable
and mark this by the 1.0 release of the Ruby gem. This makes Inqlude officially
ready for end users using Qt libraries via the Inqlude web site.

## 2.0 (ready for end users of the command line tool)

There are a lot of possible features around the command line client to help
users to find, install, and manage Qt libraries. This can be done in concert
with native package managers or as generic support based on source code. It
also opens potential for integration with other tools or services.

This is the future big step to improve Inqlude, making it ready for end users
of the command line tool. This might take a while. The highest value is already
provided by having the meta data of all third party Qt libraries available as
machine-readable JSON as well as human-readable web site. So progress on the
version 2.0 will depend on how it is picked up by contributors and how valuable
these possible future features turn out to users.

The path ahead might also change quite a bit of version 2.0 depending on what
we learn over the course of the releases leading towards this future milestone.

Input and feedback is always appreciated.
