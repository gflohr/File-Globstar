#!perl

BEGIN {
  unless ($ENV{AUTHOR_TESTING}) {
    print qq{1..0 # SKIP these tests are for testing by the author\n};
    exit
  }
}


use common::sense;
use warnings;

use Test::Perl::Critic (-profile => "perlcritic.rc") x!! -e "perlcritic.rc";
all_critic_ok();
