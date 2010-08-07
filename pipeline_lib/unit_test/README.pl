#! /bin/sh
eval '  exec perl -x $0 ${1+"$@"} '
#! perl

#BEGIN { unshift (@INC, "../"); }		#	effectively adds pipeline_lib to PERLLIB, I think

#	eval `envv ... does not work.  can't find setenv and thinks its in sh
#	should write a perl "envv" equivalent

use strict;
use File::Basename;
use lib "$ENV{ISDC_ENV}/opus/pipeline_lib/";
use ISDCLIB;
use OPUSLIB;
use SSALIB;
use ISDCPipeline;
use UnixLIB;
use TimeLIB;
use Datasets;

my $mycleanup = "$ENV{ISDC_ENV}/opus/pipeline_lib/cleanup.pl --do_not_confirm ";
#my $mycleanup = "$ENV{ISDC_ENV}/opus/pipeline_lib/cleanup.pl --DEBUG --do_not_confirm ";

chomp ( $ENV{PWD} = `pwd` );		#	because $ENV{PWD} is $ISDC_OPUS/pipeline_lib when running in Perl

print "\n###############################################################################\n";
print "#######\n";
print "#######     RUNNING THE PIPELINE_LIB UNIT TEST \n";
print "#######\n";
print "###############################################################################\n\n\n";

print "#\n#\tCleaning up from previous runs.\n#\n";
foreach ( "opus_work","opus_misc_rep","test_data","test_data.orig","out","outref","cleanup" ) {
	next unless ( `$myls $_ 2> /dev/null` );
	print "#\t\tRemoving $_\n";
	system ( "$mychmod -R +w $_" );
	system ( "$myrm -rf $_" );
}
print "#\n";

#-------------------------------------------------------------------------------------

my $OS = `uname`;
chomp $OS;
my $osdir = ( $OS =~ /SunOS/i ) ? "sparc_solaris" : "linux";
my ( $retval, @result );

print "Setting up lots of environment variables for OS=$OS.\n";

my @TEST_DATA_TGZ;		#	DON'T USE ANY VERSIONS THAT HAVEN'T BEEN DELIVERED YET!
push @TEST_DATA_TGZ, "consrev-3.8_test_data.tar.gz";
push @TEST_DATA_TGZ, "consrev-3.9_outref.tar.gz";		#	use this bc contains the rev *index* files
push @TEST_DATA_TGZ, "consssa-1.7_outref.tar.gz";
push @TEST_DATA_TGZ, "conssa-2.6_outref.tar.gz";

my @OUTREF_TGZ;			
push @OUTREF_TGZ, "pipeline_lib-9.6_outref.tar.gz";

$ENV{REP_BASE_PROD}  = "$ENV{PWD}/test_data";					print "\$ENV{REP_BASE_PROD} is $ENV{REP_BASE_PROD}\n";
$ENV{SCWDIR}         = "$ENV{REP_BASE_PROD}/scw/"; 
$ENV{OPUS_WORK}      = "$ENV{PWD}/opus_work";					print "\$ENV{OPUS_WORK} is $ENV{OPUS_WORK}\n";
$ENV{OPUS_HOME_DIR}  = "$ENV{OPUS_WORK}/opus/";					print "\$ENV{OPUS_HOME_DIR} is $ENV{OPUS_HOME_DIR}\n";
$ENV{OPUS_MISC_REP}  = "$ENV{PWD}/opus_misc_rep";				print "\$ENV{OPUS_MISC_REP} is $ENV{OPUS_MISC_REP}\n";
$ENV{ISDC_SITE}      = "";												print "\$ENV{ISDC_SITE} is $ENV{ISDC_SITE}\n";
$ENV{ISDC_OPUS}      = "$ENV{ISDC_ENV}/opus";					print "\$ENV{ISDC_OPUS} is $ENV{ISDC_OPUS}\n";
$ENV{SOGS_DISK}      = "/isdc/sw/opus/5v4b/opus";				print "\$ENV{SOGS_DISK} is $ENV{SOGS_DISK}\n";
$ENV{DEBUGIN}        = "0";											print "\$ENV{DEBUGIN} is $ENV{DEBUGIN}\n";	#	used in consssa code

my @instlist = ( "omc","jmx1", "jmx2", "isgri", "picsit", "spi" );
my @scwlist  = ( 
	"002400000012", "002400050010", "002400050020", "002400050031", "002400090010",
	"002500000041", "002500000051", "002500000061", "002500010010" );
my @revlist  = ( 
	"0003_20021023151210_00_sdp", "0004_20021027171324_00_omd", "0013_20021122192241_00_sdf", "0014_20021125080213_00_j1f",
	"0014_20021125075853_00_j1d", "0014_20021125082811_00_j2f", "0014_20021125082357_00_j2d", "0024_20021226235542_00_itv",
	"0024_20021226220948_00_irv", "0024_20021226220109_00_ire", "0024_20021226230117_00_ire", "0024_20021226220133_00_irc",
	"0024_20021226230203_00_irn", "0024_20021226233227_00_irn", "0024_20021226235606_00_j1t", "0024_20021226235614_00_j2t",
	"0024_20021226235627_00_omt", "0024_20021226235532_00_sct", "0024_20021226235554_00_stv", "0025_20021227074907_00_idp",
	"0025_20021227054859_00_irv", "0025_20021227085924_00_irv", "0025_20021227060629_00_ire", "0025_20021227070629_00_ire",
	"0025_20021227081604_00_irc", "0025_20021227073956_00_irn", "0025_20021227081019_00_irn", "0025_20021227073430_00_j1e",
	"0025_20021227081542_00_jm1", "0025_20021227073530_00_j2e", "0025_20021227080902_00_jm2", "0025_20021228074420_00_odc",
	"0025_20021227084813_00_prc", "0036_20030131204711_00_idp" );

