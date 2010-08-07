#!/usr/bin/perl -w 

use strict;
use ISDCPipeline;


&ISDCPipeline::RunProgram (
"fextract infile=\"/isdc/arc/rev_2/scw/0014/rev.002/osm/intl_avg_hk.fits[INTL-PLM.-AVG][SWID==\'001400050010\']\" outfile=intl_avg_hk.fits"
);

exit;


   my $original_pfiles   = $ENV{PFILES};
   my $original_parfiles = $ENV{PARFILES};
   $ENV{PARFILES} = "/tmp/$$-ftools/";
   system ( "mkdir $ENV{PARFILES}" );


	#	NOTE
	#	this fdump actually excedes 256 characters and hence trims the last 3 columns (EXPOSURE, TSTART, TSTOP)
	#	If these are needed, be more specific about which columns are needed
   my ($retval,@result) = &ISDCPipeline::RunProgram ( 
		"fdump infile=test3.fits outfile=STDOUT columns=- rows=- prhead=no pagewidth=256 page=no wrap=yes showrow=no showunit=no showscale=no fldsep=,"
		);
	open SRCINFO, "> srcinfo.txt";

   foreach ( @result ) {
      next if ( /^\s*$/ );
      next unless ( ( /^\s*SWID\s*SOURCE_ID\s*NAME/ )
         || ( /GRS 1758-258/ )
         || ( /Ginga 1826-24/ )
         || ( /Cyg X-1/ )
         || ( /Cyg X-3/ )
         || ( /IGR J06074\+2205/ )
         || ( /Crab/ )
         );      
		my @columns;
		if ( /^\s*SWID\s*SOURCE_ID\s*NAME/ ) {
			@columns = split /\s+/;
		} else {
			@columns = split /\s*,\s*/;
		}
#		print $columns[$#columns-1],"\n";			#	$#columns-1 is the next to last column which works here since the last 3 are trimmed
		next if ( $columns[$#columns-1] =~ /INDEF/ );
#		print $_;
		printf "%15s %20s %15s %15s %15s %15s %15s %15s\n",
			$columns[0],
			$columns[1],
			$columns[2],
			$columns[3],
			$columns[4],
			$columns[5],
			$columns[9],
			$columns[13];

   }
	close SRCINFO;

#     
#     We wish to study two data sets defined as all scw obtained within 7 degrees of
#     
#     A) RA=18:15:00  DEC=-25:00:00    containing  GRS 1758-258 and Ginga 1826-24
#     B) RA=20:16:00  DEC=+37:48:00    containing  Cyg X-1 & Cyg X-3
#     
#     You can obtain the list of those scw using Browse. The couple of sources indicated
#     in each field is important in the procedure that follows.
#     
   
#     - with fv filter out all sources excepting the couples listed in  the field definition above
#     - with fv filter out all results which did not converge (Flux  error = 0)
#     - build a file containing
#     SWID   (RA,DEC) for source 1     (RA,DEC) for source 2
#     for all scw in which both sources are detected
#     
#     we need also in this file
#     RA_SCX DEC_SCX RA_SCZ DEC_SCZ
#
#     - for each of those scw add in the file the content of one hk  file as available in the archive (ask for the detail)
#
#     for the two last points playing with some script/ftool is needed.
#     Check with us if you have any problem or question in any of those steps. 
#     

   system ( "/bin/rm -rf $ENV{PARFILES}" );
   $ENV{PARFILES} = $original_parfiles;
   $ENV{PFILES}   = $original_pfiles;

