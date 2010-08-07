#!/isdc/sw/perl/5.6.1/WS/7/bin/perl -w 

use strict;

my $lref;

my %levels = (
	"isgri" => [ qw/COR GTI DEAD BIN_I BKG_I CAT_I IMA IMA2 BIN_S CAT_S SPE LCR COMP CLEAN/ ],
	"jemx"  => [ qw/COR GTI DEAD CAT_I BKG BIN_I IMA SPE LCR BIN_S BIN_T IMA2/ ],
	"omc"   => [ qw/COR GTI IMA IMA2/ ],
);

my @arr = qw/COR GTI IMA IMA2/;
my $name = 'arr';

#$lref = \@{$levels{isgri}};
no strict 'refs';
$lref = \@{$name};

print @$lref->[0],"\n";
print @arr->[0],"\n";


#my @isgri = qw/COR GTI DEAD BIN_I BKG_I CAT_I IMA IMA2 BIN_S CAT_S SPE LCR COMP CLEAN/;
#my @lref;
#my $inst = 'isgri';


#no strict 'refs';
#$lref = \@isgri;
#@lref = @{$inst};
#print "$inst\n";
#print $lref[0],"\n";

