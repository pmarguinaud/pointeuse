#!/home/marguina/install/perl-5.36.0/bin/perl -w

use strict;
use FindBin qw ($Bin);
use lib $Bin;
use Data::Dumper;
use Meteo::Pegase;

print &Meteo::Pegase::workTodayAM (@ARGV), "\n";
print &Meteo::Pegase::workTodayPM (@ARGV), "\n";
