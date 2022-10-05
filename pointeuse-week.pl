#!/home/marguina/install/perl-5.36.0/bin/perl -w

use strict;
use FindBin qw ($Bin);
use lib $Bin;

use Meteo::Planning;
use Meteo::Pointeuse;
use Meteo::Pegase;
use Meteo::Report;

use Data::Dumper;
use Date::Calc qw (Week_of_Year Monday_of_Week Today Delta_Days Today_and_Now Mktime);
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

print &Dumper ($p);

splice (@$p, 0, 4) for (1 .. $Dd);
splice (@$p, 0, 2) if ($when eq 'PM');

print &Dumper ($p);

if ($work)
  {
    my @now = &Today_and_Now ();
    my $tnow = &Mktime (@now);
    my $tdat = &Mktime (&parseYYYYMMDDhhmm ($date), 0);
    my $dt = $tnow - $tdat;
    # Allow for up to 10 minutes delay
    if (abs ($dt) < 600)
       {
         &Meteo::Pointeuse::pointage ();
         &Report::report (sprintf ('%4.4d%2.2d%2.2d.%2.2d:%2.2d:%2.2d', @now));
       }
    else
       {
         &Meteo::Log::log ("@ARGV");
       }

  }

shift (@$p) unless ($init);

exit (0) unless (@$p);

my @at = ('at', -t => $p->[0][0], $bin, @{$p->[0]});

my $cmd = "echo \"$bin @{$p->[0]}\" | at -t $p->[0][0]";

system ($cmd);


