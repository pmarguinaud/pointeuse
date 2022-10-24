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
use Date::Calc qw (Today Today_and_Now Mktime Add_Delta_Days);
use File::Spec;

sub bt
{ 
  print @_; 

  print "\n";
  for (my $i = 0; ; $i++)
    {   
      last unless (my @call = caller ($i));
      print " $i ", $call[1], ':', $call[2], "\n";
    }   
  die "\n";
}

local $SIG{__WARN__} = \&bt;
local $SIG{__DIE__} = \&bt;


sub schedule
{
  my $p = shift;
  my $bin = 'File::Spec'->rel2abs ($0);
  my $cmd = "echo \"$bin\" | at -M -t $p->[0]";
# my $cmd = "echo \"$bin\" | at -t $p->[0]";
  &Meteo::Log::log ($cmd);
  exec ($cmd);
}


my @today = &Today ();

for my $j (0 .. 1)
  {
    my @day = &Add_Delta_Days (@today, $j * 7);
    my $planning = &Meteo::Planning::planning (@day);

    @{$planning} = grep { $_->[2] } @{$planning};

    my @now = &Today_and_Now ();
    my $tnow = &Mktime (@now);
    
    my $n = scalar (@$planning);
    
    my $dt0 = +1;
    
    for my $i (0 .. $n-1)
      {
        my $p = $planning->[$i];
    
        my @t1 = &parseYYYYMMDDhhmmss ($p->[0]);
        my $dt1 = $tnow - &Mktime (@t1);
    
        if (abs ($dt1) < 60)
          {
            sleep ($t1[-1]);
            &Meteo::Pointeuse::pointage ();
            &Meteo::Report::report (sprintf ('%4.4d%2.2d%2.2d.%2.2d%2.2d.%2.2d', &Today_and_Now ()));
            &Meteo::Log::log ('POINTAGE');
            &schedule ($planning->[$i+1]) if ($i < $n-1);
          }
        elsif ($dt1 * $dt0 < 0)
          {
            &schedule ($p);
          }
    
        $dt0 = $dt1;
      }
  }



