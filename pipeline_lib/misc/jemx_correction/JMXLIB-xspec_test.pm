
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
sub JMXLIB::TESTING;

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
	my $BKG_simulated   = "n";
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
	my $skyImagesOut    = "RAW_R,VARIA,RESID,RES+S";
	my $radiusMin       = "0.0 2.4";
	my $radiusMax       = "2.4 6.6";
	my $mapSelect       = "RAW_RECT";
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
		$mapSelect       = "RES+SRC";
		$radiusSelect    = "4.8";
		$diameter        = "-1";
		$skyImagesOut    = "RAW_I,RAW_R,VARIA,RESID,RES+S";
	}
	elsif ( $ENV{PROCESS_NAME} =~ /nqlscw/ ) {
		$skipLevels      = "BKG";
		$endLevel        = "IMA";
		$BKG_simulated   = "y";
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




###########################################################################
###########################################################################
###########################################################################

#	JEMX Correction Testing changes


	$startLevel      = "COR";
	$endLevel        = "SPE";
	$skipLevels      = "BKG";
	$ENV{IC_ALIAS}   = "IC_5.1.1";

	$nChanBins       = "8";
	$chanLow         = "46 59  77 102 130 153 175 199";
	$chanHigh        = "58 76 101 129 152 174 198 223";








###########################################################################
###########################################################################
###########################################################################





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
		"par_BKG_simulated"         => "$BKG_simulated",
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
	chdir &ISDCLIB::FindDirVers ( "$OBSDIR/scw/$scwid" );

	my $original_pfiles   = $ENV{PFILES};
	my $original_parfiles = $ENV{PARFILES};
	my $original_timeout  = $ENV{TIMEOUT};
	$ENV{TIMEOUT}  = 900;
	$ENV{PARFILES} = "/tmp/$$-farith/";
	system ( "mkdir $ENV{PARFILES}" );

#	Then, for each "jmx1_sky_ima.fits":
	&Error ( "Retval is 0000001 from the command: NO jmx1_sky_ima.fits" ) unless ( -e "jmx1_sky_ima.fits" );


	foreach my $i ( 1,2,3,4 ) {
		system ( "$mycp jmx1_sky_ima.fits jmx1_sky_ima_$i.fits" );
		foreach my $ext ( reverse ( 2 .. 33 ) ) {
			( $retval, @result ) = &ISDCPipeline::RunProgram ( "fdelhdu infile=jmx1_sky_ima_$i.fits[$ext] confirm=no proceed=y" );
			&Error ( "1 somethin bad happened! - $retval" ) if ( $retval );
		}
	}


##########################################################################

	foreach my $i ( 2 .. 33 ) {
		if ( grep /^$i$/, ( 2,3,6,7,10,11,14,15,18,19,22,23,26,27,30,31 ) ) {
			( $retval, @result ) = &ISDCPipeline::RunProgram ( "farith infil1=jmx1_sky_ima.fits[$i] infil2=/unsaved_data/soldi/scratch2/soldi/jemx/MOSAIC/Crab/correction_all.fits[$i] outfil=temp_out_file.fits ops=MUL clobber=yes" );
			&Error ( "2 somethin bad happened! - $retval" ) if ( $retval );
			( $retval, @result ) = &ISDCPipeline::RunProgram ( "fappend infile=temp_out_file.fits[0] outfile=jmx1_sky_ima_1.fits" );
			&Error ( "3 somethin bad happened! - $retval" ) if ( $retval );
			( $retval, @result ) = &ISDCPipeline::RunProgram ( "fparkey fitsfile=jmx1_sky_ima_1.fits[$i] keyword=extname value=JMX1-SKY.-IMA add=y" );
			&Error ( "4 somethin bad happened! - $retval" ) if ( $retval );
		} else {
			( $retval, @result ) = &ISDCPipeline::RunProgram ( "fappend infile=jmx1_sky_ima.fits[$i] outfile=jmx1_sky_ima_1.fits" );
			&Error ( "5 somethin bad happened! - $retval" ) if ( $retval );
		}
	}

###########################################################################

	foreach my $i ( 2 .. 33 ) {
		if ( grep /^$i$/, ( 2,6,10,14,18,22,26,30 ) ) {
			( $retval, @result ) = &ISDCPipeline::RunProgram ( "farith infil1=jmx1_sky_ima.fits[$i] infil2=/unsaved_data/soldi/scratch2/soldi/jemx/MOSAIC/Crab/vignetting/vign_1.7.fits[2] outfil=temp_out_file.fits ops=MUL clobber=yes" );
			&Error ( "6 somethin bad happened! - $retval" ) if ( $retval );
			( $retval, @result ) = &ISDCPipeline::RunProgram ( "fappend infile=temp_out_file.fits[0] outfile=jmx1_sky_ima_2.fits" );
			&Error ( "7 somethin bad happened! - $retval" ) if ( $retval );
			( $retval, @result ) = &ISDCPipeline::RunProgram ( "fparkey fitsfile=jmx1_sky_ima_2.fits[$i] keyword=extname value=JMX1-SKY.-IMA add=y" );
			&Error ( "8 somethin bad happened! - $retval" ) if ( $retval );
		} elsif ( grep /^$i$/, ( 3,7,11,15,19,23,27,31 ) ) {
			( $retval, @result ) = &ISDCPipeline::RunProgram ( "farith infil1=jmx1_sky_ima.fits[$i] infil2=/unsaved_data/soldi/scratch2/soldi/jemx/MOSAIC/Crab/vignetting/vign_1.7.fits[3] outfil=temp_out_file.fits ops=MUL clobber=yes" );
			&Error ( "9 somethin bad happened! - $retval" ) if ( $retval );
			( $retval, @result ) = &ISDCPipeline::RunProgram ( "fappend infile=temp_out_file.fits[0] outfile=jmx1_sky_ima_2.fits" );
			&Error ( "10 somethin bad happened! - $retval" ) if ( $retval );
			( $retval, @result ) = &ISDCPipeline::RunProgram ( "fparkey fitsfile=jmx1_sky_ima_2.fits[$i] keyword=extname value=JMX1-SKY.-IMA add=y" );
			&Error ( "11 somethin bad happened! - $retval" ) if ( $retval );
		} else {
			( $retval, @result ) = &ISDCPipeline::RunProgram ( "fappend infile=jmx1_sky_ima.fits[$i] outfile=jmx1_sky_ima_2.fits" );
			&Error ( "12 somethin bad happened! - $retval" ) if ( $retval );
		}
	}


###########################################################################

	foreach my $i ( 2 .. 33 ) {
		if ( grep /^$i$/, ( 2,6,10,14,18,22,26,30 ) ) {
			( $retval, @result ) = &ISDCPipeline::RunProgram ( "farith infil1=jmx1_sky_ima.fits[$i] infil2=/unsaved_data/soldi/scratch2/soldi/jemx/MOSAIC/Crab/vignetting/vign_2.0.fits[2] outfil=temp_out_file.fits ops=MUL clobber=yes" );
			&Error ( "13 somethin bad happened! - $retval" ) if ( $retval );
			( $retval, @result ) = &ISDCPipeline::RunProgram ( "fappend infile=temp_out_file.fits[0] outfile=jmx1_sky_ima_3.fits" );
			&Error ( "14 somethin bad happened! - $retval" ) if ( $retval );
			&ISDCPipeline::RunProgram ( "fparkey fitsfile=jmx1_sky_ima_3.fits[$i] keyword=extname value=JMX1-SKY.-IMA add=y" );
			&Error ( "15 somethin bad happened! - $retval" ) if ( $retval );
		} elsif ( grep /^$i$/, ( 3,7,11,15,19,23,27,31 ) ) {
			( $retval, @result ) = &ISDCPipeline::RunProgram ( "farith infil1=jmx1_sky_ima.fits[$i] infil2=/unsaved_data/soldi/scratch2/soldi/jemx/MOSAIC/Crab/vignetting/vign_2.0.fits[3] outfil=temp_out_file.fits ops=MUL clobber=yes" );
			&Error ( "16 somethin bad happened! - $retval" ) if ( $retval );
			( $retval, @result ) = &ISDCPipeline::RunProgram ( "fappend infile=temp_out_file.fits[0] outfile=jmx1_sky_ima_3.fits" );
			&Error ( "17 somethin bad happened! - $retval" ) if ( $retval );
			( $retval, @result ) = &ISDCPipeline::RunProgram ( "fparkey fitsfile=jmx1_sky_ima_3.fits[$i] keyword=extname value=JMX1-SKY.-IMA add=y" );
			&Error ( "18 somethin bad happened! - $retval" ) if ( $retval );
		} else {
			( $retval, @result ) = &ISDCPipeline::RunProgram ( "fappend infile=jmx1_sky_ima.fits[$i] outfile=jmx1_sky_ima_3.fits" );
			&Error ( "19 somethin bad happened! - $retval" ) if ( $retval );
		}
	}

###########################################################################

	foreach my $i ( 2 .. 33 ) {
		if ( grep /^$i$/, ( 2,6,10,14,18,22,26,30 ) ) {
			( $retval, @result ) = &ISDCPipeline::RunProgram ( "farith infil1=jmx1_sky_ima.fits[$i] infil2=/unsaved_data/soldi/scratch2/soldi/jemx/MOSAIC/Crab/vignetting/vign_2.5.fits[2] outfil=temp_out_file.fits ops=MUL clobber=yes" );
			&Error ( "20 somethin bad happened! - $retval" ) if ( $retval );
			( $retval, @result ) = &ISDCPipeline::RunProgram ( "fappend infile=temp_out_file.fits[0] outfile=jmx1_sky_ima_4.fits" );
			&Error ( "21 somethin bad happened! - $retval" ) if ( $retval );
			( $retval, @result ) = &ISDCPipeline::RunProgram ( "fparkey fitsfile=jmx1_sky_ima_4.fits[$i] keyword=extname value=JMX1-SKY.-IMA add=y" );
			&Error ( "22 somethin bad happened! - $retval" ) if ( $retval );
		} elsif ( grep /^$i$/, ( 3,7,11,15,19,23,27,31 ) ) {
			( $retval, @result ) = &ISDCPipeline::RunProgram ( "farith infil1=jmx1_sky_ima.fits[$i] infil2=/unsaved_data/soldi/scratch2/soldi/jemx/MOSAIC/Crab/vignetting/vign_2.5.fits[3] outfil=temp_out_file.fits ops=MUL clobber=yes" );
			&Error ( "23 somethin bad happened! - $retval" ) if ( $retval );
			( $retval, @result ) = &ISDCPipeline::RunProgram ( "fappend infile=temp_out_file.fits[0] outfile=jmx1_sky_ima_4.fits" );
			&Error ( "24 somethin bad happened! - $retval" ) if ( $retval );
			( $retval, @result ) = &ISDCPipeline::RunProgram ( "fparkey fitsfile=jmx1_sky_ima_4.fits[$i] keyword=extname value=JMX1-SKY.-IMA add=y" );
			&Error ( "25 somethin bad happened! - $retval" ) if ( $retval );
		} else {
			( $retval, @result ) = &ISDCPipeline::RunProgram ( "fappend infile=jmx1_sky_ima.fits[$i] outfile=jmx1_sky_ima_4.fits" );
			&Error ( "26 somethin bad happened! - $retval" ) if ( $retval );
		}
	}

###########################################################################

#	my $rmfgrp = &ISDCPipeline::GetICFile (
#		"structure" => "JMX1-RMF.-GRP",
#		"filematch" => "$OBSDIR/$ogDOL",
#		);
#
#	#	expecting $rmfgrp to include an extension which would need trimmed off
#	$rmfgrp =~ s/\[.*$//;
#
#	&ISDCPipeline::PipelineStep (
#		"step"           => "fextract JMX1-AXIS-ARF",
#		"program_name"   => "fextract",
#		"par_infile"     => "$rmfgrp"."[JMX1-AXIS-ARF]",
#		"par_outfile"    => "toto.fits",
#		);

	system ( "/bin/rm -rf $ENV{PARFILES}" );
	$ENV{PARFILES} = $original_parfiles;
	$ENV{PFILES}   = $original_pfiles;

	system ( "$mycp jmx1_sky_ima.fits jmx1_sky_ima_0.fits" );

	my $format  = "%-20s %20s %20s %20s %20s\n";
	my $format2 = "%-20s %20f %20f %20f %20f\n";
	open (OUTPUT, "> xspec_results" );
	printf OUTPUT $format, "FILENAME", "PhoIndex", "norm", "Red chi-sq", "Null hypothesis prob";

	foreach my $i ( 0,1,2,3,4 ) {
		($retval,@result) = &ISDCPipeline::PipelineStep(
			"step"            => "Corrected image $i",
			"program_name"    => "mosaic_spec",
			"par_DOL_inp"     => "",
			"par_DOL_out"     => "",
			"par_EXTNAME"     => "JMX1-SKY.-IMA",
			"par_DOL_idx"     => "jmx1_sky_ima_$i.fits",
			"par_DOL_spec"    => "spectrum_$i.fits(JMX1-PHA1-SPE.tpl)",
			"par_ximg"        => "0",
			"par_yimg"        => "0",
			"par_ra"          => "83.63",
			"par_dec"         => "22.01",
			"par_posmode"     => "0",
			"par_widthmode"   => "1",
			#	unspecifed by Stephane so using defaults
			"par_outmode"     => "2",
			"par_psf"         => "6",
			"par_size"        => "20",
			"par_back"        => "no",
			"par_allEnergies" => "yes",
			"par_emin"        => "25 30 40",
			"par_chatty"      => "4",
			);

#			."arf toto.fits\n"
		($retval,@result) = &ISDCPipeline::RunProgram ( "$myecho \""
			."data spectrum_$i.fits\n"
			."response /unsaved_data/soldi/scratch2/soldi/jemx/MOSAIC/Crab/fit/JEMX_8_RMF.fits\n"
			."arf jmx1_srcl_arf.fits{1}\n"
			."model wabs(po)\n"
			."3 -1\n"
			."\n"
			."\n"
			."fit 100\n"
			."quit\n"
			."y\" | xspec" );
		&Message ( @result );
			&Error ( "27 somethin bad happened! - $retval" ) if ( $retval );
		
		printf OUTPUT $format2, "spectrum_$i.fits" ,
			(split /\s+/,(grep /PhoIndex/, @result)[-1])[5],
			(split /\s+/,(grep /norm/, @result)[-1])[5],
			(split /\s+/,(grep /Reduced chi-squared/, @result)[-1])[4],
			(split /\s+/,(grep /Null hypothesis probability/, @result)[-1])[5];
	}

#		."arf toto.fits\n"
	($retval,@result) = &ISDCPipeline::RunProgram ( "$myecho \""
		."data jmx1_srcl_spe.fits{1}\n"
		."ignore **-3.0\n"
		."ignore 35.0-**\n"
		."model wabs(po)\n"
		."3 -1\n"
		."\n"
		."\n"
		."fit 100\n"
		."quit\n"
		."y\" | xspec" );
	&Message ( @result );
			&Error ( "28 somethin bad happened! - $retval" ) if ( $retval );

	printf OUTPUT $format2, "jmx1_srcl_spe.fits" ,
		(split /\s+/,(grep /PhoIndex/, @result)[-1])[5],
		(split /\s+/,(grep /norm/, @result)[-1])[5],
		(split /\s+/,(grep /Reduced chi-squared/, @result)[-1])[4],
		(split /\s+/,(grep /Null hypothesis probability/, @result)[-1])[5];
	close OUTPUT;

#	my @message;
#	push @message, "XSPEC found";
#	push @message, 
#	&Message ( "PhoIndex   : ",(split /\s+/,(grep /PhoIndex/, @result)[-1])[5] );
#	&Message ( "norm       : ",(split /\s+/,(grep /norm/, @result)[-1])[5] );
#	&Message ( "Red chi-sq : ",(split /\s+/,(grep /Reduced chi-squared/, @result)[-1])[4] );

	system ( "$myrm temp_out_file.fits" );
#	system ( "$myrm toto.fits" );


#	Then, in both cases, we need to grab the following values from the output:
#	- The number after "PhoIndex"
#	- The number after "norm"
#	- The number after "Reduced chi-squared =" 



###########################################################################
###########################################################################
###########################################################################


	return;

} # end of TESTING