$ENV{OPUS_DEFINITIONS_DIR}  = "$ENV{OPUS_HOME_DIR}";
$ENV{OPUS_DEFINITIONS_DIR} .= " ISDC_OPUS:/consscw/";
$ENV{OPUS_DEFINITIONS_DIR} .= " ISDC_OPUS:/consinput/";
$ENV{OPUS_DEFINITIONS_DIR} .= " ISDC_OPUS:/consrev/";
$ENV{OPUS_DEFINITIONS_DIR} .= " ISDC_OPUS:/conssa/";
$ENV{OPUS_DEFINITIONS_DIR} .= " ISDC_OPUS:/consssa/";
$ENV{OPUS_DEFINITIONS_DIR} .= " ISDC_OPUS:/adp/";
$ENV{OPUS_DEFINITIONS_DIR} .= " ISDC_OPUS:/pipeline_lib/";
print "\$ENV{OPUS_DEFINITIONS_DIR} is $ENV{OPUS_DEFINITIONS_DIR}\n";

my @arr = split ":", $ENV{PERL5LIB};
print "\$ENV{PERL5LIB} is ...\n";								foreach ( @arr ) { print "\t$_\n"; }
$ENV{PERL5LIB} .= "$ENV{ISDC_OPUS}/pipeline_lib";
print "\$ENV{PERL5LIB} is now ...\n";							foreach ( @arr ) { print "\t$_\n"; }

@arr = split ":", $ENV{PATH};
print "\$ENV{PATH} is ...\n";										foreach ( @arr ) { print "\t$_\n"; }
$ENV{PATH} .= ":$ENV{ISDC_OPUS}/pipeline_lib";
$ENV{PATH} .= ":$ENV{SOGS_DISK}/bin/$osdir";
print "\$ENV{PATH} is now ...\n";								foreach ( @arr ) { print "\t$_\n"; }

@arr = split ":", $ENV{LD_LIBRARY_PATH};
print "\$ENV{LD_LIBRARY_PATH} is ...\n";						foreach ( @arr ) { print "\t$_\n"; }
unshift ( @arr, "$ENV{SOGS_DISK}/lib/$osdir" );
$ENV{LD_LIBRARY_PATH} = join( ":", @arr );
print "\$ENV{LD_LIBRARY_PATH} is now ...\n";					foreach ( @arr ) { print "\t$_\n"; }

system ( "env | sort > env_dump.txt" );

system ( "$mymkdir -p $ENV{OPUS_WORK}" );
system ( "$mymkdir -p $ENV{OPUS_HOME_DIR}" );

#-------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------

print "#######     Installing OPUS_WORK with isdc_opus_install.csh\n";
#	system "$ENV{ISDC_OPUS}/pipeline_lib/isdc_opus_install.csh --system=adp --quiet";
#	die "#######     isdc_opus_install.csh return status was non-zero:$?\n" if ( $? );
#	apparently can't install 2 different systems ...

system ( "$ENV{ISDC_OPUS}/pipeline_lib/isdc_opus_install.csh --opus_version=5v4b --system=cons --quiet" );
die "#######     isdc_opus_install.csh return status was non-zero:$?\n" if ( $? );

#	... therefore
system ( "$mymkdir -p $ENV{OPUS_WORK}/adp/input" );
system ( "$mymkdir -p $ENV{OPUS_WORK}/adp/obs" );
system ( "$mymkdir -p $ENV{OPUS_WORK}/adp/logs" );
system ( "$mymkdir -p $ENV{OPUS_WORK}/adp/scratch" );
system ( "$mymkdir -p $ENV{OPUS_WORK}/adp/pfiles" );

#-------------------------------------------------------------------------------------

foreach ( @TEST_DATA_TGZ ) {
	system ( "$mymkdir -p $ENV{REP_BASE_PROD}/idx" ) unless ( -d "$ENV{REP_BASE_PROD}/idx" );
	print "#######     Searching for $_\n";
	if ( -e "$ENV{ISDC_TEST_DATA_DIR}/$_" ) {
		print "#######     Gunzipping $ENV{ISDC_TEST_DATA_DIR}/$_\n";
		system ( "$mygunzip -c $ENV{ISDC_TEST_DATA_DIR}/$_ | $mytar xf -" );
	} elsif ( -e "/isdc/testdata/unit_test/$_" ) {
		print "#######     Gunzipping /isdc/testdata/unit_test/$_\n";
		system ( "$mygunzip -c /isdc/testdata/unit_test/$_ | $mytar xf -" );
	} else {
		print "#######     WARNING: $_ not found!\n";
	}
}

if ( ( -d "outref" ) && ( -d "$ENV{REP_BASE_PROD}" ) ) {
	print "#######     Manually modifying test_data\n";
	system ( "$myrm -rf outref/obs_*/sm*" );			#	perhaps don't do this to test something else
	system ( "$mymv     outref/obs_*     $ENV{REP_BASE_PROD}/" );
	system ( "$mychmod +w outref/obs" );
	system ( "$mymv     outref/obs       $ENV{REP_BASE_PROD}/" );
	system ( "$myrm -rf $ENV{REP_BASE_PROD}/scw" );	
	system ( "$mymv  -f outref/scw       $ENV{REP_BASE_PROD}/" );		#	NEW!
	system ( "$mymv     outref/idx/rev/* $ENV{REP_BASE_PROD}/idx/rev/" );		#	NEW!
	system ( "$myrm -rf outref" );	
}

