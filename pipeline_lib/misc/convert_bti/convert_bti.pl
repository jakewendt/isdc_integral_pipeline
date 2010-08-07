#! /bin/sh
eval '  exec perl -x $0 ${1+"$@"} '
#! perl

use strict;
use ISDCPipeline;
my ($retval,@results);
$ENV{COMMONLOG_FILE} = "+";

die "No file given as first argument" unless $ARGV[0];

my %hsh;
$hsh{"start"}{"in"}   = "OBT_START";
$hsh{"start"}{"oijd"} = "START";
$hsh{"start"}{"outc"} = "UTC_START";

$hsh{"stop"}{"in"}    = "OBT_END";
$hsh{"stop"}{"oijd"}  = "STOP";
$hsh{"stop"}{"outc"}  = "UTC_END";

foreach my $key ( keys ( %hsh ) ) {

	print "\n\nProcessing $hsh{$key}{'in'}\n\n";
	print "$hsh{$key}{'oijd'}\n";
	print "$hsh{$key}{'outc'}\n";

	($retval,@results) = &ISDCPipeline::RunProgram (
		"dal_dump inDol=$ARGV[0] column=$hsh{$key}{'in'} outFormat=0"
		);

	my $row = 1;
	my $format = "%8s %30s %16s %24s %26s %26s %26s\n";
	printf ( $format,  "--ROW--", "ORIGINAL_OBTFITS","ORIG_OBT","ORIGINAL_IJD","CALULATED_IJD","ORIGINAL_UTC","CALCULATED_UTC" );

	foreach ( @results ) {
		chomp;
		next if ( /^\s*$/ );
		next if ( /Log/ );
#		print "-- $row --";
#		print $_;
		my $obt = &CONVERT ( $_, "OBTFITS", "OBT" );	
#		print " $obt ";
		chomp ( my $b4ijd = `fdump infile=$ARGV[0] outfile=STDOUT columns=$hsh{$key}{'oijd'} rows=$row prhead=n showunit=n showrow=n showcol=n | tail -1` );
#		print $b4ijd;
		my $ijd = &CONVERT ( $obt, "OBT", "IJD" );	
#		print " $ijd ";

		chomp ( my $b4utc = `fdump infile=$ARGV[0] outfile=STDOUT columns=$hsh{$key}{'outc'} rows=$row prhead=n showunit=n showrow=n showcol=n | tail -1` );
#		print $b4utc;
		my $utc = &CONVERT ( $obt, "OBT", "UTC" );	
#		print " $utc ";

		printf ( $format, $row, $_, $obt, $b4ijd, $ijd, $b4utc, $utc );

		`ftedit $ARGV[0] $hsh{$key}{'oijd'} $row $ijd`;
		die "ftedit failed.  ' source \$HEADAS/headas-init.csh ' probably not run." if $?;
		`ftedit $ARGV[0] $hsh{$key}{'outc'} $row $utc`;

		$row++;
	}
}


exit;





######################################################################

sub CONVERT {
	my ( $time, $in, $out ) = @_;

#	my ($retval,@results) = &ISDCPipeline::RunProgram(              
#		"converttime informat=$in intime=\"$time\" outformat=$out dol= accflag=3"
#		);
#	&Error ( "Converttime $in $time 2 $out failed." ) if ( $retval );
	my @results = `converttime informat=$in intime=\"$time\" outformat=$out dol= accflag=3`;

	my $result;
	foreach ( @results ) {
		next unless /^.*.${out}.:\s+(\S+)\s*$/i;
		$result = $1;
		last;
	}
	&Error ( "cannot parse result:@results" ) unless ($result =~ /\w/);

	return $result;
}
