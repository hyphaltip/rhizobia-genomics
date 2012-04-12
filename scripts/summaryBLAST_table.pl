#!/usr/bin/perl -w
use strict;
use warnings;
use Bio::SearchIO;
use Getopt::Long;
my $debug = 0;

GetOptions('v|verbose!' => \$debug);

my $dir = shift || die "provide directory with BLASTP files";
opendir(DIR,$dir) || die "cannot open dir $dir: $!\n";
my %table;
my @strains;
for my $f ( sort readdir(DIR) ) {
  next unless $f =~ /-vs-(\S+)\.BLASTP/;
  my $strain = $1;
  push @strains, $strain;
  warn("Strain is $strain\n") if $debug;
  my $in = Bio::SearchIO->new(-format => 'blasttable', -file =>"$dir/$f");
  while( my $result = $in->next_result ) {
    while( my $hit = $result->next_hit ) {
      while( my $hsp = $hit->next_hsp ) {
	if ( $hsp->percent_identity >= 50 ) {
	  # store the %ID and convert this to only 2 FP decimals 
	  # to make formatting easier
	  if ( exists $table{$result->query_name}->{$strain} )  {
	    # already saw an HSP, we want the one with the BEST %ID for now
	    # so compare the two
	    next if $table{$result->query_name}->{$strain} > $hsp->percent_identity;
	    # if the value of the current stored is greater than the one we are reading
	    # we don't want to update the value
	  }
	  $table{$result->query_name}->{$strain} = sprintf("%.2f", $hsp->percent_identity);
	}
      }
    }
  }
}

print join("\t", qw(GENE), @strains),"\n";

for my $query ( sort keys %table ) {
  print join("\t", $query, map { $table{$query}->{$_} || 0 } @strains), "\n";
}