foreach ( @OUTREF_TGZ ) {
	print "#######     Searching for outref $_\n";
	if ( -e "$ENV{ISDC_TEST_DATA_DIR}/$_" ) {
		print "#######     Gunzipping $ENV{ISDC_TEST_DATA_DIR}/$_\n";
		system ( "$mygunzip -c $ENV{ISDC_TEST_DATA_DIR}/$_ | $mytar xf -" );
	} elsif ( -e "/isdc/testdata/unit_test/$_" ) {
		print "#######     Gunzipping /isdc/testdata/unit_test/$_\n";
		system ( "$mygunzip -c /isdc/testdata/unit_test/$_ | $mytar xf -" );
	} else {
		print "#######     WARNING: $_ not found!\n";
	}
}

if ( -d "$ENV{REP_BASE_PROD}" ) {
	system ( "$mychmod -R +w $ENV{REP_BASE_PROD}" );
	system ( "$myln -s /isdc/arc/rev_2/idx/ic $ENV{REP_BASE_PROD}/idx/" );
	system ( "$myln -s /isdc/arc/rev_2/ic     $ENV{REP_BASE_PROD}/" );
}

#-------------------------------------------------------------------------------------

print "\nBelow should be an empty opus blackboard.\n";
system ( "$ENV{ISDC_OPUS}/pipeline_lib/bb_sum.pl" );
print "\n";

#-------------------------------------------------------------------------------------
#
#	The data is all there now.  Perhaps run some pipeline_lib functions
#
#-------------------------------------------------------------------------------------

#	more variables to test some ISDCPipeline.pm functions
$ENV{IC_ALIAS}     = "CONS";
$ENV{OSF_DATA_ID}  = "ire"; 
$ENV{PROCESS_NAME} = "consscw"; 
$ENV{OSF_DATASET}  = "002500000051";
$ENV{PARFILES}     = "$ENV{REP_BASE_PROD}/";		#	this must be set before running PipelineStep
my $out            = "$ENV{PWD}/out";
$ENV{LOG_FILES}    = "$out";

system ( "$mymkdir -p $ENV{LOG_FILES}" ) unless ( -d $ENV{LOG_FILES} );
#	END : more variables to test some ISDCPipeline.pm functions
	
