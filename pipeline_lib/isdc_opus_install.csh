#! /usr/bin/tcsh -f
#
# Create the proper directories for opus to run at isdc.
# assumes that opus_config.csh has been sucessfully run
#

while ($#argv > 0) 
	switch ($argv[1])
		case --h*:
			echo ""
			echo "USAGE:  isdc_opus_install.csh [--opus_version=3v2] [--system=nrt]"
			echo "where:"
			echo "       opus_version is 5v4b, 3v2 or 1v4"
			echo "       system is  nrt, adp, or cons"
			echo ""
			exit
			breaksw
		
		case --quiet:
			set quiet = "yes"
			breaksw
		
		case --opus_version=*:
			set oversion = `echo $argv[1] | cut -d"=" -f2`
			breaksw
		
		case --clean_misc_rep:
			set clean_misc_rep = "yes"
			breaksw
		
		case --system=*:
			set system = `echo $argv[1] | cut -d"=" -f2`
			breaksw
	
	endsw 
	
	shift 
end

if (! $?system) set system = $ISDC_ENV
if (! $?oversion) set oversion = "3v2" 			#	current default
if (! $?quiet) set quiet = "no"
if (! $?clean_misc_rep) set clean_misc_rep = "no"

if ($quiet != "yes") echo ">>>>>>>     Installing workspace for OPUS $oversion system $system"

####
#  Common stuff 
####

if ($quiet != "yes") echo "*******     Top level: $OPUS_WORK"

if (! -d "$OPUS_WORK") then
	mkdir $OPUS_WORK
	if ($status != 0) then
		echo "*******     ERROR:  cannot create $OPUS_WORK"
		exit 1
	endif
endif

##  First, cleanup
set contents = `ls $OPUS_WORK`
set partial = "no"

if ($#contents != 0) then 
	
	if ($quiet == "yes") then
		set answer = "y"
	else
		echo "*******     Cleaning up; remove all contents first?  [y]"
		set answer = $<
	endif
	
	if (($answer =~ "y") || ($answer =~ "Y") || ($answer == "")) then
		if ($quiet == "yes") echo "*******     Cleaning...."
	else
		#	echo "*******     Quitting."
		#	exit
		
		echo "*******     Attempting partial cleanup, leaving BB's untouched."
		echo "*******     Are you sure that all servers, managers, and processes are stopped?"
		echo "*******     Because if not, this will cause a mess."
		echo "*******     Type 'yes' if you're sure: "
		set answer = $<
		if ($answer != "yes") then
			echo "*******     You answered ${answer};  quitting"
			exit
		endif
		set partial = "yes"
	endif
	
	
	set jobs = `ls ${OPUS_WORK}/opus/*__`
	if ($#jobs != 0) then 
		echo ""
		echo "*******     ERROR:  cannot perform cleanup with processes running;"
		echo "*******     please kill everything throgh the PMG."
		echo ""
		exit
	endif 
	
	if ($partial == "no") then
		rm -rf $OPUS_WORK/*
	else
		rm -rf ${OPUS_WORK}/opus
	endif
	
endif
#
#
# First, the OPUS directory
mkdir $OPUS_WORK/opus
mkdir $OPUS_WORK/opus/lock

# do OPUS 3v2 stuff only if there
#if ($oversion == "3v2") then
if ($oversion != "1v4") then
	cp $ISDC_OPUS/pipeline_lib/opus.env $OPUS_HOME_DIR/

#	cp $ISDC_OPUS/pipeline_lib/opus_corba_objs_template $OPUS_HOME_DIR/opus_corba_objs	#	we don't need this

#	cp $SOGS_DISK/definitions/unix/opus.env $OPUS_HOME_DIR
#	cp $SOGS_DISK/definitions/unix/opus_corba_objs_template $OPUS_HOME_DIR/opus_corba_objs

	chmod +w $OPUS_HOME_DIR/*
	
	touch $OPUS_HOME_DIR/opus_iors		#	I guess this has to be here, but never seems to change
	chmod 600 $OPUS_HOME_DIR/opus_iors
endif

#  If a partial cleanup is all (i.e. only remove OPUS_HOME_DIR stuff),
#   then we're done.
if ($partial == "yes") then
	echo "*******     Re-init of OPUS_HOME_DIR done;  returning"
	exit
endif

#########
# Lastly, copy the omg and pmg files
####

#if ($oversion == "3v2") then 
if ($oversion != "1v4") then 
	if (! -e ~/OMG) then				#	assumes that if OMG is not there, that PMG isn't either.  errrr!
		ln -s /isdc/sw/opus/$oversion/OpusMgrs/OMG ~/OMG
		ln -s /isdc/sw/opus/$oversion/OpusMgrs/PMG ~/PMG
	endif
	if ($quiet == "yes") then
		set inis = "no"
	else
		echo "*******     Use default PMG and OMG .ini files?  [y]"
		set inis = $<
	endif
else
	if (! -e "~/omg.dat") cp $ISDC_OPUS/pipeline_lib/omg.dat ~/. 
	if (! -e "~/pmg.dat") cp $ISDC_OPUS/pipeline_lib/pmg.dat ~/.
endif

# Now, switch on ISDC_ENV to determine which pipelines to set up
#####
#	switch (${ISDC_ENV})
switch (${system})	#	050118 - Jake - changing this to $system since nrt and cons are now compiled in "all_sw"
	
	# NRT
	case *nrt*:
		echo "*******     Setting up workspace for NRT pipelines."
		mkdir $OPUS_WORK/nrtinput
		mkdir $OPUS_WORK/nrtscw
		mkdir $OPUS_WORK/nrtrev
		mkdir $OPUS_WORK/nrtqla
		if (($inis =~ "y") || ($inis =~ "Y") || ($inis == "")) then
			if (! -d ~/OPUSDATA) mkdir ~/OPUSDATA 
			cp $ISDC_OPUS/pipeline_lib/nrtOMG.ini ~/OPUSDATA/${USER}OMG.ini
			cp $ISDC_OPUS/pipeline_lib/nrtPMG.ini ~/OPUSDATA/${USER}PMG.ini
		endif
		breaksw
		##########
	
	# CONS
	case *cons*:
		echo "*******     Setting up workspace for CONS pipelines."
		mkdir $OPUS_WORK/consinput
		mkdir $OPUS_WORK/consscw
		mkdir $OPUS_WORK/consrev
		mkdir $OPUS_WORK/conssa				#	Standard Analysis
		mkdir $OPUS_WORK/consssa			#	Standard Science window Analysis
		#	mkdir $OPUS_WORK/conscor			#	Rerun correction step
		if (($inis =~ "y") || ($inis =~ "Y") || ($inis == "")) then
			cp $ISDC_OPUS/pipeline_lib/consOMG.ini ~/OPUSDATA/${USER}OMG.ini
			cp $ISDC_OPUS/pipeline_lib/consPMG.ini ~/OPUSDATA/${USER}PMG.ini
		endif
		breaksw
		##########
	
	# ADP
	case *adp*:
		echo "*******     Setting up workspace for ADP pipeline."
		mkdir $OPUS_WORK/adp
		if (($inis =~ "y") || ($inis =~ "Y") || ($inis == "")) then
			cp $ISDC_OPUS/pipeline_lib/adpOMG.ini ~/OPUSDATA/${USER}OMG.ini
			cp $ISDC_OPUS/pipeline_lib/adpPMG.ini ~/OPUSDATA/${USER}PMG.ini
		endif
		breaksw

	case *arc*:
		echo "*******     Setting up workspace for ARC pipeline."
		mkdir $OPUS_WORK/arc_distr
		mkdir $OPUS_WORK/arc_distr/queue
		mkdir $OPUS_WORK/arc_distr/stage
		mkdir $OPUS_WORK/arc_distr/distr
		mkdir $OPUS_WORK/arc_distr/count
		mkdir $OPUS_WORK/arc_distr/cron
		mkdir $OPUS_WORK/arc_distr/mail
		mkdir $OPUS_WORK/arc_distr/mdif
		if (($inis =~ "y") || ($inis =~ "Y") || ($inis == "")) then
			cp $ISDC_OPUS/pipeline_lib/arcOMG.ini ~/OPUSDATA/${USER}OMG.ini
			cp $ISDC_OPUS/pipeline_lib/arcPMG.ini ~/OPUSDATA/${USER}PMG.ini
		endif
		#    exit 1
		breaksw
	
	default:
		echo "Cannot determine environment.  OPUS setup incomplete"
		exit 1;
		breaksw
	
##########
endsw
##########

####
# Now, fill in pipeline dirs
####

foreach dir (`ls $OPUS_WORK`)
	
	if ($dir =~ *opus*) continue
	if ($dir !~ *arc_distr*) then 
		mkdir ${OPUS_WORK}/${dir}/input
		mkdir ${OPUS_WORK}/${dir}/logs
		mkdir ${OPUS_WORK}/${dir}/pfiles
		mkdir ${OPUS_WORK}/${dir}/scratch
	endif
	mkdir ${OPUS_WORK}/${dir}/obs
	mkdir ${OPUS_WORK}/${dir}/obs/lock
	
	# Are these necessary?
	#    if ($dir =~ *scw*) mkdir ${OPUS_WORK}/${dir}/scratch/ibis
	#    if ($dir =~ *rev*) mkdir ${OPUS_WORK}/${dir}/scratch/ibis
	
end


echo "*******     ISDC pipeline setup done"


###################################################################
#  Option to clean out alerts, triggers, etc.  Have to give an OPUS
#   version explicitely as first argument and this as second.  
if ( $clean_misc_rep == "yes") then
	if ($quiet == "yes") then
		set answer = "y"
	else
		echo ""
		echo "*******     Cleaning up OPUS_MISC_REP ${OPUS_MISC_REP}"
		echo "*******     Are you sure you want to remove all alerts, triggers, and IFTS in/outbox data ? [y]"
		set answer = $<
	endif
	#
	#  If first pass is yes
	#
	if (($answer == "") || ($answer =~ "y") || ($answer =~ "Y")) then
		
		if ($quiet != "yes") echo "*******     Looking for $OPUS_MISC_REP."
		if (! -d $OPUS_MISC_REP) then
			mkdir $OPUS_MISC_REP
			if ($status != 0) then
				echo "*******     ERROR:  cannot create $OPUS_MISC_REP"
				exit 1;
			endif
		endif
		#
		# Second:  check if we're using the real area
		#
		if ($quiet != "yes") echo "*******     Examining $OPUS_MISC_REP."
		if (($OPUS_MISC_REP == "/isdc") || ($OPUS_MISC_REP == "/isdc/")) then
			if ($quiet == "yes") then
				echo "Cannot clean $OPUS_MISC_REP with option --quiet"
				exit 1
			endif
			echo ""
			echo "*******     OPUS_MISC_REP set to $OPUS_MISC_REP !!"
			echo "*******     Are you REALLY sure you want to clean ${OPUS_MISC_REP}?!"
			echo "*******     Please type 'yes': "
			set $answer = $<
			if ($answer !~ "yes") then
				echo "*******     Quitting"
				exit;
			endif  # second answer yes
		endif # if real /isdc/

		#
		#  Now, really do it:
		#
		cd $OPUS_MISC_REP

		##########
		switch (${system})	#	050118 - Jake - changing this from $ISDC_ENV to $system since nrt and cons are now compiled in "all_sw"
			
			# NRT
			case *nrt*:
				set files = (`ls alert/nrt/*`)  
				if ($#files != 0) rm alert/nrt/* 
				set files = (`ls trigger/nrt_scw/*`)
				if ($#files != 0)  rm trigger/nrt_scw/*
				set files = (`ls trigger/nrt_rev/*`)
				if ($#files != 0) rm trigger/nrt_rev/*
				set files = (`ls trigger/nrt_qla/*`)
				if ($#files != 0) rm trigger/nrt_qla/*
				
				set files = (`ls alert/nrtdrmon/*`)
				if ($#files != 0) rm alert/nrtdrmon/*
				set files = (`ls alert/nrtppmon/*`)
				if ($#files != 0) rm alert/nrtppmon/*
				set files = (`ls log/nrtpp/*`)
				if ($#files != 0) rm log/nrtpp/*
				set files = (`ls ifts/outbox.tmp/*`)
				if ($#files != 0) rm ifts/outbox.tmp/*
				breaksw
				##########
				
			# CONS
			case *cons*:
				set files = (`ls alert/cons/*`)
				if ($#files != 0) rm alert/cons/*
				set files = (`ls trigger/cons_scw/*`)
				if ($#files != 0) rm trigger/cons_scw/*
				set files = (`ls trigger/cons_rev/*`)
				if ($#files != 0) rm trigger/cons_rev/*
				set files = (`ls trigger/cons_sa/*`)
				if ($#files != 0) rm trigger/cons_sa/*
				set files = (`ls trigger/cons_ssa/*`)
				if ($#files != 0) rm trigger/cons_ssa/*
				breaksw
				##########
				
			# ADP
			case *adp*:
				set files = (`ls alert/adp/*`)
				if ($#files != 0) rm alert/adp/*
				set files = (`ls trigger/adp/*`)
				if ($#files != 0) rm trigger/adp/*
				set files = (`ls ifts/inbox/*`)
				if ($#files != 0) rm ifts/inbox/*
				breaksw
				
			case *arc*:
				echo "*******     Nothing in arc to clean"
				breaksw
				
			default:
				echo "***  ERROR: Cannot determing environment from system/ISDC_ENV ${ISDC_ENV}"
				exit 1
				breaksw
		##########
		endsw
		##########
	endif  # if first answer yes

endif  

echo "*******     DONE."
exit

#	last line
