#!C:\Perl64\bin\perl

#################################################################################################################################
# AddTimestamp.pl
# Adds a a hidden timestamp field on each form
#
# Sjaak Peelen
# June 2019
#################################################################################################################################

###################################################################################################
# Set variable if necessary
###################################################################################################

$TS = ',,text,"Form first saved on",,,datetime_seconds_ymd,,,,,,,,,,"@NOW @READONLY"';	# timestamp field
@Surveys = ("Socio Demographics","Social Environment","Medical History","Technology Usage","Standardised Assessment Of Personality","Lte Sr","Lifetime Depression Assessment Self Report","Ids Sr","Cidi Sf","Gad7","Wsas","Bipq","Life events","Audit","Audit Fu","Csri","Depression Medication Adherence","Pssuq","Technology Assessment Measurement Fast Form","Fatigue Severity Scale","Sf 36","Technological Issues","Radar Integration");

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
	@Lines = <FILE>;
	close(FILE);

	# New DD file
	@tmp = split(/\./,$DD);
	$New_DD = $tmp[0]."_n.".$tmp[1];
	@nFN = split(/\\/,$New_DD);

	open(OUT,'>',$New_DD);
	binmode(OUT); # Ensure that LF is not replace by CRLF (after open but before I/O!)

	# Print header line
	print OUT $Lines[0];

	# Remove first (header) row.
	shift @Lines;

	$prev_form = "";
	$nf = 0;
	$cOdd = 0;
	# Loop over all parameter lines in DD file
	foreach $Line (@Lines)
	{
		if ($Line ne "\n") # Skip empty lines
		{
			@Data = split(/\,/,$Line);
			$Var = $Data[0]; # Get variable
			$Form = $Data[1]; # Get form name
			
			$count = () = $Line =~ /\"/g; # Count double quotes in a line
			
			if ($count % 2 == 0) # Determine if double quote count is even or 0
			{
				if ($Line !~ /\"/g && $cOdd % 2 == 1) # If double quote count is zero " AND previous count is uneven
				{
					print OUT $Line; # Print line as is because follow up line for a parameter
				}
				else
				{
					$cOdd = 0; # Reset count
					
					if ($Form eq $prev_form || $prev_form eq "")
					{
						$NewLine = $Line; # no changes, print already presnet variables (except first variable)
					}
					else
					{
						if ($prev_form ne "radar_integration") # No timestamp parameter for radar_integration form
						{
							$base_form = $prev_form; # New timestamp parameter in principle starts with form name
							
							# Use short form name for timestamp parameters for these forms:
							if ($prev_form eq "adverse_event"){$base_form =	"adv_event";}
							if ($prev_form eq "adverse_reaction"){$base_form = "adv_react_contact";}
							if ($prev_form eq "adverse_reaction_and_missing_data"){$base_form = "adv_react";}
							if ($prev_form eq "beck_depression_inventory_v2"){$base_form = "bdi";}
							if ($prev_form eq "changes_in_ms_treatment_and_medication_adherence"){$base_form = "ch_ms_tr_med";}
							if ($prev_form eq "clinical_information_baseline"){$base_form = "cl_info_bl";}
							if ($prev_form eq "clinical_information_follow_up"){$base_form = "cl_info_fu";}
							if ($prev_form eq "columbia_suicide_severity_rating_scale"){$base_form ="cssrs";}
							if ($prev_form eq "depression_medication_adherence"){$base_form = "dep_med_adh";}
							if ($prev_form eq "fatigue_severity_scale"){$base_form = "fss";}
							if ($prev_form eq "hole_peg_test_msfc"){$base_form = "h_p_t";}
							if ($prev_form eq "lifetime_depression_assessment_self_report"){$base_form = "ldasr";}
							if ($prev_form eq "medical_history"){$base_form = "mh";}
							if ($prev_form eq "ms_medical_history"){$base_form = "ms_mh";}
							if ($prev_form eq "ms_symptomatology_relapse_assessment"){$base_form = "ms_sympt_relap";}
							if ($prev_form eq "expanded_disability_status_scale"){$base_form = "edss";}
							if ($prev_form eq "standardised_assessment_of_personality"){$base_form = "sapas";}
							if ($prev_form eq "symbol_digit_modality_test"){$base_form = "sdm";}
							if ($prev_form eq "time_25_foot_walk_msfc"){$base_form = "t_25_f_w";}
							if ($prev_form eq "tam_fast_form_biovotion"){$base_form = "tam_biovotion";}
							if ($prev_form eq "tam_fast_form_empatica"){$base_form = "tam_empatica";}
							if ($prev_form eq "tam_fast_form_imec"){$base_form = "tam_imec";}
							if ($prev_form eq "tam_fast_form_byteflies"){$base_form = "tam_byteflies";}
							if ($prev_form eq "tam_fast_form_epilog"){$base_form = "tam_epilog";}
							if ($prev_form eq "tam_fast_form_other"){$base_form = "tam_other";}
							if ($prev_form eq "interviewquestionnaire"){$base_form = "interview";}
							if ($prev_form eq "technology_assessment_measurement_fast_form"){$base_form = "tam";}
							
							# New timestamp parameter and first line of next form
							$NewLine = $base_form."_ts,".$prev_form.$TS.chr(10).$Line; # chr(10) = LF
							$nf++; # Timestamp parameter counter
						}
						else
						{
							$NewLine = $Line; # no changes for radar_integration form
						}
					}
					
					# Print new timestamp parameter and first line of next form
					print OUT $NewLine; # Print new line
					
					$prev_form = $Form;
				}
			}
			else # uneven number of double quotes [This part DOES NOT WORK CORRECTLY for forms starting with uneven double quotes!]
			{
				print OUT $Line; # Print line as is
				
				$cOdd++; # Uneven quote line counter
			}
		}
	}
	
	#Print for last line
	if ($Line ne "\n")
	{
		if ($Form ne "radar_integration")
		{
			$base_form = $Form; # New timestamp parameter in principle starts with form name
			
			# Use short form name for timestamp parameters for these forms:
			if ($Form eq "adverse_event"){$base_form = "adv_event";}
			if ($Form eq "adverse_reaction"){$base_form = "adv_react";}
			if ($Form eq "adverse_reaction_and_missing_data"){$base_form = "adv_react";}
			if ($Form eq "beck_depression_inventory_v2"){$base_form = "bdi";}
			if ($Form eq "changes_in_ms_treatment_and_medication_adherence"){$base_form = "ch_ms_tr_med";}
			if ($Form eq "clinical_information_baseline"){$base_form = "cl_info_bl";}
			if ($Form eq "clinical_information_follow_up"){$base_form = "cl_info_fu";}
			if ($Form eq "columbia_suicide_severity_rating_scale"){$base_form ="cssrs";}
			if ($Form eq "depression_medication_adherence"){$base_form = "dep_med_adh";}
			if ($Form eq "fatigue_severity_scale"){$base_form = "fss";}
			if ($Form eq "hole_peg_test_msfc"){$base_form = "h_p_t";}
			if ($Form eq "lifetime_depression_assessment_self_report"){$base_form = "ldasr";}
			if ($Form eq "medical_history"){$base_form = "mh";}
			if ($Form eq "ms_medical_history"){$base_form = "ms_mh";}
			if ($Form eq "ms_symptomatology_relapse_assessment"){$base_form = "ms_sympt_relap";}
			if ($Form eq "expanded_disability_status_scale"){$base_form = "edss";}
			if ($Form eq "standardised_assessment_of_personality"){$base_form = "sapas";}
			if ($Form eq "symbol_digit_modality_test"){$base_form = "sdm";}
			if ($Form eq "time_25_foot_walk_msfc"){$base_form = "t_25_f_w";}
			if ($Form eq "tam_fast_form_biovotion"){$base_form = "tam_biovotion";}
			if ($Form eq "tam_fast_form_empatica"){$base_form = "tam_empatica";}
			if ($Form eq "tam_fast_form_imec"){$base_form = "tam_imec";}
			if ($Form eq "tam_fast_form_byteflies"){$base_form = "tam_byteflies";}
			if ($Form eq "tam_fast_form_epilog"){$base_form = "tam_epilog";}
			if ($Form eq "tam_fast_form_other"){$base_form = "tam_other";}
			if ($Form eq "interviewquestionnaire"){$base_form = "interview";}
			if ($Form eq "technology_assessment_measurement_fast_form"){$base_form = "tam";}
			
			# New timestamp parameter
			$NewLine = $base_form."_ts,".$Form.$TS.chr(10); # chr(10) = LF
			$nf++; # Timestamp parameter counter
			
			# Print new timestamp parameter
			print OUT $NewLine;
		}
	}

	# Close new DD file
	close(OUT);
	
	print $nFN[$#nFN]." :\tTimestamp field added to ".$nf." forms\n";
	
} # Next file

exit;