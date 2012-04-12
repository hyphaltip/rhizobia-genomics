#!/usr/bin/perl -w
use strict;
use Bio::SearchIO;

my $dir = shift || die "provide directory with BLASTP files";
opendir(DIR,$dir) || die "cannot open dir $dir: $!\n";
my %table;
my @strains;
for my $f ( sort readdir(DIR) ) {
  next unless $f =~ /-vs-(\S+)\.BLASTP/;
  my $strain = $1;
  push @strains, $strain;
  warn("Strain is $strain\n");
  my $in = Bio::SearchIO->new(-format => 'blasttable', -file =>"$dir/$f");
  while( my $result = $in->next_result ) {
    while( my $hit = $result->next_hit ) {
      while( my $hsp = $hit->next_hsp ) {
	if ( $hsp->percent_identity >= 50 ) {
	  $table{$result->query_name}->{$strain} = $hsp->percent_identity;
	}
      }
    }
  }
}

print join("\t", qw(GENE), @strains),"\n";

for my $query ( sort keys %table ) {
  print join("\t", $query, map { $table{$query}->{$_} || 0 } @strains), "\n";
}
