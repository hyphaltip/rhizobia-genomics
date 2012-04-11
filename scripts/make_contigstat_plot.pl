#!/usr/bin/perl -w
use strict;

my $dir = shift || ".";
my $name = shift || 'assembly';
opendir(DIR, $dir) || die $!;
# process output from running
# faLen < assembly | stats > assembly.contigstats

my %dat;
for my $file ( readdir(DIR) ) {
  if ( $file =~ /_(\d+)\.contigstats$/ ) {
    my ($kmer) = $1;
    open(my $fh => "$dir/$file") || die $!;
    while (<$fh>) {
      if ( /(\S+)\s+=\s+(\d+(?:\.\d+)?)/) {
	$dat{$kmer}->{$1} = $2;
      }
    }
  }
}

open(my $outfh => ">$name.stats") || die $!;
print $outfh join("\t", qw(KMER CONTIGS LENGTH MAX N50 MIN)), "\n";
for my $kmer( sort { $a <=> $b} keys %dat ) {
  print $outfh join("\t", $kmer, map { $dat{$kmer}->{$_} } 
		    qw(N SUM MAX N50 MIN)),"\n";
}
open(my $R => ">$name\_stats.R") || die $!;
print $R <<EOF
pdf("$name\_stats.pdf")
tab <- read.table("$name.stats",header=T,sep="\t")
plot(tab\$KMER,tab\$N50,main="N50",xlab="kmer",ylab="N50")
plot(tab\$KMER,tab\$CONTIGS,main="Number of Contigs",xlab="kmer",ylab="Contig count")
plot(tab\$KMER,tab\$MAX,main="Max Contigsize",xlab="kmer",ylab="Max contig (bp)")
plot(tab\$KMER,tab\$SUM,main="Total assembly size",xlab="kmer",ylab="Assembly size (bp)")
EOF
;
`R --no-save < $name\_stats.R`;
