
!-----------------------------------------------------------------------------
SYSTEM = 'ARCDD (Data Distribution)'
DISPLAY_ORDER=4
DESCRIPTION = 'Data Distribution Writing'
PROCESS_NAME = ddvcpv			! 060110 - Jake - probably not necessary, but ...

POLLING_TIME = 10         !seconds between tests for a new event
TASK = < xpoll -p $PATH_FILE -r ddvcpv >  !the OPUS method for invoking
                          !the process
COMMAND = ddvcpv.pl        !the script (in your path) that
                          !runs this pipeline process
CLASS = dd	!this is the process class for ease of sorting (inp,scw,qla,etc)
!===========================================================================
!
! This uses a single OSF trigger
!
OSF_RANK = 1              !this value could change if multiple trigger
                          !types are used in combination
OSF_TRIGGER1.FD      = v  ! If DVD distribution
OSF_TRIGGER1.CV      = w  !  and operator has written DVD
!===========================================================================
!
! Error trapping uses OSF status; 
!
XPOLL_STATE.00 = OSF_OK   !maps a successful exit status
XPOLL_STATE.01 = OSF_ERROR ! pipeline error
OSF_ERROR.CV = x           ! pipeline error
XPOLL_ERROR.CV       = x  ! got an error
OSF_PROCESSING.CV    = p  !set this OSF stage upon being triggered
OSF_OK.CV            = c  ! Completed keyword generation
!===========================================================================
