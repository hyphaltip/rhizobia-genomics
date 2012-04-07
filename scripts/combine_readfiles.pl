#!/usr/bin/perl -w
use strict;
use Getopt::Long;

my $strain_file = 'strain_lookup.dat';
# FORMAT OF THIS FILE EXPECTS LAST COLUMN TO BE THE STRAIN NAME
my $strain_column = -1;
my $job_header = <<EOF
#PBS -N combineReads -l nodes=1:ppn=1
module load stajichlab
module load velvet
module load rhizobia-bacteria
EOF
;
my $add_fwdrev_to_readid = 0; # add /1 and /2 to read ids
GetOptions(
	   'hdr:s'       => \$job_header,
	   'd|dir:s'     => \$reads_dir,
	   's|strains:s' => \$strain_file,
	   'column:i'    => \$strain_column,
	   'add|addfwd!' => \$add_fwdrev_to_readod,
);

open(my $fh => $strains) || die $!;
my %strains;
while (<$strains>) {
  my @row = split;
  $strains{$row[$strain_column]}++; # grab strain name from specific column
}

opendir(DIR, $reads_dir) || die "cannot open $reads_dir. $!\n";

# right now this is inflexible code that expects pre-trimmed data and the read
# files to be named like
#  flowcell100_lane1_STRAIN_trim_1.fq
#  flowcell100_lane1_STRAIN_trim_2.fq
#  flowcell100_lane1_STRAIN_trim_single.fq

for my $file (readdir(DIR) ) {
  if ( $file =~ /(\S+)\.fq/ ) {
    my ($stem) = $1;
    if ( $stem =~ /flowcell(\d+)\_lane(\d+)\_(\S+)/ ) {
      my ($fc,$lane,$rest) = ($1,$2,$3);
      if ( $rest =~ /(\S+)_trim_(\S+)/) {
	my ($strain,$direction) = ($1,$2);
	if ( ! exists $strains{$strain} )  {
	  warn("unknown strain $strain, is the parser working?\n");
	} else {
	  $strains{$strain}->{$fc."_".$lane}->{$direction} = $file;
	}
      } else {
	warn("cannot match trim pattern\n");
      }
    } else {
      warn("cannot match pattern of flowcellN_laneN_ in $stem\n");
    }
  }
}


for my $strain ( sort keys %strains) {
  my @ofiles;
  open(my $jobfh => ">$strain.combine.sh") || die $!;
  print $jobfh $jobheader;
  for my $lane ( keys %{$strain{$strain}} ) {
    my $ofile = sprintf("%s.fq",$lane);
    if ( exists $strains{$strain}->{$lane}->{1} &&
	 exists $strains{$strain}->{$lane}->{2} ) {
      printf ( "shuffleSequences_fastq.pl %s %s %s\n",
	       $strains{$strain}->{$lane}->{1},
	       $strains{$strain}->{$lane}->{2},
	       $ofile);
      if ( $add_fwdrev_to_readid ) {
	printf "add_fwdrev_nums_pairedfq.pl $ofile > $ofile.update\n";
	printf "$ofile $ofile.backup # you can remove all the .backup when sure this worked\n";
	printf "mv $ofile.update $ofile\n";
      }
    }
    if ( exists $strains{$strain}->{$lane}->{single} ) {
      printf "cat %s >> %s\n",$strains{$strain}->{$lane}->{single},$ofile;
    }
    push @ofiles, $ofile;
  }
  printf "cat %s >> $strain.fq", join(" ", @ofiles);
}
