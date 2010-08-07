#!/isdc/sw/perl/5.6.1/WS/7/bin/perl -w
##!/usr/bin/perl -w

use strict;
use ISDC::Level;

print "$ISDC::Level::VERSION\n";

my $l = new ISDC::Level('isgri','COR');
print "Instrument: ",$l->instrument,"\n";
print "Previous: ",$l->previous,"\n";
print "Current: ",$l->current,"\n";
print "Next: ",$l->next,"\n\n";

$l = new ISDC::Level('isgri','DEAD');
print "Instrument: ",$l->instrument,"\n";
print "Previous: ",$l->previous,"\n";
print "Current: ",$l->current,"\n";
print "Next: ",$l->next,"\n\n";

$l = new ISDC::Level('isgri','CLEAN');
print "Instrument: ",$l->instrument,"\n";
print "Previous: ",$l->previous,"\n";
print "Current: ",$l->current,"\n";
print "Next: ",$l->next,"\n\n";

#my @isgri = qw/COR GTI DEAD BIN_I BKG_I CAT_I IMA IMA2 BIN_S CAT_S SPE LCR COMP CLEAN/;
#my %levels = (
#	"isgri" => \@isgri
#);
#
#
#print "$isgri[1] \n";
#print "$levels{'isgri'}->[1] \n";
