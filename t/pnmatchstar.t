# Copyright (C) 2016-2017 Guido Flohr <guido.flohr@cantanea.com>, 
# all rights reserved.

# This file is distributed under the same terms and conditions as
# Perl itself.

use strict;

use Test::More;

use File::Globstar qw(pnmatchstar translatestar);

use constant RE_NONE => 0x0;
use constant RE_NEGATED => 0x1;
use constant RE_FULL_MATCH => 0x2;
use constant RE_DIRECTORY => 0x4;

ok  pnmatchstar('*.p[lm]', 'src/simple/hello.pl');
ok !pnmatchstar('!*.p[lm]', 'src/simple/hello.pl');
ok  pnmatchstar('src/', 'src/simple/hello.pl');
ok  pnmatchstar('src/', 'src');
ok  pnmatchstar('src/', 'src/');
ok  pnmatchstar('src/', 'src', isDirectory => 1);
ok !pnmatchstar('lib/File', 'lib/File/Globstar/ListMatch.pm');
ok !pnmatchstar('File/Globstar/ListMatch.pm, lib/File/Globstar/ListMatch.pm');

my %files = (
    'Globstar.pm' => 1,
    'Globstar.pod' => undef,
    'lib/File/Globstar.pm' => undef,
    '!lib/File/Globstar.pm' => 1,
    'src/File/Globstar.pm' => 1,
);

my $re = translatestar 'src/**/*.p[lm]', pathMode => 1;
foreach my $file (keys %files) {
    is pnmatchstar($re, $file), $files{$file}; 
}

done_testing;
