#!/home/marguina/install/perl-5.36.0/bin/perl -w

use strict;
use FindBin qw ($Bin);
use lib $Bin;

use Meteo::Planning;
use Data::Dumper;


my @date = @ARGV;

my $p = &Meteo::Planning::planning (@date);

print &Dumper ($p);