if ( -d $ENV{SCWDIR} ) {
	print "#######     \n";
	print "#######     Testing some ISDCPipeline functions.\n";
	print "#######     \n";
	print "#######     PFILES   : $ENV{PFILES}\n";
	print "#######     PARFILES : $ENV{PARFILES}\n";
	print "#######     LOG_FILES : $ENV{LOG_FILES}\n";
	print "#######     \n";
	
	#	use .log extension for some of these so that isdc_dircmp correctly parses 
	#	out the paths before trying to find any differences.

	open  FINDSCW, "> $out/FindScw.log";
	my $FindScw = &ISDCPipeline::FindScw ( "002500000051" );
	print FINDSCW "$FindScw\n";
	close FINDSCW;
	
	open  FINDPREV, "> $ENV{PWD}/out/FindPrev";
	print FINDPREV &ISDCPipeline::FindPrev ( "$FindScw/swg.fits" )."\n";
	close FINDPREV;
	
	open  REVNO, "> $out/RevNo";
	my $revnotest = &ISDCPipeline::RevNo ( "002500000051" );
	print REVNO "$revnotest\n";
	close REVNO;
	
	open  SEQNO, "> $out/SeqNo";
	my $seqno = &ISDCPipeline::SeqNo ( "002500000051" );
	print SEQNO "$seqno\n";
	close SEQNO;
	
	open  FINDDIRVERS, "> $out/FindDirVers.log";
	my $FindDirVers = &ISDCLIB::FindDirVers ( "$ENV{SCWDIR}/$revnotest/002500000051" );
	print FINDDIRVERS "$FindDirVers\n";
	close FINDDIRVERS;
	
	open  PARSEOSF, "> $out/ParseOSF";
	my ( $hextime, $status1, $name, $type, $DCF, $command1 ) =
		&OPUSLIB::ParseOSF ( "3db18375-ccc_____________________.0087_arc_prep___________________________________________________-arc-000-____" );
	print PARSEOSF "$hextime, $status1, $name, $type, $DCF, $command1\n";
	close PARSEOSF;

	open  HEXTIME2LOCAL, "> $out/HexTime2Local";
	print HEXTIME2LOCAL &TimeLIB::HexTime2Local ( "$hextime" )."\n";
	close HEXTIME2LOCAL;

	open  PARSEPSTAT, "> $out/ParsePSTAT";
	my ( $pid, $process, $status2, $time, $path, $node, $command2 ) =
		&OPUSLIB::ParsePSTAT ( "00000dda-nswst____-idle___________.3dd4b4ac-nrtscw___-nrtscw2_____________-____" );
	print PARSEPSTAT "$pid, $process, $status2, $time, $path, $node, $command2\n";
	close PARSEPSTAT;

	my $mytime = &TimeLIB::MyTime();
	print "MyTime : $mytime\n";
	print `$myecho OK > $out/MyTime` if ( $mytime );
	
	my $mytimesec = &TimeLIB::MyTimeSec();
	print "MyTimeSec : $mytimesec\n";
	print `$myecho OK > $out/MyTimeSec` if ( $mytimesec );
	
	open  PROCSTEP, "> $out/ProcStep";
	print PROCSTEP &ISDCLIB::ProcStep()."\n";		#	Should print " (CONS)"
	close PROCSTEP;
	
	open  UTCOPS, "> $out/UTCops";
	print UTCOPS &TimeLIB::UTCops( utc => "20050830102531" )."\n";
	close UTCOPS;
	
	open  INTERACTIVE, "> $out/Interactive";
	print INTERACTIVE &ISDCPipeline::Interactive()."\n";
	close INTERACTIVE;

	open  DIFFOBTS, "> $out/DiffOBTs";
	print DIFFOBTS &ISDCPipeline::DiffOBTs ( "00000006458748960768", "00000006454974087168" );
	close DIFFOBTS;
	
#	sub MoveLog {


	#	This will create an index with a time stamp of now
	#	ie. 
	#		GNRL-OBSG-GRP-IDX_20050905180047.fits
	&ISDCPipeline::MakeIndex (
		"root"      => "GNRL-OBSG-GRP-IDX",
		"filematch" => "$ENV{REP_BASE_PROD}/obs/*/og*fits",
		"ext"       => "[GROUPING]", 
		"template"  => "GNRL-OBSG-GRP-IDX.tpl",
		"subdir"    => "$out",
		);
	chdir "$ENV{PWD}";	#	because using subdir DOES NOT chdir back to where it was!

	#	This will create a link to the time stamped file
	#	ie.
	#		GNRL-OBSG-GRP-IDX.fits -> GNRL-OBSG-GRP-IDX_20050905180047.fits
	#		GNRL-OBSG-GRP-IDX_20050905180047.fits
   &ISDCPipeline::LinkUpdate (
      "root"   => "GNRL-OBSG-GRP-IDX",
		"subdir" => "$out",
      );
	chdir "$ENV{PWD}";	#	because using subdir DOES NOT chdir back to where it was!

	#	This will replace the link with the real file, but without the time stamp
	#	ie. 
	#		GNRL-OBSG-GRP-IDX.fits
   &ISDCPipeline::LinkReplace(
      "root"   => "GNRL-OBSG-GRP-IDX",
		"subdir" => "$out",
      );
	chdir "$ENV{PWD}";	#	because using subdir DOES NOT chdir back to where it was!

	&ISDCPipeline::GetICIndex ( "structure" => "SPI.-ALRT-LIM", "subIndex" => "$out/SPI.-ALRT-LIM-IDX.fits" );

	&ISDCPipeline::PutAttribute ( "$out/SPI.-ALRT-LIM-IDX.fits", "TEST", "test value", "DAL_CHAR", "Just some testing." );

	open  GETATTR, "> $out/GetAttribute";
	print GETATTR  &ISDCPipeline::GetAttribute ( "$out/SPI.-ALRT-LIM-IDX.fits", "TEST" )."\n";
	close GETATTR;

	open  GETICFILE, "> $out/GetICFile.log";
	print GETICFILE  &ISDCPipeline::GetICFile ( "structure" => "SPI.-LINE-SCT", "select" => "EVT_TYPE == 'SE'" )."\n";
	close GETICFILE;

	#	perhaps should use another as rev 0102 isn't really here
	&ISDCPipeline::CollectIndex (
		"workname" => "$out/CollectIndex.fits",	#	will accept a path
		"template" => "SPI.-COEF-CAL-IDX.tpl",
		"index"    => "$ENV{REP_BASE_PROD}/obs/sosp_010200290010_001.000/gain_coeff_index.fits",
		"sort"     => "OBTFIRST",
		);

	&ISDCPipeline::FindIndex (
		"index"    => "$ENV{SCWDIR}/0024/rev.000/idx/isgri_pxlswtch_index.fits",
		"workname" => "FindIndex.fits",
		"subdir"   => "$out",	#	will not work with a path in the workname
		"required" => 1,		#	error if nothing found
		);
	chdir "$ENV{PWD}";	#	because using subdir DOES NOT chdir back to where it was!

	&ISDCPipeline::WriteAlert (
		"step"    => "Pipeline_lib unit test alert",
		"message" => "Pipeline_lib unit test alert",
		"level"   => 2,
		"subdir"  => "$out",
		"logfile" => "WriteAlertLog",
		"id"      => "500",
		);
	chdir "$ENV{PWD}";	#	because using subdir DOES NOT chdir back to where it was!

	open  CHECKSTRUCTS, "> $out/CheckStructs";
	print CHECKSTRUCTS &ISDCPipeline::CheckStructs ( 
		"$ENV{REP_BASE_PROD}/scw/0025/002500000051.000/swg.fits", ( "SPI.-DPE.-CNV", "SPI.-001.-CNV", "SPI.-008.-CNV" ) )."\n";
	print CHECKSTRUCTS &ISDCPipeline::CheckStructs ( 
		"$ENV{REP_BASE_PROD}/scw/0025/002500000051.000/swg.fits", "SOME-FAKE-STR" )."\n";
	close CHECKSTRUCTS;

	open  GETCOLUMN, "> $out/GetColumn";
	print GETCOLUMN &ISDCLIB::GetColumn ( 
		"$ENV{REP_BASE_PROD}/scw/0025/002500000051.000/swg.fits+5", "GTI_NAME" )."\n";
	close GETCOLUMN;

	open  FINDDOL, "> $out/FindDOL.log";
	print FINDDOL &ISDCPipeline::FindDOL ( 
		"$ENV{REP_BASE_PROD}/scw/0025/002500000051.000/swg.fits", "AUXL-TCOR-HIS" )."\n";
	close FINDDOL;

	open  ROWSIN, "> $out/RowsIn";
	print ROWSIN &ISDCLIB::RowsIn ( 
		"$ENV{REP_BASE_PROD}/scw/0025/002500000051.000/swg.fits", "IBIS-GNRL-GTI" )."\n";			#	should be 21
	close ROWSIN;

	open  CHILDRENIN, "> $out/ChildrenIn";
	print CHILDRENIN &ISDCLIB::ChildrenIn ( 
		"$ENV{REP_BASE_PROD}/scw/0025/002500000051.000/swg.fits", "IBIS-GNRL-GTI-IDX" )."\n";		#	should be 21
	close CHILDRENIN;

	print "#######     \n";
	print "#######     Done testing some ISDCPipeline functions.\n";
	print "#######     \n";
}

delete $ENV{LOG_FILES};
delete $ENV{OSF_DATASET};
print "#######     PFILES   : $ENV{PFILES}\n";

#-------------------------------------------------------------------------------------
#
#	END : The data is all there now.  Perhaps run some pipeline_lib functions
#
#-------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------

