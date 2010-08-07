
package JMXLIB;

use strict;
use ISDCPipeline;
use ISDCLIB;
use UnixLIB;

sub JMXLIB::JSA;
sub JMXLIB::TESTING;

$| = 1;

sub JSA {
	my %att = @_;
	$att{proctype}      = "scw" unless $att{proctype} =~ /mosaic/;	#	either "scw" or "mosaic"

	my $proc            = &ProcStep();
	my $ogDOL           = "og_jmx$att{jemxnum}.fits[GROUPING]";
	#	default values ( consssa scw as well as conssa scw )	Used in both &JSA and &Scw

	&Error ( "*******     ERROR:   JMXLIB::JSA doesn't recognize given JEMX number $att{jemxnum}!\n" )
		unless ( $att{jemxnum} =~ /^(1|2)$/ );


	my ($retval,@result) = &ISDCPipeline::PipelineStep(
		"step"                      => "$proc - JMX $att{proctype}",
		"program_name"              => "jemx_science_analysis",
		"par_ogDOL"                 => "$ogDOL",
		"par_jemxNum"               => "$att{jemxnum}",
	"par_nChanBins" => "8",
	"par_chanLow" => "46 59  77 102 130 153 175 199",
	"par_chanHigh" => "58 76 101 129 152 174 198 223",
	"par_IC_Group" => "/isdc/ic_tree/osa_ic-20060703/idx/ic/ic_master_file.fits[1]",
	"par_IMA_skyImagesOut" => "RECONSTRUCTED,VARIANCE,EXPOSURE",
	"par_endLevel" => "SPE",


	"par_startLevel" => "COR",
	"par_skipLevels" => "",
	"par_chatter" => "2",
	"par_clobber" => "y",
	"par_osimData" => "n",
	"par_ignoreScwErrors" => "n",
	"par_timeStart" => "-1.0",
	"par_timeStop" => "-1.0",
	"par_nPhaseBins" => "0",
	"par_phaseBins" => "",
	"par_radiusLimit" => "105.0",
	"par_IC_Alias" => "OSA",
	"par_instMod" => "",
	"par_response" => "",
	"par_COR_gainHist" => "",
	"par_COR_gainModel" => "2",
	"par_COR_outputExists" => "n",
	"par_GTI_gtiUser" => "",
	"par_GTI_TimeFormat" => "IJD",
	"par_GTI_BTI_Dol" => "",
	"par_GTI_BTI_Names" => "BAD_RESPONSE LOW_GAIN",
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
	"par_BIN_I_backCorr" => "n",
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
	"par_IMA_interactionDepth" => "10.0",
	"par_IMA_hotPixelLimit" => "4.0",
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
	"par_SPE_timeStep" => "0.0",
	"par_SPE_vignCorr" => "y",
	"par_SPE_bgrMethod" => "0",
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
	"par_LCR_bgrMethod" => "0",
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
	"par_IMA2_diameter" => "20.",
	"par_IMA2_cdelt" => "0.026",
	"par_IMA2_RAcenter" => "-1",
	"par_IMA2_DECcenter" => "0.",
	"par_IMA2_outfile" => "J_MOSAIC",
	"par_IMA2_viewTime" => "Y",
	"par_IMA2_viewIntens" => "Y",
	"par_IMA2_viewVar" => "N",
	"par_IMA2_viewSig" => "Y",
	"par_IMA2_srcFileDOL" => "",
	"par_IMA2_srcselect" => "",
	"par_IMA2_srcattach" => "y",

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

	&JMXLIB::TESTING ( $ogDOL );

	return;

}	#	end of JSA





###########################################################################
###########################################################################
###########################################################################




sub TESTING {
	my ( $ogDOL ) = @_;
	my $retval = 0;
	my @result = ();

	my ( $scwid, $revno, $og, $inst, $INST, $instdir, $OG_DATAID, $OBSDIR ) = &SSALIB::ParseOSF;
	my ( $jemxnum ) = ( $inst =~ /(\d)$/ );
	chdir &ISDCLIB::FindDirVers ( "$OBSDIR/scw/$scwid" );

	$ENV{TIMEOUT}  = 900;

#	Then, for each "jmx${jemxnum}_sky_ima.fits":
	&Error ( "Retval is 000000${jemxnum} from the command: NO jmx${jemxnum}_sky_ima.fits" ) unless ( -e "jmx${jemxnum}_sky_ima.fits" );


	my $format  = "%-20s %20s %20s %20s %20s\n";
	my $format2 = "%-20s %20s %20s %20s %20s\n";
	open (OUTPUT, "> xspec_results" );
	printf OUTPUT $format, "FILENAME", "PhoIndex", "norm", "Red chi-sq", "Null hypothesis prob";

	($retval,@result) = &ISDCPipeline::PipelineStep(
		"step"            => "Corrected image",
		"program_name"    => "mosaic_spec",
		"par_DOL_inp"     => "",
		"par_DOL_out"     => "",
		"par_EXTNAME"     => "JMX${jemxnum}-SKY.-IMA",
		"par_DOL_idx"     => "jmx${jemxnum}_sky_ima.fits",
		"par_DOL_spec"    => "spectrum.fits(JMX${jemxnum}-PHA1-SPE.tpl)",
		"par_ximg"        => "0",
		"par_yimg"        => "0",
		"par_ra"          => "83.63",
		"par_dec"         => "22.01",
		"par_posmode"     => "0",
		"par_widthmode"   => "1",
		"par_Intensity"   => "RECONSTRUCTED",
		#	unspecifed by Stephane so using defaults
#		"par_outmode"     => "2",
		"par_psf"         => "6",
		"par_size"        => "20",
		"par_back"        => "no",
		"par_allEnergies" => "yes",
		"par_emin"        => "25 30 40",
		"par_chatty"      => "4",
		);

	($retval,@result) = &ISDCPipeline::RunProgram ( "$myecho \""
		."data spectrum.fits\n"
		."response /unsaved_data/soldi/scratch2/soldi/jemx/MOSAIC/Crab/fit/JEMX_8_RMF.fits\n"
		."arf jmx${jemxnum}_srcl_arf.fits{1}\n"
		."model wabs(po)\n"
		."3 -1\n"
		."\n"
		."\n"
		."fit 100\n"
		."quit\n"
		."y\" | xspec" );
	&Message ( @result );
	&Error ( "27 somethin bad happened! - $retval" ) if ( $retval );
		
	printf OUTPUT $format2, "spectrum.fits" ,
		(split /\s+/,(grep /PhoIndex/, @result)[-1])[5],
		(split /\s+/,(grep /norm/, @result)[-1])[5],
		(split /\s+/,(grep /Reduced chi-squared/, @result)[-1])[4],
		(split /\s+/,(grep /Null hypothesis probability/, @result)[-1])[5];

	($retval,@result) = &ISDCPipeline::RunProgram ( "$myecho \""
		."data jmx${jemxnum}_srcl_spe.fits{1}\n"
		."ignore **-3.0\n"
		."ignore 30.0-**\n"
		."model wabs(po)\n"
		."3 -1\n"
		."\n"
		."\n"
		."fit 100\n"
		."quit\n"
		."y\" | xspec" );
	&Message ( @result );
	&Error ( "28 somethin bad happened! - $retval" ) if ( $retval );

	printf OUTPUT $format2, "jmx${jemxnum}_srcl_spe.fits" ,
		(split /\s+/,(grep /PhoIndex/, @result)[-1])[5],
		(split /\s+/,(grep /norm/, @result)[-1])[5],
		(split /\s+/,(grep /Reduced chi-squared/, @result)[-1])[4],
		(split /\s+/,(grep /Null hypothesis probability/, @result)[-1])[5];

	close OUTPUT;

	system ( "$myrm temp_out_file.fits" );

	return;

} # end of TESTING
