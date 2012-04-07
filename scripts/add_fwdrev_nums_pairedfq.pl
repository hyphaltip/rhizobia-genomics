#!/usr/bin/perl -w
use strict;
# This script will take a file with combined paired end data
# where the read pairs IDs are not ending in /1 or /2
# and add thse.

my $i = 1;
my $last_pair;
while(<>) {
 my $id = $_;
 my ($name,$code) = split(/\s+/,$id);
 if( defined $last_pair ) {
   if( $last_pair ne $name) {
 	warn("Paired end data out of register\n");
	$i = 1;
   } else {
 	printf("%s/%d %s\n",$name,$i,$code);
 	$i++;
 	if( $i > 2) { $i = 1; $last_pair = undef }
	else { $last_pair = $name }
   }
 }
 my $seq = <>;
 my $desc = <>;
 my $qual = <>;
 print $seq,$desc,$qual;
}
