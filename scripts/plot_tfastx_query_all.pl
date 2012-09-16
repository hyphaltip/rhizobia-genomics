#!/usr/bin/perl -w
use strict;
use File::Spec;

my $expected_PID_ref = 95; # expect at least 95% identity --really 99 but some leeway
my $ref = 'NC_004463.TFASTX';
my $dir = shift || ".";
opendir(DIR, $dir) || die $!;

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
    $ref_positions{$query} = [$hstart,$hend,$hstart < $hend ? '+' : '-',];
}
my %strain_positions;
for my $strainfastx ( readdir(DIR) ) {
    next unless $strainfastx =~ /(\S+)\.TFASTX/;
    my ($strainname) = $1;
    next if $strainname eq 'NC_004463';
    open($fh => "$dir/$strainfastx") || die $!;

    while(<$fh>) {
	# this is th FASTA -m 8c output which is the same as 
	# BLAST+ -outformat 6 or BLAST -mformat 8
	next if /^#/; 
	my ($query,$hit,$percent_id,$idents,$mismatch,$gapopenings,
	    $qstart,$qend, $hstart,$hend, $evalue, $bits) = split;
	# for now, take only the best (top) hit
	next if exists $strain_positions{$query};
	$strain_positions{$strainname}->{$query} = [$hstart,$hend,
						$hstart < $hend ? '+' : '-',
						$hit,$evalue];
    }
}
my @strains = sort keys %strain_positions;
open(my $outfh => ">combined.symloc.dat") || die $!;

# sort the ref genes by their position on the (1) chromosome 
my @gene_order = sort { $ref_positions{$a}->[0] <=> $ref_positions{$b}->[0] } keys %ref_positions;

print $outfh join("\t", qw(GENE REF_START REF_END REF_STRAND),
		  (map { (sprintf("STR%s_START",$_),
			 sprintf("STR%s_END",$_),
			  sprintf("STR%s_STRAND",$_),
			  sprintf("STR%s_CONTIG",$_),
			  sprintf("STR%s_EVALUE",$_))
		   } @strains)),"\n";

for my $gene (@gene_order ) {
    # print NA if the gene was not found in the search against the strain
    
    print $outfh join("\t", $gene, @{$ref_positions{$gene}},
		      map { @{$strain_positions{$_}->{$gene} || 
				  [qw(NA NA NA NA NA)]} } @strains), "\n";
}
