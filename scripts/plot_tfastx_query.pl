#!/usr/bin/perl -w
use strict;
use File::Spec;

my $expected_PID_ref = 95; # expect at least 95% identity --really 99 but some leeway
my $ref = 'NC_004463.TFASTX';
my $strainfastx = shift || die "provide a strain TFASTX file to compare\n";

my %genes;
my %ref_positions;
# first read in the positions found for all the symbiosis genes
# which came from the TFASTX output of the proteins against USDA110 genome
open(my $fh => $ref) || die $!;
while(<$fh>) {
    # this is th FASTA -m 8c output which is the same as 
    # BLAST+ -outformat 6 or BLAST -mformat 8
    next if /^#/; 
    my ($query,$hit,$percent_id,$idents,$mismatch,$gapopenings,
	$qstart,$qend, $hstart,$hend, $evalue, $bits) = split;
    # for the ref genome we only want the 1st hit (and we assumed
    # there is only one place for it that is really worth grabbing)
    
    next if exists $genes{$query};

    if( $percent_id < $expected_PID_ref) {
	warn("percent ID for best hit of $query is only $percent_id\n");
	# a warning when PID is lower than we would have expected
    }
    $genes{$query}++;
    $ref_positions{$query} = [$hstart,$hend,$hstart < $hend ? '+' : '-'];
}
my (undef,undef,$strainfile) = File::Spec->splitpath($strainfastx);
my ($strainname) = split(/\./,$strainfile);
open($fh => $strainfastx) || die $!;
my %strain_positions;
while(<$fh>) {
    # this is th FASTA -m 8c output which is the same as 
    # BLAST+ -outformat 6 or BLAST -mformat 8
    next if /^#/; 
    my ($query,$hit,$percent_id,$idents,$mismatch,$gapopenings,
	$qstart,$qend, $hstart,$hend, $evalue, $bits) = split;
    # for now, take only the best (top) hit
    next if exists $strain_positions{$query};
    $strain_positions{$query} = [$hstart,$hend,
				 $hstart < $hend ? '+' : '-',$hit,$evalue];
}

open(my $outfh => ">$strainname.symloc.dat") || die $!;
# the ref positions will be the x-axis in our plots

# sort the ref genes by their position on the (1) chromosome 
my @gene_order = sort { $ref_positions{$a}->[0] <=> $ref_positions{$b}->[0] } keys %ref_positions;

print $outfh join("\t", qw(GENE REF_START REF_END STRAIN_START STRAIN_END STRAIN_CONTIG STRAIN_EVALUE)),"\n";

for my $gene (@gene_order ) {
    # print NA if the gene was not found in the search against the strain
    print $outfh join("\t", $gene, @{$ref_positions{$gene}},
		      @{$strain_positions{$gene} || [qw(NA NA NA NA)]}),"\n";
}
