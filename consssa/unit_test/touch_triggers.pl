#! /bin/sh
eval '  exec perl -x $0 ${1+"$@"} '
#! perl -ws

use SSALIB;

die "No trigger list given. ( -list=<filename> )" unless ( $list );

my ( $osfname, $dcf, $inst, $INST, $revno, $scwid ) = &SSALIB::Trigger2OSF ( "$list" );

open LIST, "< $list";
while ( <LIST> ) {
	chomp;
	s/\r//;	#	remove Microsoft's carriage return
	print "touch $ENV{OPUS_WORK}/consssa/input/${_}_$inst.trigger\n";
	`touch $ENV{OPUS_WORK}/consssa/input/${_}_$inst.trigger`;
}
close LIST;

exit;

#	last line
