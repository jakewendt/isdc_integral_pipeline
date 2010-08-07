#! /bin/sh
eval '  exec perl -x $0 ${1+"$@"} '
#! perl

( my $plist = $ENV{PIPELINELIST} ) =~ s/{|}//g;

my @list = split ",", $plist;

foreach my $pipeline ( @list ) {
	print "$pipeline\n";
	print `wc -l $pipeline/*p?`;
}

exit(0);

