#!/bin/csh -f

set StartDir = `pwd`

echo "#######"
echo "####### -v- Sourcing unittest.data.csh to prepare unit test test_data, outref, opus stuff and ic tree"
echo "#######"

set OS = `uname -s`
echo "#######     Current OS is ${OS}"
if ( $OS =~ SunOS ) then
   set taropts = "xf"
else
   set taropts = "xfk"		#	to preserve the possible link
endif


#	Clean up everything
foreach subdir ( "test_data" "out" "outref" "opus_work" "opus_misc_rep" "ISDC_SITE" )
	echo "#######   Checking $subdir status"
	ls $subdir >&/dev/null		#	using this technique instead of -f, -e or -d will actually work on dead links
	@ exit_status = $status
	if ( ! $exit_status ) then
#	if ( -e ${subdir} ) then
		echo "#######     Cleaning up $subdir from previous run"
		# because this tends to error on links, redirect error
		echo "#######       /bin/chmod -R +w $subdir >& /dev/null"
		/bin/chmod -R +w $subdir >& /dev/null
		echo "#######       /bin/rm -rf $subdir"
		/bin/rm -rf $subdir
	else
		echo "#######     No $subdir from previous run found."
	endif
		
	#	050916 - Jake
	#	I am trying this because I keep running out of disk space
	if ( $subdir !~ ISDC_SITE ) then 
		if ( ( $USER =~ isdc_int ) && ( ! $?DO_NOT_USE_LINKS ) ) then
			set tmpdir = "/unsaved_data/isdc_int/opus_unit_tests/$OS/$system/$subdir"
			if ( -e $tmpdir ) then
				echo "#######       Cleaning up $tmpdir from previous run"
				echo "#######         /bin/chmod -R +w $tmpdir >& /dev/null"
				/bin/chmod -R +w $tmpdir >& /dev/null
				echo "#######         /bin/rm -rf $tmpdir"
				/bin/rm -rf $tmpdir
			else
				echo "#######       No $tmpdir from previous run found."
			endif
			echo "#######       Creating new $tmpdir "
			/bin/mkdir -p $tmpdir
			echo "#######       Linking $tmpdir "
			/bin/ln -s $tmpdir
		endif
	endif
end

if ( ${system} != "iqla_scripts" ) then
	#  Run isdc_opus_install.csh to populate OPUS_WORK
	echo "#######   Installing OPUS_WORK with isdc_opus_install.csh"
	${ISDC_ENV}/opus/pipeline_lib/isdc_opus_install.csh --opus_version=$ISDC_OPUS_VERSION --system=$system --quiet
	if ( $status >0 ) then
		echo "#######   status was non-zero"
		exit 1
	endif
endif

if ( $?TEST_DATA_TGZ ) then
	if ( -r  ${ISDC_TEST_DATA_DIR}/${TEST_DATA_TGZ} ) then
		echo "#######   Untaring ${ISDC_TEST_DATA_DIR}/${TEST_DATA_TGZ} with opts $taropts"
		/bin/gunzip -c ${ISDC_TEST_DATA_DIR}/${TEST_DATA_TGZ} | /bin/tar $taropts -
	else if ( -r  /isdc/testdata/unit_test/${TEST_DATA_TGZ} ) then
		echo "#######   Untaring /isdc/testdata/unit_test/${TEST_DATA_TGZ} with opts $taropts"
		/bin/gunzip -c /isdc/testdata/unit_test/${TEST_DATA_TGZ} | /bin/tar $taropts -
	else
		echo "#######   ERROR:  cannot read ${ISDC_TEST_DATA_DIR}/${TEST_DATA_TGZ}"
		exit 2
	endif
else
	if ( ! -e test_data ) /bin/mkdir test_data
endif

