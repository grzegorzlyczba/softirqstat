#!/usr/bin/env perl
use strict;
use Getopt::Std;

my %stats;
my @names;
my $delay = shift(@ARGV) || 1;
my $probes = shift(@ARGV) || 0;
my $probe = 0;

sub usage {
    print "Usage: $0 [delay [count]]\n";
    exit 0;
};

sub print_header {
    foreach (@names) {
        printf "%".(length($_) > 6 ? length($_) : 6)."s ", $_;
    }
    print "\n";

}

sub check_args {
    if (not $delay =~ m/\d+/ or not $probes =~ m/\d+/) {
        usage();
    }
}

sub main {
    while ( 1 ) {
        open F, "</proc/softirqs" or die "error: $!";
        while (<F>) {
            if (m/([A-Z]+):\s+(.*)$/) {
                my $name = $1;
                my $sum = 0;
                my @t = split(/\s+/, $2);
                map { $sum = $sum + $_ } @t;
                if (defined($stats{$name})) {
                    printf "%".(length($name) > 6 ? length($name) : 6)."s ", ($sum - $stats{$name});
                } else {
                    printf "%".(length($name) > 6 ? length($name) : 6)."s ", $name;
                    push(@names, $name);
                }
                $stats{$name} = $sum;
            }
        }
        close F;
        print "\n";
        if (++$probe > $probes and $probes) {
            exit 0;
        }
        if (not $probe % 5) {
            print_header();
        }
        select(undef, undef, undef, $delay);
    }
}

check_args();
main();
