#!/home/marguina/install/perl-5.36.0/bin/perl -w

use strict;
use FindBin qw ($Bin);
use lib $Bin;

use Meteo::Planning;
use Meteo::Pegase;
use Data::Dumper;
use Date::Calc qw (Week_of_Year Monday_of_Week Today Delta_Days);
use File::Spec;

my $bin = 'File::Spec'->rel2abs ($0);

die unless (scalar (@ARGV) >= 1);

my ($date, $when, $work) = @ARGV;

my $init = (! defined ($when)) && (! defined ($work));
$when ||= 'AM';
$work ||= 0;

my @date = &parseYYYYMMDD (substr ($date, 0, 8));

my $p = &Meteo::Planning::planning (@date);

my ($week, $year) = &Week_of_Year (@date);
my @monday = &Monday_of_Week ($week, $year);

my $Dd = &Delta_Days (@monday, @date);

splice (@$p, 0, 4) for (1 .. $Dd);
splice (@$p, 0, 2) if ($when eq 'PM');


if ($work)
  {
    print "POINTAGE : @{$p->[0]}\n";
  }

shift (@$p) unless ($init);

exit (0) unless (@$p);


print "at -t $p->[0][0] $bin @{$p->[0]}\n";


