# Copyright (C) 2016-2017 Guido Flohr <guido.flohr@cantanea.com>,
# all rights reserved.

# This file is distributed under the same terms and conditions as
# Perl itself.

# This next lines is here to make Dist::Zilla happy.
# ABSTRACT: Perl Globstar (double asterisk globbing) and utils

package File::Globstar;

use strict;

use File::Glob qw(bsd_glob);
use Scalar::Util qw(reftype);
use File::Find;

use base 'Exporter';
use vars qw(@EXPORT_OK);
@EXPORT_OK = qw(globstar);

sub _globstar($$;$);

sub empty($) {
    my ($what) = @_;

    return if defined $what && length $what;

    return 1;
}

sub _find_files($) {
    my ($directory) = @_;

    my $empty = empty $directory;
    $directory = '.' if $empty;

    my @hits;
    File::Find::find sub {
        return if -d $_;
        return if '.' eq substr $_, 0, 1;
        push @hits, $File::Find::name;
    }, $directory;

    if ($empty) {
        @hits = map { substr $_, 2 } @hits;
    }

    return @hits;
}

sub _find_directories($) {
    my ($directory) = @_;

    my $empty = empty $directory;
    $directory = '.' if $empty;

    my @hits;
    File::Find::find sub {
        return if !-d $_;
        return if '.' eq substr $_, 0, 1;
        push @hits, $File::Find::name;
    }, $directory;

    if ($empty) {
        @hits = map { substr $_, 2 } @hits;
    }

    return @hits;
}

sub _find_all($) {
    my ($directory) = @_;

    my $empty = empty $directory;
    $directory = '.' if $empty;

    my @hits;
    File::Find::find sub {
        return if '.' eq substr $_, 0, 1;
        push @hits, $File::Find::name;
    }, $directory;

    if ($empty) {
        @hits = map { substr $_, 2 } @hits;
    }

    return @hits;
}

sub _globstar($$;$) {
    my ($pattern, $directory, $flags) = @_;

    $directory = '' if !defined $directory;
    $pattern = $_ if !@_;

    if ('**' eq $pattern) {
        return _find_all $directory;
    } elsif ('**/' eq $pattern) {
        return map { $_ . '/' } _find_directories $directory;
    } elsif ($pattern =~ s{^\*\*/}{}) {
        my %found_files;
        foreach my $directory ('', _find_directories $directory) {
            foreach my $file (_globstar $pattern, $directory, $flags) {
                $found_files{$file} = 1;
            }
        }
        return keys %found_files;
    }

    my $current = $directory;
 
    # This is a quotemeta() that does not escape the slash and the
    # colon.  Escaped slashes confuse bsd_glob() and escaping colons
    # may make a full port to Windows harder.
    $current =~ s{([\x00-\x2e\x3b-\x40\x5b-\x60\x7b-\x7f])}{\\$1}g;
    if ($directory ne '' && '/' ne substr $directory, -1, 1) {
        $current .= '/';
    }
    while ($pattern =~ s/(.)//s) {
        if ($1 eq '\\') {
            $pattern =~ s/(..?)//s;
            $current .= $1;
        } elsif ('/' eq $1 && $pattern =~ s{^\*\*/}{}) {
            $current .= '/';

            # Expand until here.
            my @directories = bsd_glob $current, $flags;

            # And search in every subdirectory;
            my %found_dirs;
            foreach my $directory (@directories) {
                $found_dirs{$directory} = 1;
                foreach my $subdirectory (_find_directories $directory) {
                    $found_dirs{$subdirectory . '/'} = 1;
                }
            }

            if ('' eq $pattern) {
                my %found_subdirs;
                foreach my $directory (keys %found_dirs) {
                    $found_subdirs{$directory} = 1;
                    foreach my $subdirectory (_find_directories $directory) {
                        $found_subdirs{$subdirectory . '/'} = 1;
                    }
                }
                return keys %found_subdirs;
            }
            my %found_files;
            foreach my $directory (keys %found_dirs) {
                foreach my $hit (_globstar $pattern, $directory, $flags) {
                    $found_files{$hit} = 1;
                }
            }
            return keys %found_files;
        } elsif ('**' eq $pattern) {
            my %found_files;
            foreach my $directory (bsd_glob $current, $flags) {
                $found_files{$directory . '/'} = 1;
                foreach my $file (_find_all $directory) {
                    $found_files{$file} = 1;
                }
            }
            return keys %found_files;
        } else {
            $current .= $1;
        }
    }

    # Pattern without globstar.  Just return the normal expansion.
    return bsd_glob $current, $flags;
}

sub globstar($;$) {
    my ($pattern, $flags) = @_;

    if (!ref $pattern || 'ARRAY' ne reftype $pattern) {
        return _globstar $pattern, '', $flags;
    }

    my %found;
    foreach (@$pattern) {
        my $p = $_;
        if ($p =~ s/^![ \x09-\x0d]*//) {
            my @found = _globstar $p, '', $flags;
            delete $found{$_} foreach _globstar $p, '', $flags;
        } else {
            $found{$_} = 1 foreach _globstar $p, '', $flags;
        }
    }

    return keys %found;
}

1;

