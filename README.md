# Inqlude - the Qt library archive

[![Gem Version](https://badge.fury.io/rb/inqlude.svg)](https://badge.fury.io/rb/inqlude)
[![Build Status](https://travis-ci.org/cornelius/inqlude.svg?branch=master)](https://travis-ci.org/cornelius/inqlude)
[![Dependency Status](https://dependencyci.com/github/cornelius/inqlude/badge)](https://dependencyci.com/github/cornelius/inqlude)
[![Code Climate](https://codeclimate.com/github/cornelius/inqlude/badges/gpa.svg)](https://codeclimate.com/github/cornelius/inqlude)

## Overview

Inqlude is a tool to handle Qt based libraries. It provides developers using Qt
with an easy way to find, install, and use libraries, in particular 3rd party
libraries. A public version of the library runs at http://inqlude.org.

Inqlude comes as a Ruby gem, which can easily be installed, and provides a
command line interface to handle Qt libraries in a similar way as Ruby gems.
There are commands to list available libraries and installed libraries, and
more.

Libraries are described by manifest files, which are maintained in a separate
git repository. Inqlude integrates with this git repository and uses it as the
list of available gems. One way to contribute information about libraries to the
archive is to simply provide patches to the manifest repository. The repository
can be found at https://github.com/cornelius/inqlude-data.

Inqlude also integrates with native package managers. If the meta information is
available, the libraries are transparently handled by installing packages with
the native tools.

There also is an option to generate an HTML overview of all available libraries.
This can be hosted or used locally.

## KDE Frameworks

The KDE Frameworks provide more than fifty libraries, which can be used to
write Qt application. Inqlude has some special tooling to deal with the data
from KDE Frameworks

To checkout all frameworks from source, you can use

```bash
kde-checkout-list.pl --component=frameworks --clone
```

from the
[kde-dev-scripts repository](https://quickgit.kde.org/?p=kde-dev-scripts.git).
This creates a `frameworks` directory with a checkout of all git repositories
part of [KDE Frameworks](https://projects.kde.org/projects/frameworks).

You can update the generic meta data of the frameworks in Inqlude with

```bash
inqlude create_kde_frameworks <frameworks-checkout-dir> <inqlude-data-dir>
```

To create release manifests for a KDE Frameworks release runs

```bash
inqlude release_kde_frameworks <release_date> <version>
```

## License

Inqlude is licensed under the GPL.

## Contact

If you have questions or comments, please contact Cornelius Schumacher
<schumacher@kde.org> or write to the
[Inqlude mailing list](mailto:inqlude@kde.org).