print "#######     Starting the consinput pipeline.\n";

foreach ( @scwlist ) {
	my ( $revno ) = ( /^(\d{4})/ );
	my $thisscwdir = "$ENV{SCWDIR}/$revno/$_.000";
	system ( "$mymkdir -p $thisscwdir" ) unless ( -e "$thisscwdir" );

	$ENV{PATH_FILE_NAME} = "consinput";
	$ENV{EVENT_NAME} = "$ENV{OPUS_WORK}/$ENV{PATH_FILE_NAME}/input/$_.trigger";
	system ( "$mytouch $ENV{EVENT_NAME}" );
	$retval = &ISDCPipeline::PipelineStart (
		"pipeline" => "Input Pipeline Start",
		"state"    => "$osf_stati{INP_ST_C}",
		"type"     => "inp",
		);
	system ( "$mymv $ENV{EVENT_NAME} $ENV{EVENT_NAME}_processing" );
}

#	add agelimit of -1 because if its 0, BBUpdate will exit in non-interactive mode
system ( "bb_mod.pl --agelimit=-1 --path=consinput --current_status=cww --new_status=ccc --donotconfirm" );

#-------------------------------------------------------------------------------------

print "#######     Starting the consscw pipeline.\n";

foreach ( @scwlist ) {
	my ( $revno ) = ( /^(\d{4})/ );
	my $thisscwdir = "$ENV{SCWDIR}/$revno/$_.000";
	system ( "$mymkdir -p $thisscwdir" ) unless ( -e "$thisscwdir" );

	$ENV{PATH_FILE_NAME} = "consscw";
	$ENV{EVENT_NAME} = "$ENV{OPUS_WORK}/$ENV{PATH_FILE_NAME}/input/$_.trigger";
	system ( "$mytouch $ENV{EVENT_NAME}" );
	$retval = &ISDCPipeline::PipelineStart (
		"pipeline" => "Scw Pipeline Start",
		"state"    => "$osf_stati{SCW_ST_C}",
		"type"     => "scw",
		);
	system ( "$mymv $ENV{EVENT_NAME} $ENV{EVENT_NAME}_processing" );
}

system ( "bb_mod.pl --agelimit=-1 --path=consscw --current_status=$osf_stati{SCW_ST_C} --new_status=$osf_stati{SCW_COMPLETE} --donotconfirm" );

#-------------------------------------------------------------------------------------

print "#######     Starting the consrev pipeline.\n";
foreach ( @revlist ) {

	$ENV{PATH_FILE_NAME} = "consrev";
	$ENV{EVENT_NAME} = "$ENV{OPUS_WORK}/$ENV{PATH_FILE_NAME}/input/$_.trigger";
	system ( "$mytouch $ENV{EVENT_NAME}" );

	#	0036_20030131204711_00_idp.log -> scw/0036/rev.000/logs/ibis_raw_dump_20030131204711_00_log.txt
	my ( $revno, $time, $vers, $type ) = ( /(\d{4})_(\d{14})_(\d{2})_(\w{3})/ );
	my $logdir = "$ENV{SCWDIR}/$revno/rev.000/logs";
	system ( "$mymkdir -p $logdir" ) unless ( -e "$logdir" );
	my $reallog = "$Datasets::Types{$type}_${time}_${vers}_log.txt";

	$retval = &ISDCPipeline::PipelineStart (
		"pipeline"    => "Rev Pipeline Start",
		"state"       => "$osf_stati{REV_ST_C}",
		"type"        => "rev",
		"reallogfile" => "$logdir/$reallog",
		);
	system ( "$mymv $ENV{EVENT_NAME} $ENV{EVENT_NAME}_processing" );
}

system ( "bb_mod.pl --agelimit=-1 --path=consrev --current_status=$osf_stati{REV_ST_C} --new_status=$osf_stati{REV_COMPLETE} --donotconfirm" );

#-------------------------------------------------------------------------------------

print "#######     Starting the consssa pipeline.\n";
foreach my $scw ( "002400050010", "002500010010" ) {
	foreach my $instr ( @instlist ) {
		next if ( $instr eq "spi" );

		$ENV{PATH_FILE_NAME} = "consssa";
		$ENV{EVENT_NAME} = "$ENV{OPUS_WORK}/$ENV{PATH_FILE_NAME}/input/${scw}_${instr}.trigger";
		system ( "$mytouch $ENV{EVENT_NAME}" );

		#	consssa/input/015700750010_isgri.trigger_processing
		#	consssa/obs/4200572f-ccc_____________________.ssom_015700960010_______________________________________________-scw-OMC-____
		#	consssa/logs/ssii_015700960010.log -> obs_isgri/0157.000/ssii_015700960010/logs/ssii_015700960010_css.txt
		my ( $osfname, $dcf, $inst, $INST, $revno, $scwid ) = &SSALIB::Trigger2OSF ( "$ENV{EVENT_NAME}" );
		$inst =~ s/\d$//;

		my $logdir = "$ENV{REP_BASE_PROD}/obs_$inst/$revno.000/$osfname/logs";
		system ( "$mymkdir -p $logdir" ) unless ( -e "$logdir" );

		$retval = &ISDCPipeline::PipelineStart (
			"pipeline"    => "SSA Pipeline Start",
			"dataset"     => "$osfname", 
			"state"       => "$osf_stati{SSA_ST_C}",
			"type"        => "ssa",
			"reallogfile" => "$logdir/${osfname}_css.txt",
			);
		system ( "$mymv $ENV{EVENT_NAME} $ENV{EVENT_NAME}_processing" );
	}
}

system ( "bb_mod.pl --agelimit=-1 --path=consssa --current_status=$osf_stati{SSA_ST_C} --new_status=$osf_stati{SSA_COMPLETE} --donotconfirm" );