if ( $?OUTREF_TGZ ) then
	if ( -r  ${ISDC_TEST_DATA_DIR}/${OUTREF_TGZ} ) then
		echo "#######   Untaring ${ISDC_TEST_DATA_DIR}/${OUTREF_TGZ} with opts $taropts"
		/bin/gunzip -c ${ISDC_TEST_DATA_DIR}/${OUTREF_TGZ} | /bin/tar $taropts -
		/bin/chmod -R a-w outref/*
	else if ( -r  /isdc/testdata/unit_test/${OUTREF_TGZ} ) then
		echo "#######   Untaring /isdc/testdata/unit_test/${OUTREF_TGZ} with opts $taropts"
		/bin/gunzip -c /isdc/testdata/unit_test/${OUTREF_TGZ} | /bin/tar $taropts -
		/bin/chmod -R a-w outref/*
	else
		echo "#######   WARNING:  cannot read ${ISDC_TEST_DATA_DIR}/${OUTREF_TGZ}"
	endif
endif


#
#	050428 - Jake - This script was created to build an IC_TREE
#		since we are no longer creating "Versioned" IC_TREEs
#		I did this in a separate script because almost all unit_tests
#		will need this function.
#
#set ICVersion = "20070123"
#set ICVersion = "20070208"
#set ICVersion = "20070219"
#set ICVersion = "20070308"
#set ICVersion = "20070601"
#set ICVersion = "20070905" # BAD
#set ICVersion = "20070906"
#set ICVersion = "20070917A"
#set ICVersion = "20070919"
#set ICVersion = "20070925B"
#set ICVersion = "20071115"
set ICVersion = "20071130"
cd $REP_BASE_PROD
echo "#######   Building IC Tree Version $ICVersion"
echo "#######    in REP_BASE_PROD +$REP_BASE_PROD+"


if ( -e       /isdc/ic_tree/${ICVersion} ) then
	/bin/ln -s /isdc/ic_tree/${ICVersion}/ic
	/bin/mkdir -p idx
	cd idx
	/bin/ln -s /isdc/ic_tree/${ICVersion}/idx/ic
	cd ..
else if ( -e       /unsaved_data/wendt/ic_tree/${ICVersion} ) then
	/bin/ln -s /unsaved_data/wendt/ic_tree/${ICVersion}/ic
	/bin/mkdir -p idx
	cd idx
	/bin/ln -s /unsaved_data/wendt/ic_tree/${ICVersion}/idx/ic
	cd ..
else
	/bin/mkdir -p idx/ic
	cd idx/ic
	if ( -e       $ISDC_OPUS/ic/ic_master_file_${ICVersion}.fits ) then
		/bin/ln -s $ISDC_OPUS/ic/ic_master_file_${ICVersion}.fits ic_master_file.fits
		/bin/ln -s $ISDC_OPUS/ic/ic_master_file_${ICVersion}.fits ic_master_file_OSA6.fits
	else if ( -e  $ISDC_OPUS/ic_master_file_${ICVersion}.fits ) then
		/bin/ln -s $ISDC_OPUS/ic_master_file_${ICVersion}.fits ic_master_file.fits
	else if ( -e  /isdc/integration/isdc_int/sw/dev/prod/opus/ic/ic_master_file_${ICVersion}.fits ) then
		/bin/ln -s /isdc/integration/isdc_int/sw/dev/prod/opus/ic/ic_master_file_${ICVersion}.fits ic_master_file.fits
	else if ( -e  /isdc/arc/rev_2/idx/ic/ic_master_file_${ICVersion}.fits ) then
		/bin/ln -s /isdc/arc/rev_2/idx/ic/ic_master_file_${ICVersion}.fits ic_master_file.fits
	else
		echo "No ic_master_file_${ICVersion}.fits file found in any of the given locations!\n"
		exit 3
	endif

	###########################################################################
	###########################################################################

	#setenv OSA6_TEST		#	only used just below here

	###########################################################################
	###########################################################################

	if ( $?OSA6_TEST ) then
		foreach ICIDX ( `/bin/ls -1 /isdc/ic_tree/osa_ic-6.0.rc1/idx/ic/*-IDX.fits` ) 
			/bin/ln -s $ICIDX
		end
		cd ../..
		/bin/ln -s /isdc/ic_tree/osa_ic-6.0.rc1/ic
	else
		foreach ICIDX ( `/bin/ls -1 /isdc/arc/rev_2/idx/ic/*-IDX.fits` ) 
			/bin/ln -s $ICIDX
		end
		cd ../..
		/bin/ln -s /isdc/arc/rev_2/ic
	endif

endif




setenv ISDC_IC_TREE $REP_BASE_PROD

echo "#######   ISDC_IC_TREE is now set to +$ISDC_IC_TREE+"
cd $StartDir

/bin/mkdir -p ${OPUS_MISC_REP}/alert/${system}
/bin/mkdir -p ${OPUS_MISC_REP}/ifts
/bin/mkdir -p ${OPUS_MISC_REP}/log/ingest/trigger.COMPLETED

#	This may include unnecessary dirs.
foreach subdir ( "adp" "cons_rev" "cons_ssa" "cons_sa" "cons_scw" "ingest" "nrt_qla" "nrt_rev" "nrt_scw" )
	/bin/mkdir -p ${OPUS_MISC_REP}/trigger/${subdir}
end


echo "#######"
echo "####### -^- Done with unittest.data.csh"
echo "#######"

#	exit 1 = isdc_opus_install failed
#	exit 2 = test_data file not accessible
#	exit 3 = ic_master_file not accessible

#	last line
