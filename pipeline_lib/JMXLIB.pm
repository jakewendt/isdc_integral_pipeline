
package JMXLIB;

=head1 NAME

I<JMXLIB.pm> - library used by nrtqla, conssa and consssa

=head1 SYNOPSIS

use I<JMXLIB.pm>;

=head1 DESCRIPTION

=item

=head1 SUBROUTINES

=over

=cut

use strict;
use ISDCPipeline;
use ISDCLIB;
use UnixLIB;

sub JMXLIB::JSA;

$| = 1;

=item B<JSA> ( %att )

=cut

sub JSA {
	my %att = @_;
	$att{proctype}      = "scw" unless $att{proctype} =~ /mosaic/;	#	either "scw" or "mosaic"
	$att{IC_Group}      = "../../idx/ic/ic_master_file.fits[1]" unless ( $att{IC_Group} );

	my $proc            = &ProcStep();
	my $ogDOL           = "og_jmx$att{jemxnum}.fits[GROUPING]";
	#	default values ( consssa scw as well as conssa scw )	Used in both &JSA and &Scw
	my $startLevel      = "COR";
	my $endLevel        = "LCR";
	my $skipLevels      = "BKG,SPE";
#	my $BKG_simulated   = "n";		#	060925 - j_scripts 4.6
	my $GTI_TimeFormat  = "IJD";
	my $LCR_vignCorr    = "yes";
	my $SPE_vignCorr    = "yes";
	my $nChanBins       = "5";							#	conssa
	my $chanLow         = "30  58 119 160 197";	#	conssa
	my $chanHigh        = "57 118 159 196 235";	#	conssa
	my $cdelt           = "0.03";
	my $radiusSelect    = "5.";
	my $viewTime        = "N";
	my $viewVar         = "N";
	my $usrCat          = "";
#	my $skyImagesOut    = "RAW_I,RAW_R,VARIA,RESID,RES+S";
#	my $skyImagesOut    = "RAW_R,VARIA,RESID,RES+S";	#	used until 061013
	my $skyImagesOut    = "RECTI,VARIA,RESID,RECON";	#	061013 - Jake - SCREW 1918 - some new stuff for newer jemx
	my $radiusMin       = "0.0 2.4";
	my $radiusMax       = "2.4 6.6";
#	my $mapSelect       = "RAW_RECT";
	my $mapSelect       = "RECTI";	#	061013 - Jake - SCREW 1918 - some new stuff for newer jemx
	my $diameter        = "20.";
	my $BIN_I_rowSelect = "";

	&Error ( "*******     ERROR:   JMXLIB::JSA doesn't recognize given JEMX number $att{jemxnum}!\n" )
		unless ( $att{jemxnum} =~ /^(1|2)$/ );

	if ( $ENV{PROCESS_NAME} =~ /cssscw/ ) {
		$nChanBins       = "8";
		$chanLow         = "30 46  71 129 179 224  45 128";
		$chanHigh        = "45 70 128 178 223 235 127 210";
	}


	if ( ( $ENV{PROCESS_NAME} =~ /cssscw/ ) && ( $att{proctype} =~ /scw/ ) ) {
		#	use the defaults
		$radiusMax       = "2.4 5.5";

		$usrCat    = "jmx$att{jemxnum}_catalog.fits";
		
		&ISDCPipeline::PipelineStep (
			"step"           => "$proc - cat_extract",
			"program_name"   => "cat_extract",
			"par_refCat"     => "$ENV{ISDC_REF_CAT}"."[JEMX_FLAG==1]",
			"par_instrument" => "JMX"."$att{jemxnum}",
			"par_inGRP"      => "",
			"par_outGRP"     => "$ogDOL",
			"par_outCat"     => "$usrCat(JMX$att{jemxnum}-SRCL-CAT.tpl)",
			"par_outExt"     => "JMX$att{jemxnum}-SRCL-CAT",
			"par_date"       => "-1.",
			"par_radiusMin"  => "$radiusMin",	#	060110
			"par_radiusMax"  => "$radiusMax",	#	060110
			"par_fluxDef"    => "0",				#	060110
			"par_fluxMin"    => "",
			"par_fluxMax"    => "",
			"par_class"      => "",
			"par_clobber"    => "yes",
			);

		#	&ISDCPipeline::PipelineStep uses PARFILES to create PFILES, but does not reset it.
		#	If anything is run after this before another &ISDCPipeline::PipelineStep is run,
		#	it will use this new temp PFILES, which won't exist.
		#	Perhaps it would be better to not use &ISDCPipeline::PipelineStep here?
		my $original_pfiles   = $ENV{PFILES};
		my $original_parfiles = $ENV{PARFILES};
		$ENV{PARFILES} = "/tmp/$$-fcalcpfile/";
		system ( "mkdir $ENV{PARFILES}" );

		&ISDCPipeline::PipelineStep (			#	there are other parameters for this exec
			"step"           => "$proc - fcalc",
			"program_name"   => "fcalc",
			"par_infile"     => "$usrCat",
			"par_outfile"    => "$usrCat",
			"par_clname"     => "FLAG",
			"par_expr"       => "1",
			"par_clobber"    => "yes",
			);

		system ( "/bin/rm -rf $ENV{PARFILES}" );
		$ENV{PARFILES} = $original_parfiles;
		$ENV{PFILES}   = $original_pfiles;
		$usrCat       .= "[1]";		#	because it will need to be a DOL to jemx_science_analysis
	}
	elsif ( ( $ENV{PROCESS_NAME} =~ /cssscw/ ) && ( $att{proctype} =~ /mosaic/ ) ) {
		$startLevel      = "IMA2";
		$endLevel        = "IMA2";
#		$mapSelect       = "RES+SRC";
		$mapSelect       = "RECON";	#	061013 - Jake - SCREW 1918 - newer stuff for newer jemx
		$radiusSelect    = "4.8";
		$diameter        = "-1";
#		$skyImagesOut    = "RAW_I,RAW_R,VARIA,RESID,RES+S";
		$skyImagesOut    = "RAWIN,RECTI,VARIA,RESID,RECON";	#	061013 - Jake - SCREW 1918 - newer stuff for newer jemx
	}
	elsif ( $ENV{PROCESS_NAME} =~ /nqlobs/ ) {
		$startLevel      = "IMA2";
		$endLevel        = "IMA2";
		$GTI_TimeFormat  = "OBT";
		$LCR_vignCorr    = "no";
		$SPE_vignCorr    = "no";
		$nChanBins       = "2";
		$chanLow         =  "46 129";
		$chanHigh        = "128 211";
		$BIN_I_rowSelect = "&& STATUS < 16";
	}
	elsif ( $ENV{PROCESS_NAME} =~ /nqlscw/ ) {
		$skipLevels      = "BKG";
		$endLevel        = "IMA";
		$GTI_TimeFormat  = "OBT";
		$LCR_vignCorr    = "no";
		$SPE_vignCorr    = "no";
		$nChanBins       = "2";
		$chanLow         =  "46 129";
		$chanHigh        = "128 211";
		$BIN_I_rowSelect = "&& STATUS < 16";
	}
	elsif ( $ENV{PROCESS_NAME} =~ /csaob1/ ) {
		$startLevel      = "IMA2";
		$endLevel        = "IMA2";
		$skipLevels      = "";
		$cdelt           = "0.02";
		$radiusSelect    = "4.8";
		$viewTime        = "Y";
		$viewVar         = "Y";
	}
	elsif ( $ENV{PROCESS_NAME} =~ /csasw1/ ) {
		$ogDOL = &ISDCLIB::FindDirVers ( "scw/$att{scwid}" )."/swg_jmx$att{jemxnum}.fits[GROUPING]";
		$cdelt           = "0.02";
		$radiusSelect    = "4.8";
	}
	else {
		&Error ( "No match found for PROCESS_NAME: $ENV{PROCESS_NAME}; proctype: $att{proctype}\n" );
	}

	#####################################################################################

	if ( $ENV{REDO_CORRECTION} ) {
		&Message ( "Redoing Correction step." );
		$startLevel     = "COR";
		$endLevel       = "DEAD";
	}

	if ( $att{proctype} =~ /scw/ ) {
		#	Check to ensure that only 1 child in OG
		my $numScwInOG = &ISDCLIB::ChildrenIn ( $ogDOL, "GNRL-SCWG-GRP-IDX" );
		&Error ( "Not 1 child in $ogDOL: $numScwInOG" ) unless ( $numScwInOG == 1 );
	}

	print "\n========================================================================\n";
	print "#######     DEBUG:  ISDC_REF_CAT is $ENV{ISDC_REF_CAT}.\n";

	my ($retval,@result) = &ISDCPipeline::PipelineStep(
		"step"                      => "$proc - JMX $att{proctype}",
		"program_name"              => "jemx_science_analysis",
		"par_ogDOL"                 => "$ogDOL",
		"par_jemxNum"               => "$att{jemxnum}",
		"par_startLevel"            => "$startLevel",
		"par_endLevel"              => "$endLevel",
		"par_skipLevels"            => "$skipLevels",
		"par_nChanBins"             => "$nChanBins",
		"par_chanHigh"              => "$chanHigh",
		"par_chanLow"               => "$chanLow",
#		"par_BKG_simulated"         => "$BKG_simulated",		#	060925 - j_scripts 4.6
		"par_CAT_I_radiusMin"       => "$radiusMin",		#	" 0 2.4",
		"par_CAT_I_radiusMax"       => "$radiusMax",		#	"2.4 6.6",
		"par_CAT_I_refCat"          => "$ENV{ISDC_REF_CAT}",
		"par_CAT_I_usrCat"          => "$usrCat",
		"par_GTI_TimeFormat"        => "$GTI_TimeFormat",
		"par_IC_Alias"              => "$ENV{IC_ALIAS}",
		"par_IC_Group"              => "$att{IC_Group}",
		"par_IMA_skyImagesOut"      => "$skyImagesOut", #	"RAW_I,RAW_R,VARIA,RESID,RES+S";
		"par_IMA2_cdelt"            => "$cdelt",
		"par_IMA2_diameter"         => "$diameter",		#	"20.",
		"par_IMA2_mapSelect"        => "$mapSelect",		#	"RAW_RECT",
		"par_IMA2_radiusSelect"     => "$radiusSelect",
		"par_IMA2_viewIntens"       => "Y",
		"par_IMA2_viewSig"          => "Y",
		"par_IMA2_viewTime"         => "$viewTime",
		"par_IMA2_viewVar"          => "$viewVar",
		"par_LCR_vignCorr"          => "$LCR_vignCorr",
		"par_SPE_vignCorr"          => "$SPE_vignCorr",
		"par_BIN_I_rowSelect"       => "$BIN_I_rowSelect",

		"par_BIN_I_backCorr"        => "n",
		"par_BIN_I_evtType"         => "-1",
		"par_BIN_I_gtiNames"        => "",
		"par_BIN_I_shdRes"          => "",
		"par_BIN_I_shdType"         => "2",
		"par_BIN_S_evtType"         => "-1",
		"par_BIN_S_rowSelectEvts"   => "",
		"par_BIN_S_rowSelectSpec"   => "",
		"par_BIN_T_evtType"         => "-1",
		"par_BIN_T_rowSelect"       => "",
		"par_CAT_I_class"           => "",
		"par_CAT_I_date"            => "-1",
		"par_CAT_I_fluxDef"         => "0",
		"par_CAT_I_fluxMax"         => "",
		"par_CAT_I_fluxMin"         => "",
		"par_COR_gainHist"          => "",
		"par_COR_gainModel"         => "2",
		"par_COR_outputExists"      => "n",
		"par_DEAD_outputExists"     => "n",
		"par_GTI_Accuracy"          => "any",
		"par_GTI_BTI_Dol"           => "",
		"par_GTI_BTI_Names"         => "",
		"par_GTI_MergedName"        => "MERGED",
		"par_GTI_attTolerance"      => "0.5",
		"par_GTI_gtiJemxNames"      => "",
		"par_GTI_gtiScNames"        => "",
		"par_GTI_gtiUser"           => "",
		"par_GTI_limitTable"        => "",
		"par_IMA2_srcFileDOL"       => "",
		"par_IMA2_srcattach"        => "y",
		"par_IMA2_srcselect"        => "",
		"par_IMA_distFuzz"          => "0.0",
		"par_IMA_gridNum"           => "0",
		"par_IMA_relDist"           => "-0.05",
		"par_IMA_searchRad"         => "0.0",
		"par_IMA_fluxLimit"         => "0.000",
		"par_LCR_bgrMethod"         => "0",
		"par_LCR_evtType"           => "-1",
		"par_LCR_fluxScaling"       => "2",
		"par_LCR_precisionLevel"    => "20",
		"par_LCR_rowSelect"         => "",
		"par_LCR_skipHotSpot"       => "n",
		"par_LCR_skipNearDeadAnode" => "y",
		"par_LCR_tAccuracy"         => "3",
		"par_LCR_timeStep"          => "-1",
		"par_LCR_useRaDec"          => "y",
		"par_SPE_bgrMethod"         => "0",
		"par_SPE_evtType"           => "-1",
		"par_SPE_fluxScaling"       => "2",
		"par_SPE_precisionLevel"    => "20",
		"par_SPE_rowSelect"         => "",
		"par_SPE_skipHotSpot"       => "n",
		"par_SPE_skipNearDeadAnode" => "y",
		"par_SPE_tAccuracy"         => "3",
		"par_SPE_timeStep"          => "0.0",
		"par_SPE_useRaDec"          => "y",
		"par_chatter"               => "2",
		"par_clobber"               => "y",
		"par_ignoreScwErrors"       => "n",
		"par_instMod"               => "",
		"par_nPhaseBins"            => "0",
		"par_osimData"              => "n",
		"par_phaseBins"             => "",
		"par_radiusLimit"           => "105.0",
		"par_response"              => "",
		"par_timeStart"             => "-1.0",
		"par_timeStop"              => "-1.0",
		"par_IMA2_DECcenter"        => "0.",
		"par_IMA2_RAcenter"         => "-1",
		"par_IMA2_emaxSelect"       => "80.",
		"par_IMA2_eminSelect"       => "0.",
		"par_IMA2_outfile"          => "J_MOSAIC",
		"par_IMA_bkgShdDOL"         => "",
		"par_IMA_detAccLimit"       => "16384",
		"par_IMA_detSigSingle"      => "12.0",
		"par_IMA_dolBPL"            => "",
		"par_IMA_edgeEnhanceFactor" => "1.0",
		"par_IMA_hotPixelLimit"     => "4.0",
		"par_IMA_interactionDepth"  => "10.0",
		"par_IMA_loopLimitPeak"     => "0.025",
		"par_IMA_makeNewBPL"        => "no",
		"par_IMA_maxNumSources"     => "10",
		"par_IMA_newBackProjFile"   => "",
		"par_IMA_radiusLimit0"      => "120.0",
		"par_IMA_radiusLimit1"      => "120.0",
		"par_IMA_radiusLimit2"      => "117.0",
		"par_IMA_radiusLimit3"      => "110.0",
		"par_IMA_skyImageDim"       => "2",
		"par_IMA_skyRadiusFactor"   => "1.0",
		"par_IMA_useDeadAnodes"     => "no",
		"par_LCR_overrideCollTilt"  => "-1.0",
		"par_SPE_overrideCollTilt"  => "-1.0",
		"par_SPE_storePif"          => "0",

		"par_GTI_AttStability_Z"    => "3.0",		#	060925 - j_scripts 4.6
		"par_IMA2_dolBPL"           => "",			#	060925 - j_scripts 4.6
		"par_IMA_collHreduc"        => "0.0",		#	060925 - j_scripts 4.6
		"par_IMA_illumNorm"         => "0",			#	060925 - j_scripts 4.6
		"par_IMA_signifLim"         => "25",		#	060925 - j_scripts 4.6


		"stoponerror" => "0",									#	382099 is sorta acceptable
		);
	
	if ($retval) {
		if ($retval =~ /382099/) {
			&Message ( "WARNING:  no data;  skipping indexing." );
			#	return 3;
		} # if "no data" error
		else {
			#	perhaps this should be 
			#	&Error ( "return status of $retval from jemx_science_analysis not allowed." );
			#	instead of ...
			print "*******     ERROR:  return status of $retval from jemx_science_analysis not allowed.\n";
			exit 1;      
		}
	} # if error

	return;

} # end of JSA


=back

=head1 REFERENCES

For further information on the other processes in this pipeline, please run perldoc on each, e.g. C<perldoc nrtdp.pl>.

For further information about B<OPUS> please see C<file:///isdc/software/opus/html/opusfaq.html> on the office network or C<file:///isdc/opus/html/opusfaq.html> on the operations network.  Note that understanding this document requires that you understand B<OPUS> first.

For further information about the NRT pipelines, please see the Top Level Architectural Design Document.

=head1 AUTHORS

Tess Jaffe <theresa.jaffe@obs.unige.ch>

Jake Wendt <Jake.Wendt@obs.unige.ch>

=cut

#	last line