#-------------------------------------------------------------------------------------

print "#######     Starting the conssma pipeline.\n";

$ENV{PATH_FILE_NAME} = "consssa";

system ( "$mycp $ENV{OPUS_WORK}/../0021_cyg_74_partial_spi.trigger $ENV{OPUS_WORK}/$ENV{PATH_FILE_NAME}/input/" );
system ( "$myecho testing > $ENV{OPUS_WORK}/$ENV{PATH_FILE_NAME}/input/002400000000_omc.trigger" );	#	This tests the sm??_ triggers

foreach ( glob ( "$ENV{OPUS_WORK}/$ENV{PATH_FILE_NAME}/input/*trigger" ) ) {
#		"$ENV{OPUS_WORK}/$ENV{PATH_FILE_NAME}/input/0021_cyg_74_partial_spi.trigger",
#		"$ENV{OPUS_WORK}/$ENV{PATH_FILE_NAME}/input/002400000000_omc.trigger" 
	$ENV{EVENT_NAME} = $_;

	my ( $osfname, $dcf, $inst, $INST, $revno, $scwid ) = &SSALIB::Trigger2OSF ( "$ENV{EVENT_NAME}" );
	my $logdir = "$ENV{REP_BASE_PROD}/obs_$inst/$revno.000/$osfname/logs";
	system ( "$mymkdir -p $logdir" ) unless ( -e "$logdir" );

	$retval = &ISDCPipeline::PipelineStart (
		"pipeline"    => "SMA Pipeline Start",
		"dataset"     => "$osfname", 
		"state"       => "$osf_stati{SMA_ST_C}",
		"type"        => "sma",
		"reallogfile" => "$logdir/${osfname}_css.txt",
		);
	system ( "$mymv $ENV{EVENT_NAME} $ENV{EVENT_NAME}_processing" );
}

system ( "bb_mod.pl --agelimit=-1 --path=consssa --current_status=$osf_stati{SSA_ST_C} --new_status=$osf_stati{SSA_COMPLETE} --donotconfirm" );

#-------------------------------------------------------------------------------------

#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	
#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	
#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	
#
#	dataset correction!
#	conssa observations should be in the format...   
#	"so"  "2 lc instrument" "underscore" "11 digits (NOT 12)" "underscore" "usually 001" "underscore" "3-4 UC instrument"
print "#######     Correcting conssa directory names.\n";
system ( "$mymv $ENV{REP_BASE_PROD}/obs/soib_010200230010_001.000 $ENV{REP_BASE_PROD}/obs/soib_01020023001_001.000" )
	if ( -d  "$ENV{REP_BASE_PROD}/obs/soib_010200230010_001.000" );
system ( "$mymv $ENV{REP_BASE_PROD}/obs/soj2_010200230010_001.000 $ENV{REP_BASE_PROD}/obs/soj2_01020023001_001.000" )
	if ( -d  "$ENV{REP_BASE_PROD}/obs/soj2_010200230010_001.000" );
system ( "$mymv $ENV{REP_BASE_PROD}/obs/soom_010200230010_001.000 $ENV{REP_BASE_PROD}/obs/soom_01020023001_001.000" )
	if ( -d  "$ENV{REP_BASE_PROD}/obs/soom_010200230010_001.000" );
system ( "$mymv $ENV{REP_BASE_PROD}/obs/sosp_010200290010_001.000 $ENV{REP_BASE_PROD}/obs/sosp_01020029001_001.000" )
	if ( -d  "$ENV{REP_BASE_PROD}/obs/sosp_010200290010_001.000" );
#
#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	
#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	
#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	#	

#-------------------------------------------------------------------------------------

#	system ( "$mymkdir -p $ENV{REP_BASE_PROD}/obs/soib_01020023001_001.000" );
#	system ( "$mymkdir -p $ENV{REP_BASE_PROD}/obs/soj2_01020023001_001.000" );
#	system ( "$mymkdir -p $ENV{REP_BASE_PROD}/obs/soom_01020023001_001.000" );
#	system ( "$mymkdir -p $ENV{REP_BASE_PROD}/obs/sosp_01020029001_001.000" );
#	system ( "$myls -l $ENV{REP_BASE_PROD}/obs" );

print "#######     Starting the conssa pipeline.\n";

$ENV{PATH_FILE_NAME} = "conssa";

foreach my $obsid ( glob ( "$ENV{REP_BASE_PROD}/obs/*" ) ) {
	#  dataset : sosp_03201020001_001_SPI
	#  logs    : sosp_03201020001_001_SPI
	#  trigger : sosp_03201020001_001
	#	obs dir : sosp_03201020001.001   NOT TRUE!
	#	obs dir : sosp_03201020001_001.000
   
	$obsid =~ s/^.*\/(\w+)\..*$/$1/; #  remove path and extension

	$ENV{EVENT_NAME} = "$ENV{OPUS_WORK}/conssa/input/$obsid.trigger";
	system ( "$mytouch $ENV{EVENT_NAME}" );

	my ($dataset, $path, $suffix) = &File::Basename::fileparse($ENV{EVENT_NAME}, '\..*');
	( my $inst = $dataset ) =~ s/^so(.{2})_\d{11}_\d{3}$/$1/;
	$inst =~ s/om/OMC/;
	$inst =~ s/sp/SPI/;
	$inst =~ s/ib/IBIS/;
	$inst =~ s/j1/JMX1/;
	$inst =~ s/j2/JMX2/;
   ( my $dcf = $inst ) =~ s/JM/J/;
	my $logdir = "$ENV{REP_BASE_PROD}/obs/$dataset.000/logs";
	system ( "$mymkdir -p $logdir" ) unless ( -e "$logdir" );

	#	not exactly 100% accurate as it does not create the scw OSFs like in csast.pl
	( $retval, @result ) = &ISDCPipeline::PipelineStart (
		"dataset"     => "${dataset}_${inst}",
		"state"       => "$osf_stati{SA_ST_C}",
		"type"        => "obs",
		"dcf"         => "$dcf",
		"logfile"     => "$ENV{OPUS_WORK}/conssa/logs/${dataset}_${inst}.log",
		"reallogfile" => "$logdir/${dataset}_${inst}_log.txt",
		);

	foreach my $scw ( "010200200010", "010200210010", "010200220010", "010200230010" ) {
		system ( "$mytouch $ENV{OPUS_WORK}/conssa/logs/${dataset}_${inst}_$scw.log" );
		system ( "osf_create -p conssa -f ${dataset}_${inst}_$scw -s cww" )
			unless ( $inst =~ /SPI/ );
	}

	system ( "$mymv $ENV{EVENT_NAME} $ENV{EVENT_NAME}_processing" );
}

