# File-Globstar

This library implements globbing with support for "**" in Perl.

Two consecutive asterisks stand for all files and directories in the
current directory and all of its descendants.

See [File::Globstar](https://github.com/gflohr/File-Globstar/blob/master/lib/File/Globstar.pod) for more information.

## Installation

Via CPAN:

```
$ perl -MCPAN -e install 'File::Globstar'
```

From source:

```
$ perl Build.PL
Created MYMETA.yml and MYMETA.json
Creating new 'Build' script for 'File-Globstar' version '0.1'
$ ./Build
$ ./Build install
```

From source with "make":

```
$ git clone https://github.com/gflohr/File-Globstar.git
$ cd File-Globstar
$ perl Makefile.PL
$ make
$ make install
```

## Bugs

Please report bugs at
[https://github.com/gflohr/File-Globstar/issues](https://github.com/gflohr/File-Globstar/issues)

## Copyright

Copyright (C) 2016-2017, Guido Flohr, <guido.flohr@cantanea.com>,
all rights reserved.

