
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
!ENV.USELOCALDISKS = 1        !       variable to use local disks for processing.  Comment out if no.
ENV.TIMEOUT = 14400



!ENV.REDO_CORRECTION = 1			!       variable to redo correction step.  Comment out if no. (also in cssst and cssfin.resource)
!ENV.CREATE_REV_3    = 1		! variable when set in conjunction with REDO_CORRECTION will copy rev_2 instead of link it
										! uncomment to copy, comment out to link (also in cssfin.resource)
										! Here, it flags the running of evts_pick.

!ENV.OSA_VERSION = 
!	_test_7.3