system ( "bb_mod.pl --agelimit=-1 --path=conssa --current_status=$osf_stati{SA_ST_C} --new_status=$osf_stati{SA_COMPLETE} --donotconfirm" );

#-------------------------------------------------------------------------------------

#	Make some files that will be considered "remainders"
system ( "$mytouch $ENV{OPUS_WORK}/consscw/input/002400000000.trigger" );
system ( "$mytouch $ENV{OPUS_WORK}/consinput/input/002500000000.trigger" );
system ( "$mytouch $ENV{OPUS_WORK}/consscw/input/002500000000.trigger" );
system ( "$mytouch $ENV{OPUS_WORK}/consscw/input/003600000000.trigger" );

#-------------------------------------------------------------------------------------

#	I don't know if I need to set these var again
$ENV{OSF_DATASET}  = "002500000051";
$ENV{LOG_FILES}    = "$out";

open  OSFSTATUS, "> $out/OSFstatus";
( $retval, @result ) = &OPUSLIB::OSFstatus (
	"files" => "$ENV{OPUS_WORK}/conssa/input/*trigger*",
	"path" => "conssa",
	);
print OSFSTATUS "$retval\n@result\n";
close OSFSTATUS;

delete $ENV{LOG_FILES};
delete $ENV{OSF_DATASET};

#-------------------------------------------------------------------------------------

#
#	How about some adp stuff?????
#
#	I could create some adp opus stuff, but
#

#-------------------------------------------------------------------------------------

#	copy prepared opus_work to out
#	This copy will show errors because the log files in some cases are incorrectly linked or don't exist
system ( "$mycp -r $ENV{OPUS_WORK} $out/ 2> /dev/null" );
system ( "$myrm -rf $out/opus_work/*/obs/*" );
system ( "$myrm -rf $out/opus_work/*/logs/*" );
system ( "$myrm -rf $out/opus_work/opus" );
system ( "$mymv $out/opus_work $out/before" );

#-------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------

print "\nBelow should be an opus blackboard with items in all pipelines (except adp).\n";
system ( "$ENV{ISDC_OPUS}/pipeline_lib/bb_sum.pl" );

#-------------------------------------------------------------------------------------

print "\nBeginning cleanup.\n";

print "#\n#\tCOMMONLOGFILE \t $ENV{COMMONLOGFILE}\n#\n";
delete $ENV{PATH_FILE_NAME};	#	this cannot be set, or cleanup does different things.
$ENV{COMMONLOGFILE} = "+common_log.txt";
print "#\n#\tCOMMONLOGFILE \t $ENV{COMMONLOGFILE}\n#\n";

system ( "$mycleanup --path=consinput --level=raw  --dataset=002400050031" );
system ( "$mycleanup --path=revol_scw --level=opus --dataset=0024" );
system ( "$mycleanup --path=consinput --level=raw  --dataset=002400050020" );
system ( "$mycleanup --path=consscw   --level=raw  --dataset=002400050020" );
system ( "$mycleanup --path=consscw   --level=raw  --dataset=002400090010" );
system ( "$mycleanup --path=consrev   --level=raw  --dataset=0024_20021226233227_00_irn" );
system ( "$mycleanup --path=consrev   --level=raw  --dataset=0024_20021226235614_00_j2t" );
system ( "$mycleanup --path=consrev   --level=raw  --dataset=0024_20021226235606_00_j1t" );

foreach ( "0003", "0004", "0013", "0014", "0024", "0025", "0036" ) {
	print "\n------------------\nCleaning $_ in three explicit steps for testing.\n";
	system ( "$mycleanup --path=revol_scw --dataset=$_ --level=opus" );
	system ( "$mycleanup --path=revol_scw --dataset=$_ --level=prp" );
	system ( "$mycleanup --path=revol_scw --dataset=$_ --level=raw" );

	system ( "$mymv $ENV{REP_BASE_PROD}/aux/adp/$_.001 $ENV{REP_BASE_PROD}/aux/adp/$_.000" );
	system ( "$mymkdir -p $ENV{REP_BASE_PROD}/aux/org/$_" );
	system ( "$mycleanup --path=revol_aux --dataset=$_ --level=raw" );
}

#-------------------------------------------------------------------------------------

print "\nBelow should be an opus blackboard with items only in conssa and consssa.\n";
system ( "$ENV{ISDC_OPUS}/pipeline_lib/bb_sum.pl" );	#	should be empty

#foreach ( "ii", "j2", "j2", "om", "ip", "sp" ) {
foreach ( "ii", "j1", "om" ) {
	system ( "$mycleanup --path=consssa --dataset=ss${_}_002400050010 --level=raw" );
}

system ( "$mycleanup --path=consssa --dataset=002400050010 --level=raw --match" );
system ( "$mycleanup --path=revol_ssa --dataset=0024 --level=raw" );







#	should also try a --bydate test











