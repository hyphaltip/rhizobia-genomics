#!/usr/bin/perl -w
use strict;
use File::Temp qw(tempdir);
use File::Spec;
use File::Copy qw(copy);
use IO::String;

# need to have 'module loaded'
# module load bwa

my $tempbase = '/dev/shm';
my $sample_size = 100_000; # sample 50,000 reads, should be enough
my $pairedfile = shift || die "need a fastq paired file";
my $contigasm = shift || die "need a contig assembly";
my $tmpdir = tempdir(CLEANUP => 1, DIR => $tempbase);

my (undef,undef,$ctgbase) = File::Spec->splitpath($contigasm);
my $destasm = File::Spec->catfile($tmpdir,$ctgbase);
warn($tmpdir,"\n");

copy($contigasm, $destasm);
system("bwa index $destasm 2> /dev/null");
open(my $fh => $pairedfile ) || die $!;
open(my $fh1 => ">$tmpdir/reads.1.fq") || die $!;
open(my $fh2 => ">$tmpdir/reads.2.fq") || die $!;

my @handles = ($fh1,$fh2);
my $h = 0;
my $i = 0;
while(<$fh>) {
    my $hand = $handles[$h];
    print $hand $_;
    for ( 1..3 ) {
	my $l = <$fh>;
	print $hand $l;
    }
    $h = 1-$h; # flip flop
    last if $h == 0 && $i++ > $sample_size;
}

system("bwa aln -t 8 -f $tmpdir/reads.1.sai $destasm $tmpdir/reads.1.fq 2> /dev/null");
system("bwa aln -t 8 -f $tmpdir/reads.2.sai $destasm $tmpdir/reads.2.fq 2> /dev/null");
my $results = `bwa sampe $destasm $tmpdir/reads.1.sai $tmpdir/reads.2.sai $tmpdir/reads.2.fq $tmpdir/reads.2.fq > $tmpdir/reads.sam`;
my $io = IO::String->new($results);
while(<$io>) {
    if ( /inferred external/ ) {
	my @row = split;
	my $se = pop @row;
	pop @row;
	my $insert = pop @row;	    
	print "insert sizes $insert +- $se\n";
    }
}
