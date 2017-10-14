# Copyright (C) 2016-2017 Guido Flohr <guido.flohr@cantanea.com>, 
# all rights reserved.

# This file is distributed under the same terms and conditions as
# Perl itself.

use strict;

use Test::More;

use File::Globstar qw(fnmatchstar);

# Testcs are defined as: PATTERN, STRING, EXPECT, TESTNAME
# EXPECT and TESTNAME are optional.
my @tests = (
    ['foobar', 'foobar', 1, 'regular match'],
    ['foobar', 'barbaz', 0, 'regular mismatch'],
    ['*bar', 'foobar', 1, 'asterisk'],
    ['*bar', 'foo/bar', 0, 'slash matched asterisk'],
    ['**/baz', 'foo/bar/baz', 1, 'leading double asterisk'],
);

foreach my $test (@tests) {
   my ($pattern, $string, $expect, $name) = @$test;
   my $got = fnmatchstar $pattern, $string;
   ok $got ^ !$expect, $name;
}

done_testing(scalar @tests);
