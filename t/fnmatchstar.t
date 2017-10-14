# Copyright (C) 2016-2017 Guido Flohr <guido.flohr@cantanea.com>, 
# all rights reserved.

# This file is distributed under the same terms and conditions as
# Perl itself.

use strict;

use Test::More tests => 1;

use File::Globstar qw(fnmatchstar);

ok fnmatchstar('regular', 'regular'), 'regular match';

