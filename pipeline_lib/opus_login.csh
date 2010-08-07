#!/bin/csh -X
#
#
#
if ($#argv != 0) then
	set oversion = $argv[1]
else
	set oversion = "3v2"		#	default version
endif

if (  ( $oversion != "1v4" )  \
	&& ( $oversion != "3v2" )  \
	&& ( $oversion != "5v4b" ) \
	) then
	echo ">>>>>>>     ERROR:  don't recognize OPUS version $oversion"
	exit 1
endif

if ( $tty != "" ) echo ">>>>>>>     Setting up for OPUS $oversion"

#
#-----------------------------------------------------------------------------
#
#	OPUS login
#
# This file is a template of opus_login.csh.  Any of these variables can
# be stretched through your own area.  Also you can add any additional
# variables to this file for your own application.
#
# Your customized version of this file should be placed in the directory
# you define below as opus_definitions_dir.
#
# **************************************************************************
# **************************************************************************
# *********                                                         ********
# *********  Look for the angle brackets <...> below to find where  ********
# *********  to insert parameters for your run-time environment.    ********
# *********                                                         ********
# **************************************************************************
# **************************************************************************
#
#            PR
#   DATE   NUMBER   User   Description
# -------- ------   ------ -------------------------------------
# 04/22/97 33431    WMiller Initial code
#
#-----------------------------------------------------------------------------
#
#=================== BEGINNING OF USER-DEFINED VARIABLES =====================
#-----------------------------------------------------------------------------
# Define variables for YOUR shell environment.  Examples of every user-
# defined variable precede the actual definitions.  Do NOT copy these 
# verbatim.  Use disks and directory trees in YOUR OWN ENVIRONMENT.  Replace
#
# all angle brackets <...> and their contents with the appropriate values.
# 
# for Y2K "bug";  I can't believe they're serious.
eval `envv set SQUASH_Y2K_BUG on`
#
#  Now, determine which version we want:
#
#
eval `envv set SOGS_DISK "/isdc/sw/opus/${oversion}/opus/"`


####################################################################
#
# eval `envv set OPUS_DEFINITIONS_DIR <SOGS_DISK:/definitions/>`
#
##########
#
#    ISDC_ENV differences.  ADP, NRT, and CONS require different setups
#
##########

#  For all of them, need this for cleanup.pl
set path = ( $path $ISDC_OPUS/pipeline_lib )

switch (${ISDC_ENV})

	# NRT



#	070124 - Jake - needed to move this here to process nrtqla in the osa_6 test environment
#
#	case *OSA*:		#	060828 - Jake - added for IBIS misalignment tests but may be useful in future
#						#		/unsaved_data/isdc_int/Linux/all_sw/OSA6


	case *nrt*:
		eval `envv set OPUS_DEFINITIONS_DIR "ISDC_OPUS:/nrtinput/ ISDC_OPUS:/nrtscw/ ISDC_OPUS:/nrtrev/ ISDC_OPUS:/nrtqla/"`

		set path = ($path $ISDC_OPUS/nrtscw $ISDC_OPUS/nrtrev $ISDC_OPUS/nrtinput $ISDC_OPUS/nrtqla )

		#  Unfortunately, no aliases for 3v2
		if ($oversion == "1v4") then
			alias omgnrtinput 'omg -xrm "*PathDialog*PathSelected.items: nrtinput" -n "NRTINPUT omg"'
			alias omgnrtscw 'omg -xrm "*PathDialog*PathSelected.items: nrtscw" -n "NRTSCW omg"'
			alias omgnrtrev 'omg -xrm "*PathDialog*PathSelected.items: nrtrev" -n "NRTREV omg"'
			#    alias omgnrtqla 'omg -xrm "*PathDialog*PathSelected.items: nrtqla" -n "NRTREV omg"'
		endif


		set perladd = "nrtrev"
		breaksw
		##########

	# CONS
#	case *all*:		#	051118 - Jake - moved all from nrt to here with cons
	case *osa*:		#	060828 - Jake - added for IBIS misalignment tests but may be useful in future
	case *cons*:
		#	050704 - Jake - some editting for SPR 4257
		eval `envv set OPUS_DEFINITIONS_DIR "ISDC_OPUS:/consinput/ ISDC_OPUS:/consscw/ ISDC_OPUS:/consrev/ ISDC_OPUS:/conssa/ ISDC_OPUS:/consssa/"`
		#eval `envv set OPUS_DEFINITIONS_DIR "ISDC_OPUS:/consinput/ ISDC_OPUS:/consscw/ ISDC_OPUS:/consrev/ ISDC_OPUS:/conssa/ ISDC_OPUS:/consssa/ ISDC_OPUS:/conscor/"`

		# Needs still nrt dirs since uses same scripts.  
		set path = ($path $ISDC_OPUS/consssa $ISDC_OPUS/conssa $ISDC_OPUS/consrev $ISDC_OPUS/nrtscw $ISDC_OPUS/nrtrev $ISDC_OPUS/nrtinput) 
		#set path = ($path $ISDC_OPUS/consssa $ISDC_OPUS/conssa $ISDC_OPUS/consrev $ISDC_OPUS/nrtscw $ISDC_OPUS/nrtrev $ISDC_OPUS/nrtinput $ISDC_OPUS/conscor) 

		if ($oversion == "1v4") then
	
			alias omgconsinput 'omg -xrm "*PathDialog*PathSelected.items: consinput" -n "CONSINPUT omg"'
			alias omgconsscw   'omg -xrm "*PathDialog*PathSelected.items: consscw" -n "CONSSCW omg"'
			alias omgconsrev   'omg -xrm "*PathDialog*PathSelected.items: consrev" -n "CONSREV omg"'
			alias omgconssa    'omg -xrm "*PathDialog*PathSelected.items: conssa" -n "CONSSA omg"'
			alias omgconsssa   'omg -xrm "*PathDialog*PathSelected.items: consssa" -n "CONSSSA omg"'
			#alias omgconscor   'omg -xrm "*PathDialog*PathSelected.items: conscor" -n "CONSCOR omg"'
		endif

		#TO BE FIXED:  someday, this may be different, but for now, the Perl code
		#  for the cons pipelines is the nrt pipelines:
		#    set perladd = "consrev"
		set perladd = "nrtrev"

		breaksw
		##########

	# ADP
	case *adp*:

		eval `envv set OPUS_DEFINITIONS_DIR "ISDC_OPUS:/adp/"`

		set path = ($path $ISDC_OPUS/adp )

		#    if ($oversion == "1v4") alias omgadp 'omg -xrm "*PathDialog*PathSelected.items: adp" -n "ADP omg"' 

		breaksw

	case *arc*:
		#  TO BE FIXED:  I don't know where these go for now.  Have to be
		#   set in the operator's login.
		#    set path = ( $ISDC_OPUS/arcdd/ $path )
		eval `envv set OPUS_DEFINITIONS_DIR "ISDC_OPUS:/arcdd/"`
		#    set perladd = "arcdd"

		breaksw

	case *all_sw*:		#	051118 - Jake - moved all from nrt to here with cons
		eval `envv set OPUS_DEFINITIONS_DIR "ISDC_OPUS:/nrtinput/ ISDC_OPUS:/nrtscw/ ISDC_OPUS:/nrtrev/ ISDC_OPUS:/nrtqla/ ISDC_OPUS:/consinput/ ISDC_OPUS:/consscw/ ISDC_OPUS:/consrev/ ISDC_OPUS:/conssa/ ISDC_OPUS:/consssa/"`

		# Needs still nrt dirs since uses same scripts.  
		set path = ($path $ISDC_OPUS/consssa $ISDC_OPUS/conssa $ISDC_OPUS/consrev $ISDC_OPUS/nrtscw $ISDC_OPUS/nrtrev $ISDC_OPUS/nrtinput $ISDC_OPUS/nrtqla) 

		#TO BE FIXED:  someday, this may be different, but for now, the Perl code
		#  for the cons pipelines is the nrt pipelines:
		#    set perladd = "consrev"
		set perladd = "nrtrev"

		breaksw
		##########

	default:

		if ( $tty != "" ) echo ">>>>>>>     Cannot determine environment from ISDC_ENV ${ISDC_ENV}"
		if ( $tty != "" ) echo ">>>>>>>     OPUS setup incomplete"
		exit;

		breaksw

endsw

if ($?perladd) then 
	eval `envv add PERL5LIB ${ISDC_OPUS}/${perladd} 1`
	eval `envv add PERLLIB  ${ISDC_OPUS}/${perladd} 1`
endif


###########
#  Required for all:
#
# location for PSTAT files and process log files
eval `envv set OPUS_HOME_DIR ${OPUS_WORK}/opus/`
#
#	060406 - Jake - What's the point of this next line?  Its just set again on the line after it!
#		because it adds pipeline_lib
eval `envv set OPUS_DEFINITIONS_DIR "${OPUS_DEFINITIONS_DIR} ISDC_OPUS:/pipeline_lib/"`

if ( $oversion == "1v4") then
	eval `envv set OPUS_DEFINITIONS_DIR "$OPUS_DEFINITIONS_DIR ${SOGS_DISK}/definitions ${SOGS_DISK}/definitions/unix"`
else 
	eval `envv set OPUS_DEFINITIONS_DIR "${OPUS_HOME_DIR} ${OPUS_DEFINITIONS_DIR}"`
endif
#  IS THIS NECESSARY?  Trying to arrange that it writes to opus_corba_objs
#   in OPUS_HOME_DIR instead of in OPUS_DEFINITIONS_DIR which should remain
#   write protected.  The OPUS team are idiots.
#eval `envv set OPUS_DEFINITIONS_DIR "${OPUS_DEFINITIONS_DIR}  SOGS_DISK:/definitions/unix/ SOGS_DISK:/definitions/"`
#
# Set PERLLIB needed for using ISDCPipeline.pm module
eval `envv add PERL5LIB "${ISDC_OPUS}/pipeline_lib" 1`
eval `envv add PERLLIB  "${ISDC_OPUS}/pipeline_lib" 1`
#
#
#
# to force opus to process triggers in order
#
eval `envv set OPUS_SORT_FILES 1`
#
####################  new with OPUS 3v2 ##############################
# set the paths to the remote shell utility (rsh-compatible) and remote 
# copy utility (rcp-compatible) to be used by OPUS
if ( $oversion != "1v4") then 
	eval `envv set OPUS_REMOTE_SHELL /usr/bin/rsh`
	eval `envv set OPUS_REMOTE_COPY  /usr/bin/rcp`
endif
######################################################################
#
#====================== END OF USER-DEFINED VARIABLES =========================
#
#
####################  new with OPUS 3v2 ##############################
# location for default X-resource files (pmg and omg)
if ( $?XUSERFILESEARCHPATH ) then
	eval `envv set XUSERFILESEARCHPATH ${XUSERFILESEARCHPATH}:$HOME/%N.dat`
else
	eval `envv set XUSERFILESEARCHPATH $HOME/%N.dat`
endif

#	050816 - Jake - SPR 4279
set OS = `uname -s`
if ( $OS =~ SunOS ) then
   set osdir = "sparc_solaris"
else
	set osdir = "linux"
#	070917 - Jake - isdclin machines were upgraded and caused a problem with this.
	eval `envv set OPUS_REMOTE_SHELL "/usr/bin/ssh"`
#	eval `envv set OPUS_REMOTE_SHELL "/usr/bin/ssh -1"`
endif

#
# location for shared libraries
if ( $oversion != "1v4" ) eval `envv add LD_LIBRARY_PATH ${SOGS_DISK}/lib/$osdir 1`

######################################################################
#
#
set fxlogin = `osfile_stretch_file SOGS_DISK:/com/fxlogin.csh`
source $fxlogin
#
#
# Define any variables that you want to stretch through your local area.
#
#eval `envv set MSG_REPORT_LEVEL MSG_ALL`
eval `envv set MSG_REPORT_LEVEL MSG_INFO`
#eval `envv set MSG_TRL_REPORT_LEVEL MSG_ALL`
eval `envv set MSG_TRL_REPORT_LEVEL MSG_INFO`
#
######################################################################
#
#  Print something, since 3v2 is silent;  1v4 already announces itself
if ( $tty != "" ) echo ">>>>>>>     Done."

#====================== OPUS_LOGIN completed.  ===============================
