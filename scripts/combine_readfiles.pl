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
module load rhizobia-genomics
EOF
;
my $add_fwdrev_to_readid = 0; # add /1 and /2 to read ids
my $reads_dir = 'reads';
GetOptions(
	   'hdr:s'       => \$job_header,
	   'd|dir:s'     => \$reads_dir,
	   's|strains:s' => \$strain_file,
	   'column:i'    => \$strain_column,
	   'add|addfwd!' => \$add_fwdrev_to_readid,
);
if ( ! defined $reads_dir || ! -d $reads_dir ) {
  warn("no read directory provided, using current directory\n");
  $reads_dir = ".";
}

if ( ! -f $strain_file ) {
  die("must have a strain file to insure we are picking up proper strains\n");
}

open(my $fh => $strain_file) || die "cannot open strainfile '$strain_file': $!";
my %strains;
while (<$fh>) {
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
	  warn("unknown strain $strain, is the parser working properly?\n");
	  next;
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
  print $jobfh $job_header;
  for my $lane ( keys %{$strains{$strain}} ) {
    my $ofile = sprintf("%s.fq",$lane);
    if ( exists $strains{$strain}->{$lane}->{1} &&
	 exists $strains{$strain}->{$lane}->{2} ) {
      printf $jobfh ( "shuffleSequences_fastq.pl %s %s %s\n",
	       $strains{$strain}->{$lane}->{1},
	       $strains{$strain}->{$lane}->{2},
	       $ofile);
      if ( $add_fwdrev_to_readid ) {
	printf $jobfh "add_fwdrev_nums_pairedfq.pl $ofile > $ofile.update\n";
	printf $jobfh "$ofile $ofile.backup # you can remove all the .backup when sure this worked\n";
	printf $jobfh "mv $ofile.update $ofile\n";
      }
    }
    if ( exists $strains{$strain}->{$lane}->{single} ) {
      printf $jobfh "cat %s >> %s\n",$strains{$strain}->{$lane}->{single},$ofile;
    }
    push @ofiles, $ofile;
  }
  printf $jobfh "cat %s >> $strain.fq", join(" ", @ofiles);
}
