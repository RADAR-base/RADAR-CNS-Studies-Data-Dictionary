#!C:\Perl64\bin\perl

#######################################################################
# Remove_LF_DD.pl
# This script remove LF's (\n) and or CR's (\r) from Data Dictionary for values between ""
# Wile keeping the ""
# Removes empty records
# Removes | if last character between ""
#
# Sjaak Peelen
# February 2019
#######################################################################

#
# Get Data Dictionary file
#
$DataDict =`dir /B RADARaRMT_DataDictionary_Danish.csv`;

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

# Split on "
$DD=join('',@DD);
$DD =~ s/,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n//g; # replace empty records
@Data=split(/"/,$DD);

$j=1;
for ($i=0; $i<=$#Data; $i++)
{	
	# Every second block
	if ($j==2)
	{
		# Remove \n (LF)
		$Data[$i] =~s/\n//g;
		# Remove \r (CR)
		$Data[$i] =~s/\r//g;
		# Remove | if last character between ""
		$Data[$i] =~s/\|$//;
		# Add ""
		$Data[$i] = "\"".$Data[$i]."\"";
		$j=1;
	}
	else
	{
		$j++;
	}
}

# Create new codebook name
@tmp=split(/\./,$DataDict);
$NewDD = $tmp[0]."c.".$tmp[1];

# Open new codebook file
open(OUT,'>',$NewDD);

# Print new codebook
foreach $Line (@Data)
{
	print OUT $Line;
}

close(OUT);

exit;