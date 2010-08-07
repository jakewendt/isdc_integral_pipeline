
!-----------------------------------------------------------------------------
SYSTEM = 'ARCDD (Data Distribution)'
DISPLAY_ORDER=2
DESCRIPTION = 'Data Distribution Packaging'
PROCESS_NAME = ddsdir			! 060110 - Jake - probably not necessary, but ...

POLLING_TIME = 10         !seconds between tests for a new event
TASK = < xpoll -p $PATH_FILE -r ddsdir >  !the OPUS method for invoking
                          !the process
COMMAND = ddsdir.pl        !the script (in your path) that
                          !runs this pipeline process
CLASS = dd	!this is the process class for ease of sorting (inp,scw,qla,etc)
!===========================================================================
!
! This uses a single OSF trigger
!
OSF_RANK = 1              !this value could change if multiple trigger
                          !types are used in combination
OSF_TRIGGER1.SD      = w  !when OSF column DP = "w" (waiting)
OSF_TRIGGER1.DI      = c  !and when OSF column YY = "c" (complete)
!===========================================================================
!
! Error trapping uses OSF status; 
!
XPOLL_STATE.00 = OSF_OK   !maps a successful exit status
XPOLL_STATE.01 = OSF_ERROR ! pipeline error
OSF_ERROR.SD = x           ! pipeline error
XPOLL_ERROR.SD       = x  ! got an error
OSF_PROCESSING.SD    = p  !set this OSF stage upon being triggered
OSF_OK.SD            = c  ! Completed keyword generation
OSF_OK.FD            = w  ! next stage is 'wait'
!===========================================================================
