#!/usr/bin/perl -w

use strict;
use lib "/isdc/integration/isdc_int/sw/dev/prod/opus/pipeline_lib";
use SSALIB;

foreach ( qw/0370_Gal__Bulge_region_isgri.trigger 0370_GX_17+2_isgri.trigger 0418_Gal__Bulge_region_isgri.trigger/ ) {
	print "$_\n\n";
	print SSALIB::Trigger2OSF ( $_ );
	print "\n------------------\n\n\n";
}
