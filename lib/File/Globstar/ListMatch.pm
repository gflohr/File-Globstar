# Copyright (C) 2016-2017 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This file is distributed under the same terms and conditions as
# Perl itself.

# This next lines is here to make Dist::Zilla happy.
# ABSTRACT: Perl Globstar (double asterisk globbing) and utils

package File::Globstar::ListMatch;

use strict;

use Locale::TextDomain qw(File-Globstar);
use Scalar::Util qw(reftype);

use File::Globstar qw(translatestar);

use constant RE_NONE => 0x0;
use constant RE_NEGATED => 0x1;
use constant RE_FULL_MATCH => 0x2;
use constant RE_DIRECTORY => 0x4;

sub new {
    my ($class, $input, %options) = @_;

    my $self = {};
    bless $self, $class;
    $self->{__ignore_case} = delete $options{ignoreCase};
    $self->{__is_exclude} = delete $options{isExclude};
    $self->{__filename} = delete $options{filename};

    if (ref $input) {
        my $type = reftype $input;
        if ('SCALAR' eq $type) {
           $self->_readString($$input);
        } elsif ('ARRAY' eq $type) {
           $self->_readArray($input);
        } else {
           $self->_readFileHandle($input);
        }
    } elsif ("GLOB" eq reftype \$input) {
        $self->_readFileHandle(\$input, );
    } else {
        $self->_readFile($input);
    }

    return $self;
}

sub match {
    my ($self, $path, $is_directory) = @_;

    $is_directory = 1 if $path =~ s{/$}{};
    $path =~ s{^/}{};

    my $basename = $path;
    $basename =~ s{.*/}{};

    my $match;
    foreach my $pattern ($self->patterns) {
        my $type = ref $pattern;
        if ($type & RE_NEGATED) {
            next if !$match;
        } else {
            next if $match;
        }

        my $string = $type & RE_FULL_MATCH ? $path : $basename;
        my $matched_here = $string =~ $$pattern;
        next if !$matched_here;
        if ($type & RE_DIRECTORY) {
            next if !$is_directory;
        }

        $match = $type ^ RE_NEGATED;
    }

    return if !$match;

    return $self;
}

sub patterns {
    return @{shift->{__patterns}};
}

sub _readArray {
    my ($self, $lines) = @_;

    my @patterns;
    $self->{__patterns} = \@patterns;

    my $ignore_case = $self->{__ignoreCase};
    foreach my $line (@$lines) {
        my $blessing = RE_NONE;
        $blessing |= RE_NEGATED if $line =~ s/^!//;
        $blessing |= RE_DIRECTORY if $line =~ s{/$}{};
        $blessing |= RE_FULL_MATCH if $line =~ m{/};
        $line =~ s{^/}{};

        my $transpiled = eval { translatestar $line, $ignore_case };
        if ($@) {
            $transpiled = quotemeta $line;
            if ($ignore_case) {
                push @patterns, \qr/^$transpiled$/i;
            } else {
                push @patterns, \qr/^$transpiled$/;
            }
        } else {
            push @patterns, \$transpiled;
        }

        bless $patterns[-1], $blessing;
    }

    return $self;
}

sub _readString {
    my ($self, $string) = @_;

    my @lines;
    foreach my $line (split /\n/, $string) {
        next if $line =~ /^#/;

        # If the string contains trailing whitespace we have to count the
        # number of backslashes in front of the first whitespace character.
        if ($line =~ s/(\\*)([\x{9}-\x{13} ])[\x{9}-\x{13} ]*$//) {
            my ($bs, $first) = ($1, $2);
            if ($bs) {
                $line .= $bs;

                my $num_bs = $bs =~ y/\\/\\/;

                # If the number of backslashes is odd, the last space was
                # escaped.
                $line .= $first if $num_bs & 1;
            }
        }
        next if '' eq $line;

        push @lines, $line;
    }

    return $self->_readArray(\@lines);
}

sub _readFileHandle {
    my ($self, $fh) = @_;

    my $filename = $self->{__filename};
    $filename = __["in memory string"] if File::Globstar::empty($filename);

    $fh->clearerr;
    my @lines = $fh->getlines;

    die __x("Error reading '{filename}': {error}!\n",
            filename => $filename, error => $!) if $fh->error;
    
    return $self->_readString(join '', @lines);
}

sub _readFile {
    my ($self, $filename) = @_;

    $self->{__filename} = $filename
        if File::Globstar::empty($self->{__filename});

    open my $fh, '<', $filename
        or die __x("Error reading '{filename}': {error}!\n",
                   filename => $filename, error => $!);
    
    return $self->_readFileHandle($fh);
}

1;
