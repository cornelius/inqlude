# Inqlude manifest format

Inqlude uses manifest files to capture meta data of Qt libraries for further
inspection and processing. The meta data is stored as JSON formatted files in
the file system. This document describes the format.

## Directory structure

All data is stored in a manifest directory. It can have an arbitrary name and
path, but by default the inqlude command line tool assumes the path
~/.inqlude/manifests.

The manifest directory is under version control by git.

Each library reprented in the Inqlude system has its own sub-directory in the
manifest directory. The name of the sub-directory is the name of the library.
See there for more information about its specification and how it's used.

Each version of the library has its own manifest file in the library
sub-directory. The name of the manifest file is of the format:

    <name>.<release_date>.manifest

The name and release_date parts have to be identical to the corresponding
attributes stored in the manifest file with the same names.

## Manifest file format

The manifest files are formatted as JSON and contain a list of structured
attributes describing the library and the specific version represented by the
concrete file.

These are the attributes:

### schema_version

Version number of the schema used in this manifest

This is used to make expectations of tools and processing explicit and adapt
to schema changes.

If the schema is changed in a way incompatible with processing tools, the
schema version number has to be increased.

This document specifies schema version 1.

*schema_version is a mandatory attribute*

### name

Name of the library

The name of the library has to be a lower-case string with only alphanumeric
characters. It has to be identical with the name part of the manifest file names
and the name of the directory where the manifest is stored in the manifest
repository.

As a convention Qt bindings to other libraries are named with the name of the
other library and a "-qt" suffix. For example the Qt bindings to PackageKit
are named "packagekit-qt" in Inqlude.

It's used as internal handle by the tools and shows up where it
needs to be processed by software, e.g. as an identifier as paramezer of the
command line tool or as part of the URL on the web site. The name has to be
identical with the value of the name attribute of the manifest files
representing the different versions of the library.

*name is a mandatory attribute*

### release_date

Date, when the version was released

*release_date is a mandatory attribute*

### version

Version of the release

*version is a mandatory attribute*

### summary

One-line summary describing the library

This is the main description of the library used in summary lists etc.

*summary is a mandatory attribute*

### urls

List of URLs relevant to the library

All URLs are represented as a key specifying the type of the URL and the
actual URL itself. Arbitrary types can be defined. Some types are used for
specific purposes and get special treatment.

The following types are recognized:

* "homepage": Home page of the library. This is the main URL used as entry point
  for looking up information about the library. All manifests should contain
  a homepage URL.
* "download": Download area where the source code of the library can be
  downloaded. This is not the download of the specific version of the library.
  This is described in the packages section.
* "vcs": URL of the source code repository where the library is developed.
* "tutorial": URL to tutorial-style documentation how to use the library.
* "api_docs": URL to reference documentation of the API of the library.
* "description_source": If the description text is taken from another source
  this URL points to the source.
* "announcement": Link to release announcement
* "custom": Array of pairs of title and URL of custom links

*the homepage is a mandatory url attribute*

### licenses

List of licenses under which the library can be used

Array of identifier strings of the software licenses under which the library
can be used. This can be a free-form string, but there is a list of predefined
strings for the most often used licenses:

* "LGPLv2.1+": Lesser GNU Public License 2.1 or later
* "GPLv2+": GNU Public License v2 or later
* "GPLv3+": GNU Public License v3 or later

*there must be at least one license*

### description

Full description of the library

The description is a text describing the library. It can be of arbitrary length.
No special formatting is supported other than using newlines to start a new
paragraph.

*description is a mandatory attribute*

### authors

List of authors

Array of author names and email addresses. The standard email address format
"John Doe <jdoe@example.com>" is used.

### maturity

Maturity of the release

This attribute is a flag for identifying the maturity of the release. It's used
to identify stable, test, and development versions.

The flag has to be one of the following identifiers:

* "stable": for stable releases ready for production use
* "beta": for pre-releases of stable versions used for gathering feedback, not
  recommended for production use
* "alpha": preview releases, not suitable for production use

*maturity is a mandatory attribute*

### platforms

List of supported platforms

Array of strings identifying the platforms on which the library runs.

Supported values are:

* "Linux"
* "Windows"
* "Mac"

*there must be at least one platform*

### packages

List of packages of the release

This section contains a list of data on packaged versions of the library, which
can be used to run it on specific systems. This includes the source code
release, but also platform-specific binary packages.

For each type of package there is a type-specific format to describe the
package. The following types are supported:

#### source

This is the source code of the release. It has one URL to the file, which
can be used to download the code.

*source is a mandatory package attribute*

#### openSUSE

openSUSE binary packages. For each version of openSUSE there is a separate
entry.

Each entry contains the package_name, repository, and source_rpm attributes.
The repository contains an url and a name sub-attribute.
