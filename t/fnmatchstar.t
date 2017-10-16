# Copyright (C) 2016-2017 Guido Flohr <guido.flohr@cantanea.com>, 
# all rights reserved.

# This file is distributed under the same terms and conditions as
# Perl itself.

use strict;

use Test::More;

use File::Globstar qw(fnmatchstar);

# Tests are defined as: PATTERN, STRING, EXPECT, TESTNAME
# EXPECT and TESTNAME are optional.
my @tests = (
    ['foobar', 'foobar', 1, 'regular match'],
    ['foobar', 'barbaz', 0, 'regular mismatch'],
    ['*bar', 'foobar', 1, 'asterisk'],
    ['*bar', 'foo/bar', 0, 'slash matched asterisk'],
    ['**/baz', 'foo/bar/baz', 1, 'leading double asterisk'],
    ['foo/**/baz', 'foo/bar/bar/bar/bar/baz', 1, 'double asterisk'],
    ['foo/**', 'foo/bar/bar/bar/bar/baz', 1, 'trailing double asterisk'],
    ['foo/b?r', 'foo/bar', 1, 'question mark'],
    ['foo?bar', 'foo/bar', 0, 'question mark matched slash'],
);

foreach my $test (@tests) {
   my ($pattern, $string, $expect, $name) = @$test;
   my $got = fnmatchstar $pattern, $string;
   ok $got ^ !$expect, $name;
}

ok fnmatchstar 'foobar', 'fOobAr', 1;
ok !fnmatchstar 'foobar', 'fOobAr', 0;

done_testing(2 + scalar @tests);
