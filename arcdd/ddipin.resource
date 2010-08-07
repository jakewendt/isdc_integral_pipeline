
!-----------------------------------------------------------------------------
SYSTEM = 'ARCDD (Data Distribution)'
DISPLAY_ORDER=1
DESCRIPTION = 'Data Distribution Input'
PROCESS_NAME = ddipin			! 060110 - Jake - probably not necessary, but ...

POLLING_TIME = 10         !seconds between tests for a new event
TASK = < xpoll -p $PATH_FILE -r ddipin >  !the OPUS method for invoking
                          !the process
COMMAND = ddipin.pl        !the script (in your path) that
                          !runs this pipeline process
CLASS = dd	!this is the process class for ease of sorting (inp,scw,qla,etc)
XPOLL_STATE.00 = FILE_SUCCESS
XPOLL_STATE.01 = FILE_ERROR

FILE_RANK = 1             !this value could change if multiple trigger
                          !types are used in combination
FILE_DIRECTORY1 = arc_dd_queue   !incoming data found here.  Note this
                          ! this is a reference to the adp.path file
FILE_OBJECT1 = *.trigger     !trigger on files with this extension
FILE_PROCESSING = _work   ! Extension addition during processing
FILE_SUCCESS    = _processing   ! Extension addition if normal processing
FILE_ACTION = '/bin/rm -f ^f'	!  but then just remove it
FILE_ERROR      = _bad    ! Extension addition if error 
XPOLL_ERROR     = _bad

