This directory contains tools and data to deal with topics of libraries in
Inqlude. Topics are used to categorize libraries. Each library has at least one
topic, but can have more than one. There should be no topics with less than 4
libraries and there should not be more than 20 topics.

The file `topics.csv` contains the suggested assignment of topics to libraries.
This data needs to be reflected in the manifest of `inqlude-data` to become
effective.

There is a command line tool to print a summary of the topics `list-topics`. It
comes with test. Run `rspec .` in this directory to run them.
