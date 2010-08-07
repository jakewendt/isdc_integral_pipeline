
!-----------------------------------------------------------------------------
SYSTEM = 'ARCDD (Data Distribution)'
DISPLAY_ORDER=3
DESCRIPTION = 'Data Distribution Packaging'
PROCESS_NAME = ddfdir			! 060110 - Jake - probably not necessary, but ...

POLLING_TIME = 10         !seconds between tests for a new event
TASK = < xpoll -p $PATH_FILE -r ddfdir >  !the OPUS method for invoking
                          !the process
COMMAND = ddfdir.pl        !the script (in your path) that
                          !runs this pipeline process
CLASS = dd	!this is the process class for ease of sorting (inp,scw,qla,etc)
!===========================================================================
!
! This uses a single OSF trigger
!
OSF_RANK = 1              !this value could change if multiple trigger
                          !types are used in combination
OSF_TRIGGER1.FD      = w  !when OSF column DP = "w" (waiting)
OSF_TRIGGER1.SD      = c  !and when OSF column YY = "c" (complete)
!===========================================================================
!
! Error trapping uses OSF status; 
!
XPOLL_STATE.00 = OSF_ERROR ! NOTE:  shouldn't happen here!
XPOLL_STATE.01 = OSF_ERROR ! pipeline error
XPOLL_STATE.02 = OSF_FTP
XPOLL_STATE.04 = OSF_DVD
XPOLL_STATE.05 = OSF_TAPE
OSF_PROCESSING.FD    = p  !set this OSF stage upon being triggered
!  If error:
OSF_ERROR.FD = x           ! pipeline error
XPOLL_ERROR.FD       = x  ! got an error
!  If FTP:
OSF_FTP.FD            = f  ! FTP
OSF_FTP.CV            = -  ! operator does nothing
!  IF DVD:
OSF_DVD.FD            = v !  DVD
OSF_DVD.CV            = o  ! operator writes DVD
!  IF TAPE:
OSF_TAPE.FD            = t  !  TAPE
OSF_TAPE.CV            = o  !  operator writes tape
!
!===========================================================================

