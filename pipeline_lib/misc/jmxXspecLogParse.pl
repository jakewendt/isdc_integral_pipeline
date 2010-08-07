#! /bin/sh
eval '  exec perl -x $0 ${1+"$@"} '
#! perl

use strict;

my $format  = "%-21s %20s %20s %20s %20s\n";
my $format2  = "%-21s %20s %20s %20s %20s\n";
#my $format2 = "%-21s %20.8g %20.8g %20.8g %20.8g\n";
my @result;
my $source;
my $output;
my %data;

while (<>) {
	next if ( /^Log/ );
	next if ( /^Error/ );
	next if ( /^Warn/ );
	next if ( ( /^-----/ ) && ( ! /-----   Input             : / ) );
	next if ( /^>>>>>>>/ );

	next unless ( /Source File:/ )
		||    ( /-----\s+Input/ )
		||    ( /powerlaw   PhoIndex/ )
		||    ( /powerlaw   norm/ )
		||    ( /Reduced chi-squared/ )
		||    ( /Null hypothesis probability/ );

#	-----   Input             : ssj1_023900450010
#	 Source File: spectrum_0.fits
#    2    2   powerlaw   PhoIndex            1.00000      +/-  0.0          
#    3    2   powerlaw   norm                1.00000      +/-  0.0          
#  Reduced chi-squared =    3.01553e+06 for      5 degrees of freedom 
#  Null hypothesis probability =   0.000000e+00
#    2    2   powerlaw   PhoIndex            2.31716      +/-  4.07892E-02  
#    3    2   powerlaw   norm                0.283118     +/-  2.35232E-02  
#  Reduced chi-squared =       1.855399 for      5 degrees of freedom 
#  Null hypothesis probability =   9.851285e-02

	if ( /-----\s+Input\s*:\s*(ssj\d_\d{12})/ ) {
		$output = $1;
	} elsif ( /Source File:\s*(.+)/ ) {
		$source = $1;
#	} elsif ( /PhoIndex\s+([e\-\+\d\.]+)\s+/i ) {
#		$data{$source}{"phoindex"} = $1;
#	} elsif ( /norm\s+([e\-\+\d\.]+)\s+/i ) {
#		$data{$source}{"norm"} = $1;
#	} elsif ( /Reduced chi-squared\s*=\s+([e\-\+\d\.]+)\s+/i ) {
#		$data{$source}{"redchisq"} = $1;
#	} elsif ( /Null hypothesis probability\s*=\s+([e\-\+\d\.]+)\s+/i ) {
	} elsif ( /PhoIndex\s+(\S+)\s+/i ) {
		$data{$source}{"phoindex"} = $1;
	} elsif ( /norm\s+(\S+)\s+/i ) {
		$data{$source}{"norm"} = $1;
	} elsif ( /Reduced chi-squared\s*=\s+(\S+)\s+/i ) {
		$data{$source}{"redchisq"} = $1;
	} elsif ( /Null hypothesis probability\s*=\s+(\S+)\s+/i ) {
		$data{$source}{"nulhyppro"} = $1;
	}
}

open ( OUTPUT, "> $output" );
printf OUTPUT $format, "FILENAME", "PhoIndex", "norm", "Red chi-sq", "Null hypothesis prob";

foreach ( sort keys %data ) {
	printf OUTPUT $format2, 
		$_,
		$data{$_}{phoindex},
		$data{$_}{norm},
		$data{$_}{redchisq},
		$data{$_}{nulhyppro};
}

#	(split /\s+/,(grep /Source File/, @result)[-1])[3],
#	(split /\s+/,(grep /PhoIndex/, @result)[-1])[5],
#	(split /\s+/,(grep /norm/, @result)[-1])[5],
#	(split /\s+/,(grep /Reduced chi-squared/, @result)[-1])[4],
#	(split /\s+/,(grep /Null hypothesis probability/, @result)[-1])[5];
#
#
close OUTPUT;


exit;
