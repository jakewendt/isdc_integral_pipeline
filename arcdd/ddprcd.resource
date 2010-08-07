
!-----------------------------------------------------------------------------
SYSTEM = 'ARCDD (Data Distribution)'
DISPLAY_ORDER=6
DESCRIPTION = 'Data Distribution Privacy'
PROCESS_NAME = ddprcd			! 060110 - Jake - probably not necessary, but ...

POLLING_TIME = 10         !seconds between tests for a new event
TASK = < xpoll -p $PATH_FILE -r ddprcd >  !the OPUS method for invoking
                          !the process
COMMAND = ddprcd.pl        !the script (in your path) that
                          !runs this pipeline process
CLASS = dd	!this is the process class for ease of sorting (inp,scw,qla,etc)
!===========================================================================
!
! This uses a single OSF trigger
!
OSF_RANK = 1              !this value could change if multiple trigger
                          !types are used in combination
OSF_TRIGGER1.NT      = c  ! If not notified yet and
OSF_TRIGGER1.PR      = w  !  and dist is FTP 
!===========================================================================
!
! Error trapping uses OSF status; 
!
XPOLL_STATE.00 = OSF_OK   !maps a successful exit status
XPOLL_STATE.01 = OSF_ERROR ! pipeline error
OSF_ERROR.PR = x           ! pipeline error
XPOLL_ERROR.PR       = x  ! other error
OSF_PROCESSING.PR    = p  ! set this OSF stage upon being triggered
OSF_OK.PR            = c  ! Completed keyword generation
!===========================================================================
