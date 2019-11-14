#!C:\Perl64\bin\perl

#################################################################################################################################
# EditRequired.pl
# Edits "Required" variables in a REDCap Data Dictionary based on a lookup file, either parameter based or form based.
# All files need to be in the same directory as the pl script.
# If some FIELDS contain a LF, please first run Remove_LF_DD.pl (However, the "binmode(FILE)" statement should make this step redundant.)
#
# Sjaak Peelen
# October 2018
#################################################################################################################################


###################################################################################################
# Set variables if necessary
###################################################################################################

$Dlm = "\t";														# Delimiter character of reference file
$AllReq = 'false';													# 'true' if all need to be set to Required, otherwise 'false'
$FormReq = 'true';													# 'true' if complete form needs to be set to Required, otherwise 'false'
$VarCol = 0;														# Column number (starting at 0) for field name/variable
$ReqCol = 1;														# Column number (starting at 0) for Required indicator
$FormCol = 0;														# Column number (starting at 0) for form name
$RefFile =`dir /B Forms.txt`;										# Reference file
# End of variable setting ##########################################################################

#######################################################################################################
# Reference file
#######################################################################################################

if (lc($AllReq) eq 'false') # No reference file needed if all need to be set to Required
{
	# Remove carriage return
	chop($RefFile);

	# Abort if no reference file
	if ($RefFile eq '')
	{
		print "Reference file, ".$RefFile." not found!\n";
		exit;
	}

	# Open Reference file, write to array
	open(FILE, $RefFile);
	@REF = <FILE>;
	close(FILE);

	# Remove first (header) row.
	shift @REF;

	# Loop over Codebook lines
	$i=0;
	foreach $RefLine (@REF)
	{	

		chop($RefLine);  #Remove carriage return
		
		# Determine columns
		@RefColumns = split(/$Dlm/,$RefLine);
		
		if (lc($FormReq) eq 'false') # If required fields are set by parameter
		{
			# Write Required values to hash
			$ReqValues{$RefColumns[$VarCol]} = $RefColumns[$ReqCol];
			$IDs[$i] = $RefColumns[$VarCol]; # Write IDs to array
			print $IDs[$i]."-\n";
		}
		else # If required field are set by Form name
		{
			$ReqForms{$RefColumns[$FormCol]} = $RefColumns[$ReqCol];
		}
		$i++;
	}
}
### End of reading Reference file ###########################################################################

#######################################################################################################
# Data Dictionary file
#######################################################################################################

@DDs =`dir /B RADAR*.csv`;

# Abort if no Data Dictionary file
if (join('', @DDs) eq '')
{
	print "No Data Dictionary files found!\n";
	exit;
}

print "Required value changed for:\n";

foreach $DD (@DDs)
{
	chop($DD);  #Remove carriage return

	# Open Data Dictionary file
	open(FILE, $DD);
	binmode(FILE); # Ensure that LF is not replace by CRLF (after open but before I/O!)
	
	@Lines = <FILE>;
	close(FILE);

	# New DD file
	@tmp = split(/\./,$DD);
	$New_DD = $tmp[0]."_n.".$tmp[1];

	open(OUT,'>',$New_DD);
	binmode(OUT); # Ensure that LF is not replace by CRLF (after open but before I/O!)

	# Print header line
	print OUT $Lines[0];

	# Remove first (header) row.
	shift @Lines;

	$b_change = 'false'; # Boolean for changes
	$Row = 1;
	# Loop over all lines in DD file
	foreach $Line (@Lines)
	{	
		$Row++;
		
		#chop($Line); # Remove carriage return
		@Data = split(/\,/,$Line);
		$Var = $Data[0]; # Get variable
		$Form = $Data[1]; # Get form name
		
		### Determine required field position #############################
		$numCommas = 0; # Reset comma counter
		for ($n = 0; $n <= length($Line); $n++)
		{
			# Skip any comma's IN a field
			if (substr($Line,$n,1) eq '"')
			{
				$n++;
				until(substr($Line,$n,1) eq '"' || $n == length($Line))
				{
					$n++;
				}
			}
			
			if (substr($Line,$n,1) eq ',')
			{
				$numCommas++; #Count comma's
			}
		}
		
		$LastPos = length($Line)-1; # Last position

		if (substr($Line,$LastPos,1) eq '"') # if last character is "
		{
			# Loop over all characters starting from before-last position
			for ($p=$LastPos-1; $p>=0; $p--)
			{
				if (substr($Line,$p,1) eq '"')
				{
					$p--; # reduce character counter
					last; # exit for loop
				}
			}
		}
		else # No " as last character
		{
			$p = $LastPos;
		}
		
		$C_count = 0; # Reset comma counter
		for ($n=$p; $n>=0; $n--) # Reverse loop
		{
			if (substr($Line,$n,1) eq ',')
			{
				$C_count++; # If comma encountered, lower character position
			}
			
			if ($C_count == 5) # If 5 comma's counted
			{
				$R_pos = $n; # Set the position where "Required value should be written"
				last;
			}
		}
		### End determine required field position #############################
		
		### Checks ############################################################
		# Check for incorrect records
		if ($numCommas != 17)
		{
			print "Incorrect record at row ".$Row.".\n";
		}
		
		if ($AllReq eq 'false')
		{
			if ($FormReq eq 'false')
			{
				$b_ID = 'false';
				# Check if ID exists in reference file
				foreach $ID (@IDs)
				{
					if ($ID eq $Var)
					{
						$b_ID = 'true';
					}
				}
				
				if ($b_ID eq 'false')
				{
					print "[".$Var."] not found in reference file at line ".$Row."\n";
				}
			}
		}
		### End checks ############################################################
		
		if (lc($AllReq) eq 'true')
		{
			$ReqValue = 'y'; # If all fields need to be set to Required
		}
		else
		{
			if (lc($FormReq) eq 'false')
			{
				$ReqValue = $ReqValues{$Var};
			}
			else # If required field set per form
			{
				$ReqValue = $ReqForms{$Form};
			}
		}
		
		if (lc(substr($Line,$R_pos-1,1)) eq 'y') # Check if Required value in data file is y
		{
			$CurrentRValue = substr($Line,$R_pos-1,1); # Get Required value from data file
			if (lc($FormReq) eq 'false' || lc($AllReq) eq 'true') # If set per parameter
			{
				$NewLine = substr($Line,0,$R_pos-1).$ReqValue.substr($Line,$R_pos); # New line
			}
			else # If set by form name and existing value is 'y'
			{
				$NewLine = $Line;
				$ReqValue = $CurrentRValue;
			}
		}
		else # Current Req value = ""
		{
			$CurrentRValue = ""; # Get Required value from data file
			if ($Form eq "radar_integration") # Skip Radar Integration form
			{
				$NewLine = $Line;
			}
			else # All other forms
			{
				$NewLine = substr($Line,0,$R_pos).$ReqValue.substr($Line,$R_pos); # New line
			}
		}
		
		print OUT $NewLine; # Print new line with adapted Required value
		
		if (lc($ReqValue) ne lc($CurrentRValue)) # If change in Req value
		{
			print $DD." : ".$Var." : ".$Form." --> ".$ReqValue."\n";
			$b_change = 'true';
		}

	}

	if ($b_change eq 'false') # Nothing updated
	{
		print $DD." --> None\n";
	}

	close(OUT);
	
} # Next file

exit;