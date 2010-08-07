
!===========================================================================
!
SYSTEM = 'CONS SA/ScW Analysis Pipeline'
DISPLAY_ORDER=1
DESCRIPTION = 'CONS SA/ScW Analysis'
PROCESS_NAME = cssscw

!===========================================================================
!
! XPOLL configuration stuff
!
POLLING_TIME = 60         !seconds between tests for a new event
TASK = < xpoll -p $PATH_FILE -r cssscw >  !the OPUS method for invoking
                                          !the process
COMMAND = cssscw.pl       !the script (in your path) that
                         !runs this pipeline process

CLASS = css 	!this is the process class for ease of sorting (inp,scw,qla,etc)
!
!===========================================================================
!
! This uses an OSF trigger
!
OSF_RANK = 1              !this value could change if multiple trigger
                          !types are used in combination
OSF_TRIGGER1.ST      = c  !when OSF column SA = "w" (waiting)
OSF_TRIGGER1.SA      = w  !when OSF column SA = "w" (waiting)
OSF_TRIGGER1.DATA_ID = scw  !  when it's an scw type trigger (not obs)
!
!===========================================================================
!
! Error trapping uses OSF status:
!
XPOLL_STATE.00 = OSF_OK   ! All ran sucessfully
XPOLL_ERROR.SA      = x   ! Extension addition if error
XPOLL_STATE.01 = OSF_ERROR ! pipeline errors
OSF_ERROR.SA   = x         ! pipeline errors
OSF_PROCESSING.SA    = p  ! set this OSF stage upon being triggered
OSF_OK.SA            = c  ! Completed 
!===========================================================================
!
!  Variables used in process script.  
!
ENV.OUTPATH = rii             ! repository 2
ENV.WORKDIR = work            ! where we work
ENV.LOG_FILES = log_files     ! where do we write log files?
!ENV.PARFILES = parfiles       ! parfiles go here
ENV.INPUT = rii_input         ! input trigger directory
ENV.IC_ALIAS = CONS
ENV.TIMEOUT = 14400

!===========================================================================
!
!	Advanced Processing Options
!
!
!		variable to use local disks for processing.  Comment out if no.
!ENV.USELOCALDISKS = 1        
!
!		variable to redo correction step.  Comment out if no. (also in cssst and cssfin.resource)
!ENV.REDO_CORRECTION = 1			
!
!		variable when set in conjunction with REDO_CORRECTION will copy rev_2 instead of link it
!		uncomment to copy, comment out to link (also in cssfin.resource)
!		Here, it flags the running of evts_pick.
!ENV.CREATE_REV_3    = 1		
!
!		If OSA_VERSION is set, it is appended to obs_$inst, returning obs_$inst${OSA_VERSION}
!ENV.OSA_VERSION = 
!	_test_7.3
!
!
!		DO NOT USE in normal processing.  Comment out unless you are explicity doing consssa testing.
!		SCREW 2046 Test
!	W_STAGE is used to determine the parameters in IBISLIB.pm
!	R_STAGE is used as a source for og_copy
!	These should be very unique strings as at one point W_STAGE is replaced with R_STAGE
!ENV.R_STAGE = .S01		!	Used as the read  obsdir when og_copy is run
!ENV.W_STAGE = .S02		!	Used as the write obsdir when og_create or og_copy is run
!
!	either also include the ENV.W_STAGE setting in cssfin.resource OR 
!	create a symbolic link between obs_isgri${W_STAGE} and obs_isgri
!
!
!	NOT USED
!ENV.STAGE = 1		!	og_create is run;  COR to BIN_I
!ENV.STAGE = 2		!	og_create is NOT run;  BKG_I to IMA
!

