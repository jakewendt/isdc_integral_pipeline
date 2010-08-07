#! /bin/sh
eval '  exec perl -x $0 ${1+"$@"} '
#! perl -s

my %comps;

#	( my $plist = $ENV{PIPELINELIST} ) =~ s/{|}//g;
#	my @list = split ",", $plist;

my @list = qw/adp conssa consssa nrtinput nrtscw nrtrev nrtqla pipeline_lib/;

while (<>) {	#	each line in the given file
	my $found;
	chomp;
	next if ( /^\s*$/ );
	next if ( /^\s*#/ );
	next if ( /Insert|makefiles|cfitsio|cfortran|templates|readline|sla_c|sla_f90|wcslib/ );
	next if ( /dal3gen|dal3aux|dal3omc|dal3ibis|dal3jemx|dal3spi|dal3cat|dal3hk/ );
	next if ( /isdc_dircmp|c_minuit|isdc_errors/ );
	next if ( /adp|consinput|consscw|consrev|conssa|consssa|nrtinput|nrtscw|nrtrev|nrtqla|pipeline_lib/ );

	my ( $component ) = /(\S+)/;

	next if ( $component =~ /^dal$/ );	#	exact match

#	print "$component\n";

	foreach my $pipeline ( @list ) {
#		print "\t$pipeline\n";
SCR:	foreach my $script ( glob "$pipeline/*p?" ) {
#			print "\t\t$script\n";
#			print `grep $component $script`;
			open SCRIPT, "< $script";
			while ( my $line = <SCRIPT> ) {
				chomp $line;
				next if ( $line =~ /^\s*$/ );
				next if ( $line =~ /^\s*#/ );
				next unless ( $line =~ /$component/ );
				$line =~ s/^\s+//;
				$line =~ s/\s+$//;
				printf ( "%-20s %-30s \n", $component, $script ) unless ( $html );
				$comps{$component}{$pipeline}++;
				$found++;
				next SCR;
#				printf ( "%-20s %-30s %-s \n", $component, $script, $line );
			}
			close SCRIPT;
		}
	}
	print "--------------- $component not found in any pipeline script\n" unless ( $found || $html );
}

print "<html><head><style>td { text-align: center; }</style></head><body><center><table width=100% wordwrap=1 border=\"1\">\n" if ( $html );

# Print result in particular order (by category, then alphabetical 
# within category).
foreach my $component (sort keys %comps ) {
      
#	$variable = $variable->[1];	#	don't know what this was for
	my $bgcolor = "white";
#	$bgcolor = "yellow" if ( $DS{$comp{$variable}{diffState}}{str} eq $DS{DIFFERENT}{str} );
#	$bgcolor = "red"    if ( $DS{$comp{$variable}{diffState}}{str} eq $DS{UNIQUE}{str} ); 

	print "<tr bgcolor=$bgcolor>\n\t<td>$component</td>\n" if ( $html );
	printf ("%-25s" , $component ) unless ( $html );   # closing semi-colon
	foreach my $pipeline ( @list ) {
		printf ("  %-12s", $comps{$component}{$pipeline} ) unless ( $html );
		print "\t<td>$comps{$component}{$pipeline}</td>\n" if ( $html );
	}
	print "</tr>\n" if ( $html );
	print "\n";
}

if ( $html ) {
	print "<tr>\n\t<td>Component</td>\n";
	foreach my $pipeline ( @list  ) {
		print "\t<td>$pipeline</td>\n";
	}
	print "</tr>\n";
	print "</table></center></body></html>\n";
}



exit(0);

#	last line
