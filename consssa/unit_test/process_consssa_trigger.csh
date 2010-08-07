#!/bin/csh -f

if ( $#argv != 1 ) then
	echo "-------     "
	echo "-------     $0 can only use a single parameter of the trigger file!"
	echo "-------     "
	exit
endif

set trigger=$argv[1]
echo "-------     "
echo "-------     running $0 on $trigger"
echo "-------     "




#foreach trigger (`/bin/ls opus_work/consssa/input/* | /bin/awk -F. '{print $1}' | /bin/awk -F/ '{print $4}' | /bin/sort`)



	echo "###############################################################################"
	echo "######"
	echo "######  RUNNING:  opus_wrapper on pipeline consssa for $trigger"
	echo "######"
	echo "######    You should see no errors"
	echo "######"

	#	testing second scw
	#if ( $trigger == "002400050010" ) then
	#	continue
	#endif
	
	#  Unlike other pipelines, we must control this here;  opus_wrapper isn't
	#   smart enough and it is easier here:
	
	###############################################
	#  So first the startup:
	###############################################
	${ISDC_ENV}/opus/pipeline_lib/opus_wrapper cssst $trigger ${OPUS_WORK}/${trigger}_cssst.log
	@ exit_status = $status 
	echo "#######     exit status from opus_wrapper was $exit_status"
	if ($exit_status > 0) exit 1
	
	###############################################
	#  Now we see what triggers were created:
	###############################################
	echo "#######     Examining OSFs created..."
	set obsosfs =  `osf_test -p consssa.path -pr dataset`
	echo "#######     $obsosfs"
	
	###############################################
	#  Loop over Obs groups, i.e. instruments
	###############################################
	foreach obsosf ($obsosfs) 
		set obsgrp = $obsosf[1]
		echo "#######     Obs group OSF is ${obsgrp}"
		echo "#######     Running cssscw for ${obsgrp}"
		echo "#######     Running 'osf_test -p consssa.path -pr dcf_num -f $obsgrp'"
		set ins = `osf_test -p consssa.path -pr dcf_num -f $obsgrp ` 

		#if (($ins != "JX1") && ($ins != "JX2")) then
		#	continue
		#endif
		#if ( $ins == "ISG" ) continue 
		#if ( $ins == "PIC" ) continue 

		if ($status != 0) exit 1
		eval `/usr/bin/envv set OSF_DCF_NUM $ins`
		echo "#######     OSF_DCF_NUM is $OSF_DCF_NUM"

		${ISDC_ENV}/opus/pipeline_lib/opus_wrapper cssscw $obsgrp ${OPUS_WORK}/${obsgrp}_cssscw.log
		@ exit_status = $status 
		echo "#######     exit status from opus_wrapper was $exit_status"
		if ($exit_status > 0) exit 1
		
		echo "#######     Running cssfin for ${obsgrp}"
		
		${ISDC_ENV}/opus/pipeline_lib/opus_wrapper cssfin $obsgrp ${OPUS_WORK}/${obsgrp}_cssfin.log
		@ exit_status = $status 
		echo "#######     exit status from opus_wrapper was $exit_status"
		if ($exit_status > 0) exit 1
		
	end  # foreach instrument
	

	#  Now we have to clean up the blackboard so that the next trigger sees 
	#   only its related OSFs:
#	foreach osf ( `osf_test -p consssa.path -pr dataset`)
#		echo "#######     running 'osf_delete -p consssa.path -f $osf'"
#		osf_delete -p consssa.path -f $osf
#		if ( $status != 0 ) exit 1
#	end

	foreach osf ( `osf_test -p consssa.path -pr dataset`)
		set command = "cleanup.pl --path=consssa --dataset=$osf --level=opus --do_not_confirm"
		echo "#######     Running $command"
		$command
		if ( $exit_status > 0 ) exit 1
	end

#	end  # foreach trigger

exit

#	last line
