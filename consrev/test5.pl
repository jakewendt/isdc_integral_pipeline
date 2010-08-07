#! /bin/sh
eval '  exec perl -x $0 ${1+"$@"} '
#! perl

use File::Basename;
use strict;
use ISDCPipeline;

$ENV{PROCESS_NAME} = "csstest";
$ENV{OUTPATH} = "rii";
$ENV{WORKDIR} = "work";
$ENV{OBSDIR} = "rii_obs";
$ENV{LOG_FILES} = "log_files";
$ENV{PARFILES} = "$ENV{OPUS_WORK}/consssa/pfiles";
#	$ENV{INPUT} = "rii_input";
$ENV{IC_ALIAS} = "CONS";

$ENV{SOGS_DISK} = "/isdc/sw/opus/3v2/opus/";
$ENV{OPUS_WORK} = "$ENV{PWD}/unit_test/opus_work";
$ENV{OPUS_HOME_DIR} = "$ENV{OPUS_WORK}/opus/";
$ENV{ISDC_OPUS} = "$ENV{ISDC_ENV}/opus/";
$ENV{LD_LIBRARY_PATH} = "$ENV{SOGS_DISK}/lib/sparc_solaris/:$ENV{LD_LIBRARY_PATH}";
$ENV{REP_BASE_PROD} = "$ENV{PWD}/unit_test/test_data";
$ENV{OPUS_DEFINITIONS_DIR} = "\"$ENV{OPUS_HOME_DIR}\ $ENV{ISDC_ENV}/opus/consssa\ $ENV{ISDC_ENV}/opus/pipeline_lib\" ";


if ( 0 ) {
	print "0\n";
} else {
	print "1\n";
}

