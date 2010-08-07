
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

	&Error ( "*******     ERROR:   JMXLIB::JSA doesn't recognize given JEMX number $att{jemxnum}!\n" )
		unless ( $att{jemxnum} =~ /^(1|2)$/ );

	#	OSA 7 - jemx_science_analysis 5.0.2 defaults
	my %parameters = (
		"par_ogDOL" => "",
		"par_jemxNum" => "2",
		"par_startLevel" => "COR",
		"par_endLevel" => "IMA2",
		"par_skipLevels" => "",
		"par_chatter" => "2",
		"par_clobber" => "y",
		"par_osimData" => "n",
		"par_ignoreScwErrors" => "n",
		"par_nChanBins" => "4",
		"par_chanLow" => "46 83 129 160",
		"par_chanHigh" => "82 128 159 223",
		"par_timeStart" => "-1.0",
		"par_timeStop" => "-1.0",
		"par_nPhaseBins" => "0",
		"par_phaseBins" => "",
		"par_radiusLimit" => "122.0",
		"par_IC_Group" => "../../idx/ic/ic_master_file.fits[1]",
		"par_IC_Alias" => "OSA",
		"par_instMod" => "",
		"par_response" => "",
		"par_COR_gainHist" => "",
		"par_COR_gainModel" => "2",
		"par_COR_outputExists" => "n",
		"par_COR_randPos" => "n",
		"par_GTI_gtiUser" => "",
		"par_GTI_TimeFormat" => "IJD",
		"par_GTI_BTI_Dol" => "",
		"par_GTI_BTI_Names" => "BAD_RESPONSE BAD_CONFIGURATION",
		"par_GTI_attTolerance" => "0.5",
		"par_GTI_AttStability_Z" => "3.0",
		"par_GTI_limitTable" => "",
		"par_GTI_gtiJemxNames" => "",
		"par_GTI_gtiScNames" => "",
		"par_GTI_MergedName" => "MERGED",
		"par_GTI_Accuracy" => "any",
		"par_DEAD_outputExists" => "n",
		"par_CAT_I_usrCat" => "",
		"par_CAT_I_refCat" => "$ENV{ISDC_REF_CAT}",
		"par_CAT_I_radiusMin" => " 0 2.4",
		"par_CAT_I_radiusMax" => "2.4 5.8",
		"par_CAT_I_fluxDef" => "0",
		"par_CAT_I_fluxMin" => "",
		"par_CAT_I_fluxMax" => "",
		"par_CAT_I_class" => "",
		"par_CAT_I_date" => "-1",
		"par_BIN_I_chanLowDet" => "46 96 135",
		"par_BIN_I_chanHighDet" => "95 134 178",
		"par_BIN_I_evtType" => "-1",
		"par_BIN_I_shdType" => "2",
		"par_BIN_I_shdRes" => "",
		"par_BIN_I_rowSelect" => "&&STATUS<256",
		"par_BIN_I_gtiNames" => "",
		"par_IMA_makeNewBPL" => "no",
		"par_IMA_newBackProjFile" => "",
		"par_IMA_detAccLimit" => "16384",
		"par_IMA_skyImageDim" => "2",
		"par_IMA_useDeadAnodes" => "no",
		"par_IMA_maxNumSources" => "10",
		"par_IMA_edgeEnhanceFactor" => "1.0",
		"par_IMA_loopLimitPeak" => "0.025",
		"par_IMA_detSigSingle" => "12.0",
		"par_IMA_skyRadiusFactor" => "1.0",
		"par_IMA_radiusLimit0" => "120.0",
		"par_IMA_radiusLimit1" => "120.0",
		"par_IMA_radiusLimit2" => "117.0",
		"par_IMA_radiusLimit3" => "110.0",
		"par_IMA_interactionDepth" => "3.0",
		"par_IMA_hotPixelLimit" => "4.0",
		"par_IMA_skyImagesOut" => "RECONSTRUCTED,VARIANCE",
		"par_IMA_dolBPL" => "",
		"par_IMA_bkgShdDOL" => "",
		"par_IMA_signifLim" => "25",
		"par_IMA_illumNorm" => "0",
		"par_IMA_collHreduc" => "0.0",
		"par_IMA_relDist" => "1.5",
		"par_IMA_fluxLimit" => "0.000",
		"par_IMA_searchRad" => "5.00",
		"par_IMA_gridNum" => "10",
		"par_IMA_distFuzz" => "0.15",
		"par_IMA_detImagesOut" => "n",
		"par_SPE_timeStep" => "0.0",
		"par_SPE_vignCorr" => "y",
		"par_SPE_evtType" => "-1",
		"par_SPE_precisionLevel" => "20",
		"par_SPE_tAccuracy" => "3",
		"par_SPE_rowSelect" => "",
		"par_SPE_useRaDec" => "y",
		"par_SPE_fluxScaling" => "2",
		"par_SPE_skipNearDeadAnode" => "y",
		"par_SPE_skipHotSpot" => "n",
		"par_SPE_overrideCollTilt" => "-1.0",
		"par_SPE_storePif" => "0",
		"par_LCR_timeStep" => "0.0",
		"par_LCR_vignCorr" => "y",
		"par_LCR_evtType" => "-1",
		"par_LCR_precisionLevel" => "20",
		"par_LCR_tAccuracy" => "3",
		"par_LCR_useRaDec" => "y",
		"par_LCR_rowSelect" => "",
		"par_LCR_fluxScaling" => "2",
		"par_LCR_skipNearDeadAnode" => "y",
		"par_LCR_skipHotSpot" => "n",
		"par_LCR_overrideCollTilt" => "-1.0",
		"par_BIN_S_rowSelectEvts" => "",
		"par_BIN_S_rowSelectSpec" => "",
		"par_BIN_S_evtType" => "-1",
		"par_BIN_T_rowSelect" => "",
		"par_BIN_T_evtType" => "-1",
		"par_IMA2_mapSelect" => "RECON",
		"par_IMA2_dolBPL" => "",
		"par_IMA2_radiusSelect" => "4.8",
		"par_IMA2_eminSelect" => "0.",
		"par_IMA2_emaxSelect" => "80.",
		"par_IMA2_diameter" => "0.",
		"par_IMA2_cdelt" => "0.026",
		"par_IMA2_RAcenter" => "-1",
		"par_IMA2_DECcenter" => "0.",
		"par_IMA2_outfile" => "",
		"par_IMA2_viewTime" => "Y",
		"par_IMA2_viewIntens" => "Y",
		"par_IMA2_viewVar" => "Y",
		"par_IMA2_viewSig" => "Y",
		"par_IMA2_srcFileDOL" => "",
		"par_IMA2_srcselect" => "",
		"par_IMA2_srcattach" => "y",
		"par_IMA2_print_ScWs" => "N",
	);

	#	Universal diffs based on settings prior to 071214
	$parameters{'par_ogDOL'}                 = "og_jmx$att{jemxnum}.fits[GROUPING]";
	$parameters{'par_jemxNum'}               = $att{jemxnum};
	$parameters{'par_IC_Alias'}              = $ENV{IC_ALIAS};
	$parameters{'par_IC_Group'}              = $att{IC_Group};

