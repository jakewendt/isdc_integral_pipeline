
package IBISLIB;

use strict;
use ISDCPipeline;
use UnixLIB;
use ISDCLIB;
use SSALIB;

sub IBISLIB::ISA;
sub IBISLIB::IPMosaic;

$| = 1;


sub ISA {
	&Carp::croak ( "IBISLIB::ISA: Need even number of args" ) if ( @_ % 2 );
	
	my %att = @_;
	$att{proctype}     = "scw"  unless $att{proctype} =~ /mosaic/;			#	either "scw" or "mosaic"
	$att{IC_Group}     = "../../idx/ic/ic_master_file.fits[1]" unless ( $att{IC_Group} );
	$att{instdir}      = "obs" unless ( $att{instdir} );

	my $proc           = &ProcStep();
	&Message ( "Running IBISLIB::ISA for dataset:$ENV{OSF_DATASET}: process:$ENV{PROCESS_NAME}; proctype:$att{proctype}; INST:$att{INST}." );

	#	set defaults to consssa/scw, cause its easier programmatically
	my $ogDOL          = "og_ibis.fits[1]";
	my $disableIsgri   = "no";
	my $disablePICsIT  = "yes";
	my $rebin_corr     = "";
	my $refcat         = "$ENV{ISDC_REF_CAT}";
	my $startLevel     = "COR";
	my $endLevel       = "IMA";
	my $SearchMode     = "2";
	my $ToSearch       = "2";
	my $DoPart2        = "0";
	my $MapSize        = "40.";
	my $ICOR_riseDOL   = "";
	my $II_ChanNum     = "1";
	my $II_ChanMin     = "20";
	my $II_ChanMax     = "60";
	my $MinCatSouSnr   = "6";
	my $SouFit         = "0";
	my $method_cor     = "2";
	my $brPifThreshold = "0.0001";
	my $BTI_Names      = "validation_report omc_rise_time_set_too_low wrong_rise_time_selection solar_activity wrong_veto";
	my $SCW1_BKG_I_isgrBkgDol  = "-";
	my $SCW1_BKG_I_isgrUnifDol = "-";
	my $PICSIT_inCorVar = "1";		#	060104 - Jake - FIX I don't know if this diff is really nec as we don't really proc picsit.  ask NP/Luigi
	my $GTI_PICsIT      = "ATTITUDE P_SGLE_DATA_GAPS P_MULE_DATA_GAPS";
	my $levelList       = "PRP,COR,GTI,DEAD,BIN_I,BKG_I,CAT_I,IMA,IMA2,BIN_S,SPE,LCR,COMP,CLEAN";

	#####################################################################################

	if ( $att{INST} =~ /ISGRI|IBIS/ ) {
		$refcat        .= "[ISGRI_FLAG == 1]";	#	only unused for consssa of picsit
		if ( $ENV{PROCESS_NAME} =~ /cssscw/ ) {	
			$rebin_corr     = "$ENV{REP_BASE_PROD}/$att{instdir}/rebinned_corr_ima.fits[1]";
			&ISDCPipeline::RunProgram ( "$mycp $ENV{ISDC_OPUS}/consssa/rebinned_corr_ima.fits.gz $ENV{REP_BASE_PROD}/$att{instdir}/" )
				unless ( -e "$ENV{REP_BASE_PROD}/$att{instdir}/rebinned_corr_ima.fits.gz" );
		}
		if ( ( $ENV{PROCESS_NAME} =~ /csasw1|cssscw/ ) && ( ! -e "energy_bands.fits.gz" ) ) {
			&ISDCPipeline::RunProgram ( "$mycp $ENV{ISDC_OPUS}/pipeline_lib/energy_bands.fits.gz ./" );
			&Error ( "energy_bands.fits.gz does not exist!" ) unless ( -e "energy_bands.fits.gz" );
		}
	}
	else {
		&Error ( "Unknown INST instrument : $att{INST}!" );
	}

	#####################################################################################

	if ( $att{proctype} =~ /scw/ ) {
		#	Check to ensure that only 1 child on OG
		my $numScwInOG = &ISDCLIB::ChildrenIn ( $ogDOL, "GNRL-SCWG-GRP-IDX" );
		&Error ( "Not 1 child in $ogDOL: $numScwInOG" ) unless ( $numScwInOG == 1 );
	}

	print "\n========================================================================\n";
	print "#######     DEBUG:  ISDC_REF_CAT is $ENV{ISDC_REF_CAT}\n";

	my $dal_retry_open_existed = $ENV{DAL_RETRY_OPEN} if ( defined ( $ENV{DAL_RETRY_OPEN} ) );
	$ENV{DAL_RETRY_OPEN} = 5 unless ( defined ( $ENV{DAL_RETRY_OPEN} ) );		#	060208 - Jake - SCREW 1807

	&ISDCPipeline::PipelineStep (
		"step"                        => "$proc - IBIS Analysis $att{proctype}",
		"program_name"                => "ibis_science_analysis",
		"par_ogDOL"                   => "$ogDOL",
		"par_startLevel"              => "$startLevel",
		"par_endLevel"                => "$endLevel",
		"par_IC_Group"                => "$att{IC_Group}",
		"par_CAT_refCat"              => "$refcat",
		"par_SWITCH_disableIsgri"     => "$disableIsgri",
		"par_SWITCH_disablePICsIT"    => "$disablePICsIT",
		"par_SCW1_BKG_I_isgrBkgDol"   => "$SCW1_BKG_I_isgrBkgDol",
		"par_SCW1_BKG_I_isgrUnifDol"  => "$SCW1_BKG_I_isgrUnifDol",
		"par_IBIS_II_ChanNum"         => "$II_ChanNum",	#	051208 - Jake
		"par_IBIS_II_E_band_min"      => "$II_ChanMin",
		"par_IBIS_II_E_band_max"      => "$II_ChanMax",
		"par_OBS1_SearchMode"         => "$SearchMode",
		"par_OBS1_DoPart2"            => "$DoPart2",
		"par_OBS1_ToSearch"           => "$ToSearch",
		"par_OBS1_MapSize"            => "$MapSize",
		"par_SCW1_ICOR_riseDOL"       => "$ICOR_riseDOL",
		"par_rebinned_corrDol_ima"    => "$rebin_corr",
		"par_IC_Alias"                => "$ENV{IC_ALIAS}",
		"par_PICSIT_inCorVar"         => "$PICSIT_inCorVar",
		"par_SCW1_GTI_PICsIT"         => "$GTI_PICsIT",		#	"ATTITUDE P_SGLE_DATA_GAPS P_MULE_DATA_GAPS",
		"par_GENERAL_levelList"       => "$levelList",		#	"PRP,COR,GTI,DEAD,BIN_I,BKG_I,CAT_I,IMA,IMA2,BIN_S,SPE,LCR,COMP,CLEAN",
		"par_SCW1_BKG_I_method_cor"   => "$method_cor",
		"par_SCW1_GTI_BTI_Names"      => "$BTI_Names",                 
		"par_SCW1_BKG_I_brPifThreshold" => "$brPifThreshold",	#	060705 - Jake - added for ibis_scripts 8.7
		"par_OBS1_MinCatSouSnr"       => "$MinCatSouSnr",
		"par_OBS1_SouFit"             => "$SouFit",




#	SHOULD I JUST COMMENT THESE OUT OR SHOULD I REPLACE THEM WITH THEIR ORIGINAL VALUES????????



		#	universally different than default (maybe)
		"par_SWITCH_disableCompton"   => "yes",		#	don't think that we ever use Compton
		"par_IBIS_II_inEnergyValues"  => "energy_bands.fits[1]",	#	not used unless IBIS_II_ChanNum = -1, so can hard code this
		"par_IBIS_NoisyDetMethod"     => "1",		#	060116 - SCREW 1783 denied so this stays at 1
		"par_ILCR_e_max"              => "40 300",                                   # "40 60 100 200"
		"par_ILCR_e_min"              => "15 40",                                    # "20 40 60 100"
		"par_ILCR_num_e"              => "2",                                        # "4"
		"par_OBS1_MinNewSouSnr"       => "5",                                        # "7."
		"par_OBS2_imgSel"             => "EVT_TYPE==SINGLE && E_MIN==252 && E_MAX==336",
		"par_SCW1_BIN_cleanTrk"       => "0",# "1"
		"par_SCW1_BKG_P_method"       => "0",
		"par_SCW1_BKG_picsMUnifDOL"   => "",
		"par_SCW1_BKG_picsSUnifDOL"   => "",
		"par_SCW1_GTI_ISGRI"          => "ATTITUDE ISGRI_DATA_GAPS",
		"par_SCW1_GTI_TimeFormat"     => "OBT",
		"par_SCW2_BKG_P_method"       => "0",
		"par_SCW2_ISPE_MethodFit"     => "1",





		"par_SCW1_BIN_P_PicsCxt"        => "",		#	060705 - Jake - added for ibis_scripts 8.7
		"par_SCW1_BKG_I_brSrcDOL"       => "",		#	060705 - Jake - added for ibis_scripts 8.7
		"par_SCW1_BKG_I_pif"            => "",		#	060705 - Jake - added for ibis_scripts 8.7
		"par_SCW1_BKG_aluAtt"           => "",		#	060705 - Jake - added for ibis_scripts 8.7
		"par_SCW1_BKG_leadAtt"          => "",		#	060705 - Jake - added for ibis_scripts 8.7
		"par_SCW1_BKG_tungAtt"          => "",		#	060705 - Jake - added for ibis_scripts 8.7
		"par_SCW1_GTI_attTolerance_X"   => "0.5",	#	060705 - Jake - added for ibis_scripts 8.7
		"par_SCW1_GTI_attTolerance_Z"   => "3.0",	#	060705 - Jake - added for ibis_scripts 8.7
		"par_SCW1_ICOR_protonDOL"       => "",		#	060705 - Jake - added for ibis_scripts 8.7
		"par_SCW1_ICOR_rtcDOL"          => "",		#	060705 - Jake - added for ibis_scripts 8.7
		"par_SCW1_ICOR_switDOL"         => "",		#	060705 - Jake - added for ibis_scripts 8.7
		"par_SCW2_BIN_P_PicsCxt"        => "",		#	060705 - Jake - added for ibis_scripts 8.7


		#	still default values (I think)
		"par_CAT_usrCat"              => "",
		"par_GENERAL_clobber"         => "yes",
		"par_IBIS_IPS_ChanNum"        => "0",
		"par_IBIS_IPS_E_band_max_m"   => "600 1000 10000",        
		"par_IBIS_IPS_E_band_max_s"   => "600 1000 10000",        
		"par_IBIS_IPS_E_band_min_m"   => "170 600 1000",          
		"par_IBIS_IPS_E_band_min_s"   => "170 600 1000",          
		"par_IBIS_IPS_corrPDH"        => "0",                                                  
		"par_IBIS_P_convFact"         => "7.0",
		"par_IBIS_SI_ChanNum"         => "-1",
		"par_IBIS_SI_E_band_max"      => "",
		"par_IBIS_SI_E_band_min"      => "",
		"par_IBIS_SI_inEnergyValues"  => "",
		"par_IBIS_SM_inEnergyValues"  => "",
		"par_IBIS_SPS_ChanNum"        => "51",
		"par_IBIS_SPS_E_band_max_m"   => "",                                      
		"par_IBIS_SPS_E_band_max_s"   => "",                                      
		"par_IBIS_SPS_E_band_min_m"   => "",                                              
		"par_IBIS_SPS_E_band_min_s"   => "",                                              
		"par_IBIS_SPS_corrPDH"        => "0",                                                  
		"par_IBIS_SP_ChanNum"         => "51",
		"par_IBIS_SS_inEnergyValues"  => "",
		"par_IBIS_max_rise"           => "90",
		"par_IBIS_min_rise"           => "7",
		"par_IBIS_IP_ChanNum"         => "3",
		"par_IBIS_IP_E_band_max_m"    => "600 1000 13500",
		"par_IBIS_IP_E_band_max_s"    => "600 1000 10000",
		"par_IBIS_IP_E_band_min_m"    => "350 600 1000",
		"par_IBIS_IP_E_band_min_s"    => "175 600 1000",
		"par_IBIS_SP_E_band_max_m"    => "",
		"par_IBIS_SP_E_band_max_s"    => "",
		"par_IBIS_SP_E_band_min_m"    => "",
		"par_IBIS_SP_E_band_min_s"    => "",
		"par_ILCR_delta_t"            => "100",                                    
		"par_ILCR_select"             => "",                                                
		"par_ISGRI_mask"              => "",
		"par_OBS1_CAT_class"          => "",
		"par_OBS1_CAT_date"           => "-1.",
		"par_OBS1_CAT_fluxDef"        => "",
		"par_OBS1_CAT_fluxMax"        => "",
		"par_OBS1_CAT_fluxMin"        => "",
		"par_OBS1_CAT_radiusMax"      => "20",
		"par_OBS1_CAT_radiusMin"      => "0",
		"par_OBS1_CleanMode"          => "1",
		"par_OBS1_DataMode"           => "0",
		"par_OBS1_MapAlpha"           => "0.0",
		"par_OBS1_MapDelta"           => "0.0",
		"par_OBS1_PixSpread"          => "1",
		"par_OBS1_ScwType"            => "POINTING",
		"par_OBS1_aluAtt"             => "",
		"par_OBS1_covrMod"            => "",
		"par_OBS1_deco"               => "",
		"par_OBS1_leadAtt"            => "",
		"par_OBS1_tungAtt"            => "",
		"par_OBS1_ExtenType"          => "0",
		"par_OBS1_FastOpen"           => "1",
		"par_OBS1_NegModels"          => "0",
		"par_OBS2_detThr"             => "3.0",                                                     
		"par_OBS2_projSel"            => "TAN",
		"par_PICSIT_detThr"           => "3.0",                           
		"par_PICSIT_outVarian"        => "0",
		"par_PICSIT_deco"             => "",
		"par_PICSIT_source_DEC"       => "",
		"par_PICSIT_source_RA"        => "",
		"par_PICSIT_source_name"      => "",
		"par_SCW1_BIN_I_idxLowThre"   => "",
		"par_SCW1_BIN_P_HepiLut"      => "",                                                 
		"par_SCW1_BIN_P_inDead"       => "",
		"par_SCW1_BIN_P_inGTI"        => "",
		"par_SCW1_BKG_I_method_int"   => "1",
		"par_SCW1_BKG_badpix"         => "yes",                 
		"par_SCW1_BKG_divide"         => "no",                  
		"par_SCW1_BKG_flatmodule"     => "no",              
		"par_SCW1_BKG_picsMBkgDOL"    => "",
		"par_SCW1_BKG_picsSBkgDOL"    => "",
		"par_SCW1_BIN_I_idxNoisy"     => "",
		"par_SCW1_GTI_Accuracy"       => "any",
		"par_SCW1_GTI_BTI_Dol"        => "",                           
		"par_SCW1_GTI_LimitTable"     => "",
		"par_SCW1_GTI_SCI"            => "",
		"par_SCW1_GTI_SCP"            => "",
		"par_SCW1_GTI_gtiUserI"       => "",
		"par_SCW1_GTI_gtiUserP"       => "",
		"par_SCW1_ICOR_GODOL"         => "",
		"par_SCW1_ICOR_idxSwitch"     => "",
		"par_SCW1_ICOR_probShot"      => "0.01",
		"par_SCW1_ISGRI_event_select" => "",
		"par_SCW1_PCOR_enerDOL"       => "",
		"par_SCW1_veto_mod"           => "",
		"par_SCW2_BIN_I_idxLowThre"   => "",
		"par_SCW2_BIN_P_HepiLut"      => "",                                                 
		"par_SCW2_BIN_P_inDead"       => "",
		"par_SCW2_BIN_P_inGTI"        => "",
		"par_SCW2_BIN_cleanTrk"       => "0",
		"par_SCW2_BKG_I_isgrBkgDol"   => "",
		"par_SCW2_BKG_I_method_cor"   => "0",
		"par_SCW2_BKG_I_method_int"   => "1",
		"par_SCW2_BKG_badpix"         => "yes",                         
		"par_SCW2_BKG_divide"         => "no",                          
		"par_SCW2_BKG_flatmodule"     => "no",                      
		"par_SCW2_BKG_picsMBkgDOL"    => "-",
		"par_SCW2_BKG_picsMUnifDOL"   => "",
		"par_SCW2_BKG_picsSBkgDOL"    => "-",
		"par_SCW2_BKG_picsSUnifDOL"   => "",
		"par_SCW2_ISGRI_event_select" => "",
		"par_SCW2_ISPE_DataMode"      => "0",
		"par_SCW2_ISPE_MethodInt"     => "1",
		"par_SCW2_ISPE_aluAtt"        => "",
		"par_SCW2_ISPE_idx_isgrResp"  => "",
		"par_SCW2_ISPE_isgrUnifDol"   => "",
		"par_SCW2_ISPE_leadAtt"       => "",
		"par_SCW2_ISPE_tungAtt"       => "",
		"par_SCW2_PIF_filter"         => "",                            
		"par_SCW2_cat_for_extract"    => "",               
		"par_SCW2_catalog"            => "",                                       
		"par_SCW2_deccolumn"          => "DEC_FIN",                                      
		"par_SCW2_racolumn"           => "RA_FIN",                                                
		"par_SCW2_BIN_I_idxNoisy"     => "",
		"par_SCW2_ISPE_isgrarf"       => "",
		"par_SWITCH_osimData"         => "NO",
		"par_chatter"                 => "2",
		"par_corrDol"                 => "",                                                                            
		"par_staring"                 => "no",
		"par_sum_spectra"             => "no",
		"par_tolerance"               => "0.0001",
		"par_rebin_arfDol"            => "",
		"par_rebin_slope"             => "-2",
		"par_rebinned_backDol_ima"    => "",
		"par_rebinned_backDol_lc"     => "",
		"par_rebinned_backDol_spe"    => "",
		"par_rebinned_corrDol_lc"     => "",
		"par_rebinned_corrDol_spe"    => "",
		);

	delete $ENV{DAL_RETRY_OPEN} unless ( defined ( $dal_retry_open_existed ) );		#	060208 - Jake - SCREW 1807
	$ENV{DAL_RETRY_OPEN} = $dal_retry_open_existed if ( defined ( $dal_retry_open_existed ) );

	&ISDCPipeline::RunProgram("$myrm GNRL-REFR-CAT.fits")
		if ( ( -e "GNRL-REFR-CAT.fits" ) && ( $ENV{PROCESS_NAME} =~ /cssscw|csaob1/ ) );

	&NewStuff ( $ogDOL);

	return;
} # end of ISA


