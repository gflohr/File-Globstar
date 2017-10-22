# Copyright (C) 2016-2017 Guido Flohr <guido.flohr@cantanea.com>, 
# all rights reserved.

# This file is distributed under the same terms and conditions as
# Perl itself.

use strict;

use Test::More;

ok require File::Globstar::ListMatch;

my ($matcher, $input, @patterns);

$input = [qw (Tom Dick Harry)];
$matcher = File::Globstar::ListMatch->new($input);
is_deeply [$matcher->patterns], [
    qr{^Tom$},
    qr{^Dick$},
    qr{^Harry$},
], 'array input';

$input = <<EOF;
FooBar
BarBaz
EOF
$matcher = File::Globstar::ListMatch->new(\$input);
is_deeply [$matcher->patterns], [
    qr{^FooBar$},
    qr{^BarBaz$}
], 'string input';

done_testing;