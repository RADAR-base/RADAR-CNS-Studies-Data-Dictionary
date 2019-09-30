#!C:\Perl64\bin\perl

#######################################################################
#Edit_quotes.pl
# This script removes first and last "
#
# Sjaak Peelen
# July 2018
#######################################################################

#
# Get Data Dictionary file
#
$DataDict =`dir /B RADARMDDCIBERs1_DataDictionary_2018-07-10a.csv`;

# Remove carriage return
chop($DataDict);

# Abort if no DD or DDs
if ($DataDict eq '' || $DataDict =~ /\n/ )
{
	print "No or multiple Data Dictionary files. No processing!\n";
	exit;
}

# Open Data Dictionary, write to variable
open(FILE, $DataDict);
@DD = <FILE>;
close(FILE);

# Create new codebook name
@tmp=split(/\./,$DataDict);
$NewDD = $tmp[0]."c.".$tmp[1];

# Open new codebook file
open(OUT,'>',$NewDD);
binmode(OUT); # Ensure that LF is not replace by CRLF (after open but before I/O!)

# Print new codebook
foreach $Line (@DD)
{
	$Line =~ s/^\"//s; # Remove first "
	$Line =~ s/\t$//s; # Remove last tab
	$Line =~ s/\"$//s; # Remove last "
	$Line =~ s/\"\"/\"/g; # Replace "" by "
	print OUT $Line;
}

close(OUT);

exit;