######################################################################


sub NewStuff {
	my ( $ogDOL ) = @_;
	my ( $scwid, $revno, $og, $inst, $INST, $instdir, $OG_DATAID, $OBSDIR ) = &SSALIB::ParseOSF();

	&ISDCPipeline::PipelineStep (
		"step"         => "src_collect",
		"program_name" => "src_collect",
		"par_group"    => "$ogDOL",
		"par_extname"  => "",
		"par_instName" => "DEFAULT",
		"par_results"  => "src_out.fits",
		"par_select"   => "",
		"par_attach"   => "no",
		"par_chatter"  => "2",
		);

	#	due to a bug in ftools, the $PARFILES/$PFILES variables need to be shortened, so...
	my $original_pfiles   = $ENV{PFILES};
	my $original_parfiles = $ENV{PARFILES};
	$ENV{PARFILES} = "/tmp/$$-ftools/";
	system ( "mkdir $ENV{PARFILES}" );

	my ($retval,@result,@header);
	($retval,@result) = &ISDCPipeline::RunProgram (
		"fdump infile=src_out.fits outfile=STDOUT columns=- rows=- prhead=no pagewidth=256 page=no wrap=yes showrow=no showunit=no showscale=no fldsep=,"
		);
	
	my %source;
	open SRCINFO, "> orig_srcinfo.txt";

	foreach ( @result ) {
		next if ( /^\s*$/ );
		next unless ( ( /^\s*SWID\s*SOURCE_ID\s*NAME/ )
			|| ( /GRS 1758-258/ )
			|| ( /Ginga 1826-24/ )
			|| ( /Cyg X-1/ )
			|| ( /Cyg X-3/ )
			);
		my @columns;
		if ( /^\s*SWID\s*SOURCE_ID\s*NAME/ ) {
			@columns = split /\s+/;
			$columns[0] = sprintf "# %10s", $columns[0];
		} else {
			@columns = split /\s*,\s*/;
			$columns[2] =~ s/ /_/g;
			next if ( $columns[13] =~ /INDEF/ );
			$source{$columns[2]}{"SOURCE_ID"}  = $columns[1];
			$source{$columns[2]}{"RA_FIN"}     = $columns[3];
			$source{$columns[2]}{"DEC_FIN"}    = $columns[4];
			$source{$columns[2]}{"FIN_RD_ERR"} = $columns[5];
			$source{$columns[2]}{"DETSIG"}     = $columns[9];
			$source{$columns[2]}{"FLUX_ERR"}   = $columns[13];
		}

#	SWID    12A
#	SOURCE_ID       16A
#	NAME    20A
#	RA_FIN 1E deg
#	DEC_FIN 1E deg
#	FIN_RD_ERR      1E deg
#	DETSIG  1E deg
#	FLUX_ERR        1E count/s

		printf SRCINFO "%12s %18s %14s %14s %14s %14s %14s %14s\n",
			$columns[0],
			$columns[1],
			$columns[2],
			$columns[3],
			$columns[4],
			$columns[5],
			$columns[9],
			$columns[13];
	}
	close SRCINFO;		#	This file is becoming obsolete

	###########################################################################
	#
	#		ONLY IF BOTH SOURCES WERE FOUND ....
	#
	if ( keys(%source) == 2 ) {
		my $revdir = &ISDCLIB::FindDirVers ( "/isdc/arc/rev_2/scw/$revno/rev" );
		&Error ( "&ISDCLIB::FindDirVers ( \"/isdc/arc/rev_2/scw/$revno/rev\" ) failure!" ) unless ( $revdir );
		&Error ( "No $revdir/osm/intl_avg_hk.fits.gz found!" ) unless ( -e "$revdir/osm/intl_avg_hk.fits.gz" );
		&ISDCPipeline::RunProgram (
			"fextract infile=\"$revdir/osm/intl_avg_hk.fits[INTL-PLM.-AVG][SWID==\'$scwid\']\" outfile=intl_avg_hk.fits"
			);
		
		chomp ( my $swg = `$myls scw/0*/swg_ibis.fits` );
		($retval,@header) = &ISDCPipeline::RunProgram (
			"fdump infile=$swg+1 outfile=STDOUT columns=- rows=- prhead=yes prdata=no pagewidth=256 page=no"
			);
		my ( $ra_scx, $ra_scz, $dec_scx, $dec_scz, $tstart, $tstop );
		foreach ( @header ) {
			my @vals = split /\s+/;
			$ra_scx  = $vals[2] if ( /^RA_SCX/ );
			$dec_scx = $vals[2] if ( /^DEC_SCX/ );
			$ra_scz  = $vals[2] if ( /^RA_SCZ/ );
			$dec_scz = $vals[2] if ( /^DEC_SCZ/ );
			$tstart  = $vals[2] if ( /^TSTART/ );
			$tstop   = $vals[2] if ( /^TSTOP/ );
		}
		&Error ( "RA_SCX not found!" )  unless ( $ra_scx );
		&Error ( "DEC_SCX not found!" ) unless ( $dec_scx );
		&Error ( "RA_SCZ not found!" )  unless ( $ra_scz );
		&Error ( "DEC_SCZ not found!" ) unless ( $dec_scz );
		&Error ( "TSTART not found!" )  unless ( $tstart );
		&Error ( "TSTOP not found!" )   unless ( $tstop );

		open SRCINFO, "> srcinfo.txt";
		printf SRCINFO "# %16s %14s %14s %14s %14s %14s %14s %18s %14s %14s %14s %14s %14s %14s %18s %18s %18s %18s %18s %18s\n",
			"SOURCE_ID1",
			"NAME1",
			"RA_FIN1",
			"DEC_FIN1",
			"FIN_RD_ERR1",
			"DETSIG1",
			"FLUX_ERR1",
			"SOURCE_ID2",
			"NAME2",
			"RA_FIN2",
			"DEC_FIN2",
			"FIN_RD_ERR2",
			"DETSIG2",
			"FLUX_ERR2",
			"TSTART",
			"TSTOP",
			"RA_SCX",
			"DEC_SCX",
			"RA_SCZ",
			"DEC_SCZ";

		foreach ( sort keys(%source) ) {
			printf SRCINFO "%18s %14s %14s %14s %14s %14s %14s ",
				$source{$_}{"SOURCE_ID"},
				$_,
				$source{$_}{"RA_FIN"},
				$source{$_}{"DEC_FIN"},
				$source{$_}{"FIN_RD_ERR"},
				$source{$_}{"DETSIG"},
				$source{$_}{"FLUX_ERR"};
		}
		printf SRCINFO "%18s %18s %18s %18s %18s %18s\n", $tstart, $tstop, $ra_scx, $dec_scx, $ra_scz, $dec_scz ;
		close SRCINFO;		

		($retval,@header) = &ISDCPipeline::RunProgram (
			"fcreate cdfile=/isdc/integration/isdc_int/sw/dev/prod/opus/pipeline_lib/srcinfo.lis datafile=srcinfo.txt outfile=srcinfo.fits"
			);

		($retval,@header) = &ISDCPipeline::RunProgram (
			"faddcol infile=intl_avg_hk.fits colfile=srcinfo.fits colname=-"
			);
	} else {
		&Message ( "Perl says found ".keys(%source)." sources. (Not 2)\n" );
	}

	system ( "/bin/rm -rf $ENV{PARFILES}" );
	$ENV{PARFILES} = $original_parfiles;
	$ENV{PFILES}   = $original_pfiles;

	return;
}

#	last line
