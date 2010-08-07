#! /bin/sh
eval '  exec perl -x $0 ${1+"$@"} '
#! perl

( my $plist = $ENV{PIPELINELIST} ) =~ s/{|}//g;

my @list = split ",", $plist;

foreach my $pipeline ( @list ) {
	print "\n----------------------\n$pipeline\n----------------------\n";
	my @actual;

	my @list = `grep \"program_name\" $pipeline/*p?`;
	foreach ( @list ) {
		chomp;
		my ( $comp ) = ( /\=\>\s*(.*)$/ );
		$comp =~ s/^(\s*")//;
		$comp =~ s/(",\s*)$//;
		next unless ( $comp );
		next if ( /ERROR/ );
		next if ( /COPY/ );
		next if ( /NONE/ );
		next if ( /CHECK/ );
		next if ( /\$my/ );
		push @actual, $comp;
	}


#	my @list = `grep RunProgram $pipeline/*p?`;
#	foreach ( @list ) {
#		chomp;
#		my $comp = $_;
#		next unless ( $comp );
#		push @actual, $comp;
#	}



	my @sorted = sort { $a cmp $b } @actual;
	foreach my $comp ( @sorted ) {
		print "$comp \n";
	}
	
}

exit(0);

