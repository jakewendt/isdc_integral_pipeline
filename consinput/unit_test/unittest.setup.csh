#!/bin/csh -f


echo "#######"
echo "####### -v- Sourcing unittest.setup.csh to setup the basic pipeline unit test environment"
echo "#######"

echo "#######     Current user is ${USER}"
set OS = `uname -s`

set ECHO = "echo"
echo "#######     Current OS is ${OS}"
if ( $OS =~ SunOS ) then
	set osdir = "sparc_solaris"
	if ( -x /usr/ucb/echo ) set ECHO  = "/usr/ucb/echo"
else
	set osdir = "linux"
	if ( -x /bin/echo ) set ECHO  = "/bin/echo"
endif

$ECHO    "#######     Using echo : $ECHO"
$ECHO -n "#######     Current machine is "
uname -n
$ECHO -n "#######     Using perl : "
which perl
echo "#######     "

##  Check that I haven't run gen_diff_entry without updating tar file yet:
if (-d "outref.new") then
	echo "#######     ERROR:  outref.new exists;  please update tar file."
	exit 1
endif

######################################################################
#  Check for things we'll need:
# 
#  First, of course, ISDC_ENV
if (-d "$ISDC_ENV") then
	echo "#######     ${ISDC_ENV} check OK"

	if ( ${system} != "iqla_scripts" ) then
		#  Is pipeline_lib correctly installed?
		if (! -x "${ISDC_ENV}/opus/pipeline_lib/opus_wrapper") then
			echo "#######     ERROR:  Cannot execute ${ISDC_ENV}/opus/pipeline_lib/opus_wrapper"
			echo "#######     Check that pipeline_lib is installed correctly"
			exit 2
		else
			echo "#######     ${ISDC_ENV}/opus/pipeline_lib/opus_wrapper check OK"
		endif # if wrapper
	endif
   
   #  Are system pfiles installed?
	if (! -d "${ISDC_ENV}/pfiles") then
		echo "#######     ERROR:  PFILES dir ${ISDC_ENV}/pfiles does not exist"
		echo "#######     Please check that all dependent software is installed correctly"
		exit 3
	else
		echo "#######     ${ISDC_ENV}/pfiles check OK"
	endif
   
else
   echo "#######     ERROR:  ISDC_ENV is set to ${ISDC_ENV}"                     
   exit 4
endif # if ISDC_ENV


######################################################################
#
#  Environment variables needed:  remember that OPUS login not done 

#  Need this to make it work within "make test" command:
setenv SHELL /bin/csh


#	Currently only have *pm in conssa, nrtrev, nrtqla and pipeline_lib
#	Conssa and nrtqla add themselves.  All others are unnecessary.
# 
#  And these are only set for the duration of the unit test, not permanently
#   affecting the operator.  So we can feel free to do whatever:
eval `/usr/bin/envv del PERL5LIB /isdc/integration/isdc_int/SunOS/all_sw/prod/opus/pipeline_lib`	#	from opus_login.csh (may or may not be SunOS)
eval `/usr/bin/envv del PERL5LIB /isdc/integration/isdc_int/SunOS/all_sw/prod/opus/nrtrev`			#	from opus_login.csh (may or may not be SunOS)
eval `/usr/bin/envv del PERL5LIB /isdc/integration/isdc_int/sw/dev/prod/opus/pipeline_lib`
eval `/usr/bin/envv add PERL5LIB ${ISDC_ENV}/opus/pipeline_lib 1`
eval `/usr/bin/envv add PERL5LIB ${ISDC_ENV}/opus/${system} 1`
#if ( ${system} =~ *input ) eval `/usr/bin/envv add PERL5LIB ${ISDC_ENV}/opus/nrtinput 1`
if ( ${system} =~ *rev   ) eval `/usr/bin/envv add PERL5LIB ${ISDC_ENV}/opus/nrtrev 1`
#if ( ${system} =~ *scw   ) eval `/usr/bin/envv add PERL5LIB ${ISDC_ENV}/opus/nrtscw 1`
#if ( ${system} =~ iqla_scripts ) eval `/usr/bin/envv add PERL5LIB $ISDC_ENV/opus/iqla_scripts 1`
echo "#######     PERL5LIB is now ..."
echo $PERL5LIB | /bin/awk -F: '{for (i=1;i<=NF;i++) printf ("+++++++       "$i"\n");}'







