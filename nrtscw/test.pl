#!/usr/bin/perl

$ENV{SCWDIR} = "/isdc/arc/rev_2/scw";
$ENV{OSF_DATASET} = "040000680040";
my $revno = "0400";

my @scwdirs =  grep /\d{12}\.\d{3}/, glob ( "$ENV{SCWDIR}/$revno/*" );

foreach ( @scwdirs ) {
	print "$_\n";
}

print "\$ENV{OSF_DATASET} $ENV{OSF_DATASET}\n";
print "last $scwdirs[$#scwdirs]\n";

if ( $scwdirs[$#scwdirs] =~ /$ENV{OSF_DATASET}/ ) {
	print "OSF is the last!\n";
}

if ( $ENV{OSF_DATASET} =~ /1$/ ) {
	print "OSF is a SLEW!\n";
}


if ( ( $scwdirs[$#scwdirs] !~ /$ENV{OSF_DATASET}/ ) 
	|| ( $ENV{OSF_DATASET} !~ /0$/ ) ) {
	print "bummer\n";
}

my ($sec,$min,$hr,$dom,$mon,$yr,$dow,$doy,$dlst) = localtime(time);
my @months = qw/Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec/;
$yr+=1900;
print "$ENV{OSF_DATASET}            dp_aux_attr             11452           automatically added by cswdp on $dom-$months[$mon]-$yr\n";

