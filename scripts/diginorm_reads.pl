#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use File::Spec;

my $jobdir = 'jobs';

GetOptions(
	   'j|jobdir:s' => \$jobdir,
	   );

my $dir = shift || die "no dir";

mkdir($jobdir) unless -d $jobdir;
my $job_header = <<EOF
#PBS -N diginorm -l nodes=1:ppn=1 -q highmem
module load stajichlab
module load khmer
module load stajichlab-python
EOF
;
$dir = File::Spec->rel2abs($dir);
opendir(DIR, $dir)|| die "$dir: $!";

for my $file ( readdir(DIR) ) {
  if ( $file =~ /(\S+)\.fq(\.gz)?/) {
    my $strain = $1;
    open(my $jobfh => ">$jobdir/$strain.diginorm.sh") || die $!;
    print $jobfh $job_header;
    print $jobfh "cd $dir\n";
    printf $jobfh "normalize-by-median.py -q -C 20 -k 20 -N 4 -x 8e8 --savehash $strain.kh $file\n";
    printf $jobfh "filter-abund.py $strain.kh $file.keep\n";
    printf $jobfh "normalize-by-median.py -q -C 5 -k 20 -N 4 -x 4e8 $file.keep.abundfilt\n";
    printf $jobfh "python \$KHMERROOT/sandbox/strip-and-split-for-assembly.py $file.keep.abundfilt.keep\n";
    close($jobfh);
  }
}