if ( ! $?ISDC_OPUS_VERSION ) setenv ISDC_OPUS_VERSION 5v4b
#
#	ISDC_OPUS_VERSION is set from within /isdc/scripts/login
#	This probably won't work on the WCT, so I'll have to modify
#
echo "#######     ISDC_OPUS_VERSION is now $ISDC_OPUS_VERSION "

#eval `/usr/bin/envv set SOGS_DISK /isdc/sw/opus/3v2/opus`
#eval `/usr/bin/envv set SOGS_DISK /isdc/sw/opus/5v4b/opus`
eval `/usr/bin/envv set SOGS_DISK /isdc/sw/opus/$ISDC_OPUS_VERSION/opus`
echo "#######     SOGS_DISK is now $SOGS_DISK "




eval `/usr/bin/envv del PATH /isdc/integration/isdc_int/SunOS/all_sw/prod/bin/ac_stuff`		#	051120 - Jake - testing!!!!
eval `/usr/bin/envv del PATH /home/isdc_guest/isdc_int/my/scripts/`		#	051120 - Jake - testing!!!!
eval `/usr/bin/envv del PATH /home/isdc/wendt/my/init`		#	051120 - Jake - testing!!!!
eval `/usr/bin/envv del PATH /home/isdc/wendt/my/scripts`		#	051120 - Jake - testing!!!!



eval `/usr/bin/envv del PATH /isdc/sge/bin/solaris64`		#	050429 - Jake - testing!!!!

eval `/usr/bin/envv del PATH /isdc/integration/isdc_int/SunOS/all_sw/prod/opus/pipeline_lib`			#	from opus_login.csh (may or may not be SunOS)
eval `/usr/bin/envv del PATH /isdc/integration/isdc_int/SunOS/all_sw/prod/opus/consssa`				#	from opus_login.csh (may or may not be SunOS)
eval `/usr/bin/envv del PATH /isdc/integration/isdc_int/SunOS/all_sw/prod/opus/conssa`					#	from opus_login.csh (may or may not be SunOS)
eval `/usr/bin/envv del PATH /isdc/integration/isdc_int/SunOS/all_sw/prod/opus/consrev`				#	from opus_login.csh (may or may not be SunOS)
eval `/usr/bin/envv del PATH /isdc/integration/isdc_int/SunOS/all_sw/prod/opus/nrtscw`					#	from opus_login.csh (may or may not be SunOS)
eval `/usr/bin/envv del PATH /isdc/integration/isdc_int/SunOS/all_sw/prod/opus/nrtrev`					#	from opus_login.csh (may or may not be SunOS)
eval `/usr/bin/envv del PATH /isdc/integration/isdc_int/SunOS/all_sw/prod/opus/nrtinput`				#	from opus_login.csh (may or may not be SunOS)
eval `/usr/bin/envv del PATH /isdc/integration/isdc_int/SunOS/all_sw/prod/opus/nrtqla`					#	from opus_login.csh (may or may not be SunOS)
eval `/usr/bin/envv del PATH /isdc/integration/isdc_int/sw/dev/prod/opus/pipeline_lib`
eval `/usr/bin/envv del PATH ${LHEASOFT}/scripts`
eval `/usr/bin/envv del PATH ${LHEASOFT}/bin`
eval `/usr/bin/envv del PATH /isdc/sw/opus/3v2/WS/7/opus/com`
eval `/usr/bin/envv del PATH /isdc/sw/opus/3v2/WS/7/opus/bin/sparc_solaris`
eval `/usr/bin/envv add PATH ${SOGS_DISK}/com 1`
eval `/usr/bin/envv add PATH ${SOGS_DISK}/bin/$osdir 1`
eval `/usr/bin/envv add PATH ${ISDC_ENV}/opus/pipeline_lib 1`
eval `/usr/bin/envv add PATH ${ISDC_ENV}/opus/${system} 1`
if ( ${system} =~ *input ) eval `/usr/bin/envv add PATH ${ISDC_ENV}/opus/nrtinput 1`
if ( ${system} =~ *rev   ) eval `/usr/bin/envv add PATH ${ISDC_ENV}/opus/nrtrev 1`
if ( ${system} =~ *scw   ) eval `/usr/bin/envv add PATH ${ISDC_ENV}/opus/nrtscw 1`
#if ( ${system} =~ iqla_scripts ) eval `/usr/bin/envv add PATH $ISDC_ENV/opus/iqla_scripts 1`
echo "#######     PATH is now ..."
echo $PATH | /bin/awk -F: '{for (i=1;i<=NF;i++) printf ("+++++++       "$i"\n");}'
rehash

