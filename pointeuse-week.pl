#!/home/marguina/install/perl-5.36.0/bin/perl -w

use strict;
use FindBin qw ($Bin);
use lib $Bin;

use Meteo::Planning;
use Meteo::Pointeuse;
use Meteo::Pegase;
use Meteo::Report;
use Meteo::Log;

use Data::Dumper;
use Date::Calc qw (Week_of_Year Monday_of_Week Today Delta_Days Today_and_Now Mktime);
use File::Spec;

sub schedule
{
  my $p = shift;
  my $bin = 'File::Spec'->rel2abs ($0);
  my $cmd = "echo \"$bin\" | at -t $p->[0]";
  &Meteo::Log::log ($cmd);
  exec ($cmd);
}

my $planning = &Meteo::Planning::planning (&Today ());

my @now = &Today_and_Now ();
my $tnow = &Mktime (@now);

my $n = scalar (@$planning);

my $dt0 = +1;

for my $i (0 .. $n-1)
  {
    my $p = $planning->[$i];
    my $dt1 = $tnow - &Mktime (&parseYYYYMMDDhhmm ($p->[0]), 0);

    if (abs ($dt1) < 60)
      {
        &Meteo::Pointeuse::pointage ();
        &Meteo::Report::report (sprintf ('%4.4d%2.2d%2.2d.%2.2d:%2.2d:%2.2d', @now));
        &Meteo::Log::log ('POINTAGE');
        &schedule ($planning->[$i+1]) if ($i < $n-1);
      }
    elsif ($dt1 * $dt0 < 0)
      {
        &schedule ($p);
      }

    $dt0 = $dt1;
  }

