# Accessing Inqlude data

The data of the Inqlude library archive is maintained in the
[inqlude-data](https://github.com/cornelius/inqlude-data) repository. It
includes the meta data for all libraries collected in Inqlude. There are various
ways to access this data from a client. They are described in this document.

## Using the git repository

The most direct way is to clone the [meta data git repository](https://github.com/cornelius/inqlude-data) and work on the
data locally. The repository contains a set of directories with manifests
following the [Inqlude manifest specification](https://github.com/cornelius/inqlude/blob/master/manifest-format.md).
The data can be updated with standard git commands such as `git pull`.

## All data in one JSON

There is a JSON file available at http://inqlude.org/inqlude-all.json, which
contains the data for the latest version of all libraries. This is the most
convenient way, if you just want to have the current data.

The file is updated whenever the data in the inqlude-data git repository is
updated.

The file is simply wrapping the manifests in a JSON array:

```json
[
  {
    "$schema": "http://inqlude.org/schema/release-manifest-v1#",
    "name": "attica",
    "release_date": "2013-06-12",
    "version": "0.4.2",
    ...
  },
  {
    "$schema": "http://inqlude.org/schema/release-manifest-v1#",
    "name": "avahi-qt",
    "release_date": "2012-02-15",
    "version": "0.6.31",
    ...
  }
]
```

## Using a client

There currently are two clients to access the Inqlude data.

The preferred way to access the data as a user of libraries is the native
command line client written in C++. Its source is maintained as the
[inqlude-client project](https://projects.kde.org/projects/playground/sdk/inqlude-client).

The other client is the [Inqlude admin tool](https://github.com/cornelius/inqlude).
It provides commands to access the meta data. It also has commands to manipulate
and verify meta data.
