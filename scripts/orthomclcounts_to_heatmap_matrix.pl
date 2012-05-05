#!/usr/bin/perl -w
use strict;
use warnings;

my $header = <>;
while (<>) {
  my @row= split(/\t/,$_);
  my ($family,@counts) = @row;
  my $desc = pop @counts;
  my %n;
  for my $c ( @counts ) {
    $n{$c}++;
  }
  if ( keys %n == 1 ) {
    # skipping lines where the counts are all the same
    next;
  }
  print;
}