eval `/usr/bin/envv set OPUS_WORK ${PWD}/opus_work`
echo "#######     OPUS_WORK is now $OPUS_WORK "

eval `/usr/bin/envv set OPUS_HOME_DIR ${OPUS_WORK}/opus`
echo "#######     OPUS_HOME_DIR is now $OPUS_HOME_DIR "

eval `/usr/bin/envv set ISDC_OPUS ${ISDC_ENV}/opus`
echo "#######     ISDC_OPUS is now $ISDC_OPUS "


#eval `/usr/bin/envv del LD_LIBRARY_PATH ${SOGS_DISK}/lib/$osdir`
#eval `/usr/bin/envv del LD_LIBRARY_PATH ${SOGS_DISK}/lib/$osdir/`
#eval `/usr/bin/envv del LD_LIBRARY_PATH ${SOGS_DISK}//lib/$osdir`
eval `/usr/bin/envv del LD_LIBRARY_PATH /isdc/sw/opus/3v2/WS/7/opus/lib/sparc_solaris/`		#	just a link
eval `/usr/bin/envv del LD_LIBRARY_PATH ${SOGS_DISK}//lib/$osdir/`			#	bc envv doesn't match if extra /'s
eval `/usr/bin/envv del LD_LIBRARY_PATH /isdc/sge/lib/solaris64`				#	050429 - Jake - testing!!!!

eval `/usr/bin/envv add LD_LIBRARY_PATH ${SOGS_DISK}/lib/$osdir 1`
echo "#######     LD_LIBRARY_PATH is now ..."
echo $LD_LIBRARY_PATH | /bin/awk -F: '{for (i=1;i<=NF;i++) printf ("+++++++       "$i"\n");}'

eval `/usr/bin/envv set REP_BASE_PROD ${PWD}/test_data`
echo "#######     REP_BASE_PROD is now $REP_BASE_PROD "

eval `/usr/bin/envv set OPUS_MISC_REP ${PWD}/opus_misc_rep`
echo "#######     OPUS_MISC_REP is now $OPUS_MISC_REP "

if ($?AUXL_REF_DIR) unsetenv AUXL_REF_DIR
echo "#######     AUXL_REF_DIR is not set"

if ( ${system} != "iqla_scripts" ) then
	#	I don't know why Tess complicated this with the -e, \(space) and \"
	#	Maybe I'll find out the hard way
	#  Tricky:  note the "\ " between the entries, and the -e option, and the escaped quotes:
	#eval `/usr/bin/envv -e set OPUS_DEFINITIONS_DIR \"${OPUS_HOME_DIR}\ ISDC_OPUS:/consrev/\ ${ISDC_OPUS}/consssa\ ${ISDC_OPUS}/pipeline_lib\" `

	eval `/usr/bin/envv set OPUS_DEFINITIONS_DIR "${OPUS_HOME_DIR} ISDC_OPUS:/pipeline_lib/ ISDC_OPUS:/${system}/"`	#	Normal
	if ( ${system} =~ consrev ) eval `/usr/bin/envv set OPUS_DEFINITIONS_DIR "${OPUS_DEFINITIONS_DIR} ISDC_OPUS:/consssa/"`
	echo "#######     OPUS_DEFINITIONS_DIR is now $OPUS_DEFINITIONS_DIR "

	echo "#######     Setting up OPUS environment with:  'source ${SOGS_DISK}/com/fxlogin.csh'"
	source ${SOGS_DISK}/com/fxlogin.csh
	if ($status != 0 ) then
	   echo "#######     status was non-zero ($status)"
	   exit 5
	endif
endif


env | /bin/sort > env_dump.txt

echo "#######"
echo "####### -^- Done with unittest.setup.csh"
echo "#######"

