#!C:\Perl64\bin\perl

#################################################################################################################################
# Get_freeText_fields.pl
# Gets free text fields (notes) that are required.
#
# Sjaak Peelen
# June 2019
#################################################################################################################################

###################################################################################################
# Set variable if necessary
###################################################################################################

$TS = ',,text,"Form first saved on",,,datetime_seconds_ymd,,,,,,,,,,"@NOW @READONLY"';	# timestamp field
@Surveys = ("socio_demographics","social_environment","medical_history","technology_usage","standardised_assessment_of_personality","lte_sr","lifetime_depression_assessment_self_report","ids_sr","cidi_sf","gad7","wsas","bipq","life_events","audit","audit_fu","csri","depression_medication_adherence","pssuq","technology_assessment_measurement_fast_form","fatigue_severity_scale","sf_36","technological_issues","radar_integration");

# End of variable setting ##########################################################################

# Data Dictionary files

@DDs =`dir /B /S /A-D RADAR*_DataDictionary.csv`; # Subdirectories allowed

# Abort if no Data Dictionary file
if (join('', @DDs) eq '')
{
	print "No Data Dictionary files found!\n";
	exit;
}

foreach $DD (@DDs) # loop over DD files
{
	chop($DD);  # Remove carriage return

	# Open Data Dictionary file and write to array
	open(FILE, '<', $DD);
	@Text = <FILE>;
	close(FILE);
	
	binmode(STDOUT); # Ensure that LF is not replace by CRLF (after open but before I/O!)
	
	$allText = join('',@Text); # Join all lines till one piece of text
	
	@Blocks = split(/\"/,$allText); # Split text on "
	
	$n = 0;
	$nText = "";
	foreach $Block (@Blocks)
	{
		if ($n % 2 == 1) # uneven
		{
			$Block = "blabla"; # Replace text between ""
		}
		
		$nText = $nText.$Block;
		$n++;
	}
	
	@Lines = split(/\n/,$nText); # Create lines

	# New DD file
	@tmp = split(/\\/,$DD);
	$nFN = $tmp[-1]; # Filename

	# Loop over all parameter lines in DD file
	foreach $Line (@Lines)
	{
		@Data = split(/\,/,$Line);

		$Var = $Data[0]; # Get variable
		$Form = $Data[1]; # Get form name
		$Type = $Data[3]; # Get Field Type value
		$Req = $Data[12]; # Get required value
			
		if ($Type eq 'notes' && $Req eq "y")
		{
			print $nFN."\t".$Var."\t".$Form."\n";
		}
	} # next line

} # Next file

exit;