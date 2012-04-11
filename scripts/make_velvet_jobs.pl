#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Spec;
my $jobdir = 'jobs';
my $queue = 'js';
my $min = 17;
my $max = 71;
GetOptions(
	   'j|jobs:s' => \$jobdir,
	   'min:i'    => \$min,
	   'max:i'    => \$max,
	   'q|queue:s'=> \$queue,
	  );

my $dir = shift || die "need a directory";
$dir = File::Spec->rel2abs($dir);
opendir(INDIR,$dir) || die $!;
my %strains;
for my $file (readdir(INDIR) ) {
  if ( $file =~ /(\S+)\.fq(?:.gz)?\.keep\.abundfilt\.keep\.(se|pe)/) {
    my ($strain,$kind) = ($1,$2);
    mkdir("$dir/$strain") unless -d "$dir/$strain";
    warn "file is $file, strains is $strain, kind is $kind\n";
    $strains{$strain}->{$kind} = File::Spec->catfile($dir,$file);
  }
}
for my $strain ( keys %strains ) {
  open(my $jobfh => ">$jobdir/$strain.velveth.sh") || die $!;
  my $files;
  if ( exists $strains{$strain}->{pe} ) {
    $files = sprintf("-fasta -shortPaired %s",$strains{$strain}->{pe});
  }
  if ( exists $strains{$strain}->{se} ) {
    $files .= sprintf(" -fasta -short %s",$strains{$strain}->{se});
  }
  print $jobfh <<EOF
#PBS -N $strain.velh -l nodes=1:ppn=8,mem=36gb -q $queue
#PBS -j oe
module load stajichlab
module load velvet
cd $dir/$strain
velveth asm $min,$max,2 -create_binary $files
EOF
;
  open($jobfh => ">$jobdir/$strain.velvetg.sh") || die $!;
  print $jobfh <<EOF
#PBS -N $strain.velg -l nodes=1:ppn=8,mem=36gb -q $queue
#PBS -j oe
module load stajichlab
module load velvet
cd $dir/$strain
for asmdir in asm_??
do
 velvetg \$asmdir -exp_cov auto -cov_cutoff auto -ins_length 350 -min_contig_lgth 500
 done

EOF
    ;
}
