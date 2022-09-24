package Meteo::Planning;

use strict;
use FindBin qw ($Bin);
use lib $Bin;

use Meteo::Pegase;
use Data::Dumper;
use Date::Calc qw (Week_of_Year Monday_of_Week Add_Delta_Days Today);
use base qw (Exporter);
our @EXPORT = qw (planning);

sub randhhmm
{
  my ($h, $v) = @_;
  my $t = $h + $v * (rand () - 0.5);
  my $hh = int ($t);
  my $mm = int (($t - $hh) * 60);
  return sprintf ('%2.2d%2.2d', $hh, $mm);
}

my $v = 0.5;
my @am = ( 8.5, 12.0);
my @pm = (13.0, 17.5);


sub planning
{
  my @date = @_ ? @_ : &Today ();
  
  my $w = &getCurrentWeek (@date);
  
  my ($week, $year) = &Week_of_Year (@date);
  my @monday = &Monday_of_Week ($week, $year);
  my $init = $year * 52 + $week;
  
  srand ($init);
  
  my @YYYYMMDDhhmm;

  for my $i (0 .. 6)
    {
      my @day = &Add_Delta_Days (@monday, $i);
      my $YYYYMMDD = sprintf ("%4.4d%2.2d%2.2d", @day);
      my @amt = ($YYYYMMDD . &randhhmm ($am[0], $v), $YYYYMMDD . &randhhmm ($am[1], $v/2));
      my @pmt = ($YYYYMMDD . &randhhmm ($pm[0], $v/2), $YYYYMMDD . &randhhmm ($pm[1], $v));
      push @YYYYMMDDhhmm, map ({ [$_, 'AM', $w->[$i] & AM] } @amt), map ({ [$_, 'PM', $w->[$i] & PM] } @pmt);
    }

  return \@YYYYMMDDhhmm;
}

1;


