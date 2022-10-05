package Meteo::Log;

use strict;
use FileHandle;
use Date::Calc qw (Today_and_Now);

my $HOME = (getpwuid ($>))[7];

sub log
{
  my @now = &Today_and_Now ();
  my $now = sprintf ('%4.4d%2.2d%2.2d.%2.2d:%2.2d:%2.2d', @now);
  'FileHandle'->new (">>$HOME/.pointeuse/log.txt")->print ("$now @_\n");
}

1;
