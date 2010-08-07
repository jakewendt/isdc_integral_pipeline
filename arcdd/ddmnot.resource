
!-----------------------------------------------------------------------------
SYSTEM = 'ARCDD (Data Distribution)'
DISPLAY_ORDER=6
DESCRIPTION = 'Data Distribution Notification'
PROCESS_NAME = ddmnot			! 060110 - Jake - probably not necessary, but ...

POLLING_TIME = 10         !seconds between tests for a new event
TASK = < xpoll -p $PATH_FILE -r ddmnot >  !the OPUS method for invoking
                          !the process
COMMAND = ddmnot.pl        !the script (in your path) that
                          !runs this pipeline process
CLASS = dd	!this is the process class for ease of sorting (inp,scw,qla,etc)
!===========================================================================
!
! This uses a single OSF trigger
!
OSF_RANK = 1              !this value could change if multiple trigger
                          !types are used in combination
OSF_TRIGGER1.NT      = w  ! If not notified yet and
OSF_TRIGGER1.FD      = f  !  and dist is FTP 
! OR
OSF_TRIGGER2.NT      = w  ! If not notified yet and 
OSF_TRIGGER2.CV      = c  !  and writing done
!===========================================================================
!
! Error trapping uses OSF status; 
!
XPOLL_STATE.00 = OSF_OK   !maps a successful exit status
XPOLL_STATE.01 = OSF_ERROR ! pipeline error
OSF_ERROR.NT = x           ! pipeline error
XPOLL_ERROR.NT       = x  ! other error
OSF_PROCESSING.NT    = p  ! set this OSF stage upon being triggered
OSF_OK.NT            = c  ! Completed keyword generation
!===========================================================================