#	I wouldn't be surprised if some of these changes cause a problem in one of the other pipelines
#	$parameters{'par_endLevel'}              = "LCR";
#	$parameters{'par_skipLevels'}            = "BKG,SPE";
#	$parameters{'par_nChanBins'}             = "5";
#	$parameters{'par_chanHigh'}              = "57 118 159 196 235";
#	$parameters{'par_chanLow'}               = "30  58 119 160 197";
#	$parameters{'par_CAT_I_radiusMin'}       = "0.0 2.4";
#	$parameters{'par_CAT_I_radiusMax'}       = "2.4 6.6";
#	$parameters{'par_IMA_skyImagesOut'}      = "RECTI,VARIA,RESID,RECON";
#	$parameters{'par_IMA2_cdelt'}            = "0.03";
#	$parameters{'par_IMA2_diameter'}         = "20.";
#	$parameters{'par_IMA2_mapSelect'}        = "RECTI";
#	$parameters{'par_IMA2_radiusSelect'}     = "5.";
#	$parameters{'par_IMA2_viewTime'}         = "N";
#	$parameters{'par_IMA2_viewVar'}          = "N";
#	$parameters{'par_BIN_I_rowSelect'}       = "";
#	$parameters{'par_GTI_BTI_Names'}         = "";
#	$parameters{'par_IMA_distFuzz'}          = "0.0";
#	$parameters{'par_IMA_gridNum'}           = "0";
#	$parameters{'par_IMA_relDist'}           = "-0.05";
#	$parameters{'par_IMA_searchRad'}         = "0.0";
#	$parameters{'par_LCR_timeStep'}          = "-1";
#	$parameters{'par_radiusLimit'}           = "105.0";
	$parameters{'par_IMA2_outfile'}          = "J_MOSAIC";
