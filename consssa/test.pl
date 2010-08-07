#!/usr/bin/perl -w

print "testing\n";

system ( "echo "
	."\"notice \nquit\" "
	."| xspec" );

exit;