system ( "$mycleanup --path=revol_ssa --dataset=0025 --level=opus" );
system ( "$mycleanup --path=revol_ssa --dataset=0025 --level=raw --inst=\"isgri,picsit,omc\"" );
system ( "$mycleanup --path=revol_ssa --dataset=0025 --level=raw --inst=\"jemx1,jmx2,spi\"" );
#system ( "$mycleanup --path=revol_ssa --dataset=0025 --level=raw" );

system ( "$mycleanup --path=consssa --dataset=smsp_0021_cyg_74_partial --level=raw" );

foreach my $trigger ( glob ("$ENV{OPUS_WORK}/conssa/input/*trigger*") ) {
	#  dataset : sosp_03201020001_001_SPI
	#  logs    : sosp_03201020001_001_SPI
	#  trigger : sosp_03201020001_001
	#	obs dir : sosp_03201020001.001   NOT TRUE!
	#	obs dir : sosp_03201020001_001.000

	$trigger =~ s/^.*\/(\w+)\.trigger.*$/$1/;	#	remove path and extension

	$trigger .= "_SPI"  if ( $trigger =~ /^sosp/ );
	$trigger .= "_OMC"  if ( $trigger =~ /^soom/ );
	$trigger .= "_IBIS" if ( $trigger =~ /^soib/ );
	$trigger .= "_JMX1" if ( $trigger =~ /^soj1/ );
	$trigger .= "_JMX2" if ( $trigger =~ /^soj2/ );

	system ( "$mycleanup --path=conssa --dataset=$trigger --level=raw" );
}

#-------------------------------------------------------------------------------------

print "\nBelow should be an empty blackboard.\n";
system ( "$ENV{ISDC_OPUS}/pipeline_lib/bb_sum.pl" );

system ( "$mymv $ENV{REP_BASE_PROD}/obs* $out" );
system ( "$mymv $ENV{REP_BASE_PROD}/scw $out" );
#	This copy will show errors because the log files in some cases are incorrectly linked or don't exist
system ( "$mycp -r $ENV{OPUS_WORK} $out/ 2> /dev/null" );
system ( "$myrm -rf $out/opus_work/*/obs/*" );
system ( "$myrm -rf $out/opus_work/*/logs/*" );
system ( "$myrm -rf $out/opus_work/opus" );
system ( "$mymv $out/opus_work $out/after" );



#-------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------

#
#	TEST ISDCPipeline subs	(still need to set LOG_DIRs and other ENV values)
#

$ENV{LOG_FILES}   = "$out";
`$mymkdir -p $ENV{LOG_FILES}` unless ( -d $ENV{LOG_FILES} );
$ENV{OSF_DATASET} = "irem_raw_20021226220109_00";
$ENV{PARFILES}    = "./test_data/";		#	this must be set before running PipelineStep

print "#\n#\tCOMMONLOGFILE \t $ENV{COMMONLOGFILE}\n#\n";
&ISDCPipeline::RunProgram ( "echo Testing ISDCPipeline::RunProgram" );
print "#\n#\tCOMMONLOGFILE \t $ENV{COMMONLOGFILE}\n#\n";

&ISDCPipeline::PipelineStep (
	"step"         => "Test PipelineStep",
	"program_name" => "echo testing pipelinestep",
	"getstdout"    => 0,
	);
	
print "#\n#\tCOMMONLOGFILE \t $ENV{COMMONLOGFILE}\n#\n";
&ISDCPipeline::RunProgram ( "echo Testing ISDCPipeline::RunProgram" );
print "#\n#\tCOMMONLOGFILE \t $ENV{COMMONLOGFILE}\n#\n";
	
&ISDCPipeline::PipelineStep (
	"step"         => "Test PipelineStep",
	"program_name" => "echo testing pipelinestep",
	"getstdout"    => 1,
	);
	
print "#\n#\tCOMMONLOGFILE \t $ENV{COMMONLOGFILE}\n#\n";
&ISDCPipeline::RunProgram ( "echo Testing ISDCPipeline::RunProgram" );
print "#\n#\tCOMMONLOGFILE \t $ENV{COMMONLOGFILE}\n#\n";
	
&ISDCPipeline::PipelineEnvVars();														#	prints all environment variables to screen
print `$mytouch $out/PipelineEnvVars.done`;

$ENV{TEST_ENVSTRETCH_VAR} = "REP_BASE_PROD:/test";
print "#\n#\tTEST_ENVSTRETCH_VAR \t $ENV{TEST_ENVSTRETCH_VAR}\n#";
&ISDCPipeline::EnvStretch( "TEST_ENVSTRETCH_VAR" );
print "#\n#\tTEST_ENVSTRETCH_VAR \t $ENV{TEST_ENVSTRETCH_VAR}\n#\n";
print `$mytouch $out/EnvStretch.done`;


print "#######     PFILES   : $ENV{PFILES}\n";
open  CONVERTTIME, "> $out/ConvertTime";
my $ConvertTime = &ISDCPipeline::ConvertTime (
	"informat"  => "YYYYDDDHH",
	"intime"    => "200215013",
	"outformat" => "UTC",
	);
print CONVERTTIME "$ConvertTime\n";
close CONVERTTIME;

print "#######     PFILES   : $ENV{PFILES}\n";

&ISDCPipeline::PipelineFinish();
print `$mytouch $out/PipelineFinish.done`;

#	These logs will contain different execution times which causes the file to be different.
system ( "$mymv $out/irem_raw_20021226220109_00.log $ENV{REP_BASE_PROD}/" );
system ( "$mymv $out/002500000051.log $ENV{REP_BASE_PROD}/" );

print "\n###############################################################################\n";
print "#######\n";
print "#######     ENDING THE PIPELINE_LIB UNIT TEST \n";
print "#######\n";
print "###############################################################################\n\n\n";


exit 0;

#	last line