#	$parameters{'par_IMA_detImagesOut'}      = "y";



	#	default values ( consssa scw as well as conssa scw )	Used in both &JSA and &Scw


	if      ( $ENV{PATH_FILE_NAME} =~ /consssa/ ) {
		$parameters{'par_nChanBins'} = "8";
		$parameters{'par_chanLow'}   = "30 46  71 129 179 224  45 128";
		$parameters{'par_chanHigh'}  = "45 70 128 178 223 235 127 210";
	} elsif ( $ENV{PATH_FILE_NAME} =~ /conssa/ ) {
		$parameters{'par_IMA2_cdelt'}       = "0.02";
	} elsif ( $ENV{PATH_FILE_NAME} =~ /nrtqla/ ) {
		$parameters{'par_IMA_skyImagesOut'} = "RECONSTRUCTED,VARIANCE,SIGNIFICANCE";
		$parameters{'par_nChanBins'}        = "2";
		$parameters{'par_chanLow'}          =  "46 129";
		$parameters{'par_chanHigh'}         = "128 178";
	} else {
		&Error ( "No match found for PATH_FILE_NAME: $ENV{PATH_FILE_NAME}; PROCESS_NAME: $ENV{PROCESS_NAME}; proctype: $att{proctype}\n" );
	}


	if ( ( $ENV{PROCESS_NAME} =~ /cssscw/ ) && ( $att{proctype} =~ /scw/ ) ) {
		#	use the defaults
		$parameters{'par_CAT_I_radiusMax'} = "2.4 5.5";
		$parameters{'par_CAT_I_usrCat'}    = "jmx$att{jemxnum}_catalog.fits";
		
		&ISDCPipeline::PipelineStep (
			"step"           => "$proc - cat_extract",
			"program_name"   => "cat_extract",
			"par_refCat"     => "$ENV{ISDC_REF_CAT}"."[JEMX_FLAG==1]",
			"par_instrument" => "JMX"."$att{jemxnum}",
			"par_inGRP"      => "",
			"par_outGRP"     => $parameters{'par_ogDOL'},
			"par_outCat"     => "$parameters{'par_CAT_I_usrCat'}(JMX$att{jemxnum}-SRCL-CAT.tpl)",
			"par_outExt"     => "JMX$att{jemxnum}-SRCL-CAT",
			"par_date"       => "-1.",
			"par_radiusMin"  => $parameters{'par_CAT_I_radiusMin'},
			"par_radiusMax"  => $parameters{'par_CAT_I_radiusMax'},
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
			"step"         => "$proc - fcalc",
			"program_name" => "fcalc",
			"par_infile"   => $parameters{'par_CAT_I_usrCat'},
			"par_outfile"  => $parameters{'par_CAT_I_usrCat'},
			"par_clname"   => "FLAG",
			"par_expr"     => "1",
			"par_clobber"  => "yes",
			);

		system ( "/bin/rm -rf $ENV{PARFILES}" );
		$ENV{PARFILES} = $original_parfiles;
		$ENV{PFILES}   = $original_pfiles;
		$parameters{'par_CAT_I_usrCat'} .= "[1]";		#	because it will need to be a DOL to jemx_science_analysis
	}
	elsif ( ( $ENV{PROCESS_NAME} =~ /cssscw/ ) && ( $att{proctype} =~ /mosaic/ ) ) {
		$parameters{'par_startLevel'}        = "IMA2";
		$parameters{'par_IMA2_mapSelect'}    = "RECON";
		$parameters{'par_IMA2_radiusSelect'} = "4.8";
		$parameters{'par_IMA2_diameter'}     = "-1";
		$parameters{'par_IMA_skyImagesOut'}  = "RAWIN,RECTI,VARIA,RESID,RECON";
	}
	elsif ( $ENV{PROCESS_NAME} =~ /nqlobs/ ) {
		$parameters{'par_startLevel'} = "IMA2";
	}
	elsif ( $ENV{PROCESS_NAME} =~ /nqlscw/ ) {
#		$parameters{'par_skipLevels'} = "BKG";
		$parameters{'par_endLevel'}   = "IMA";
	}
	elsif ( $ENV{PROCESS_NAME} =~ /csaob1/ ) {
		$parameters{'par_startLevel'}    = "IMA2";
	}
	elsif ( $ENV{PROCESS_NAME} =~ /csasw1/ ) {
		$parameters{'par_ogDOL'} = &ISDCLIB::FindDirVers ( "scw/$att{scwid}" )."/swg_jmx$att{jemxnum}.fits[GROUPING]";
	}
	else {
		&Error ( "No match found for PROCESS_NAME: $ENV{PROCESS_NAME}; proctype: $att{proctype}\n" );
	}

	#####################################################################################

	if ( $ENV{REDO_CORRECTION} ) {
		&Message ( "Redoing Correction step." );
		$parameters{'par_startLevel'} = "COR";
		$parameters{'par_endLevel'}   = "DEAD";
	}

	if ( $att{proctype} =~ /scw/ ) {
		#	Check to ensure that only 1 child in OG
		my $numScwInOG = &ISDCLIB::ChildrenIn ( $parameters{'par_ogDOL'}, "GNRL-SCWG-GRP-IDX" );
		&Error ( "Not 1 child in $parameters{'par_ogDOL'}: $numScwInOG" ) unless ( $numScwInOG == 1 );
	}

	print "\n========================================================================\n";
	print "#######     DEBUG:  ISDC_REF_CAT is $ENV{ISDC_REF_CAT}.\n";

	my ($retval,@result) = &ISDCPipeline::PipelineStep(
		"step"         => "$proc - JMX $att{proctype}",
		"program_name" => "jemx_science_analysis",
		%parameters,
		"stoponerror" => "0"
		);
	
	if ($retval) {
		if ($retval =~ /382099|35644/) {		#	071204 - Jake - SCREW 997: added 35644
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
