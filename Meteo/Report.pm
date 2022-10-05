package Meteo::Report;

use strict;
use Meteo::Log;

my $HOME = (getpwuid ($>))[7];

sub report
{
  my $mess = shift;
  my $report = "$HOME/.pointeuse/report.pl";
  if (-f $report)
    {
      $report = do ("$report");
      if (my $c = $@)
        {
          die $c;
        }
      $report->($mess);
    }
  &Meteo::Log::log ($mess);
}

1;
