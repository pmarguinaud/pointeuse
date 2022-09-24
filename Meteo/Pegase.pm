package Meteo::Pegase;

use strict;
use WWW::Mechanize;
use HTTP::Request::Common;
use JSON;
use Data::Dumper;
use File::Path;
use File::Basename;
use FileHandle;
use Date::Calc qw (Week_of_Year Today Monday_of_Week Add_Delta_Days Delta_Days Day_of_Week);
use Meteo::Credentials;

use constant
{
  AM => 0b10,
  PM => 0b01,
};

sub parseYYYYMMDD
{
  my $YYYYMMDD = shift;
  die unless (my @date = ($YYYYMMDD =~ m/^(\d\d\d\d)(\d\d)(\d\d)$/o));
 
  for (@date)
    {
      s/^0*//o;
    } 

  die if (grep { length ($_) == 0 } @date);

  return @date;
}

sub getPegaseWeek
{
  my ($year, $month, $day) = scalar (@_) ? @_ : &Today ();
  
  (my $week, $year) = &Week_of_Year ($year, $month, $day);

  my $W;

  my $cached = "./.pegase/$week-$year.pl";

  if (-f $cached)
    {
      $W = do ($cached);
      return $W;
    }
  
  my @monday0 = &Monday_of_Week ($week, $year);
  my @monday1 = &Add_Delta_Days (@monday0, +7);
  
  my $ua = 'WWW::Mechanize'->new ();
  $ua->agent_alias ('Linux Mozilla');
  
  my ($rq, $rp);
  
  my $cred = &Meteo::Credentials::getARRAYRef ();

  $rq = POST 'http://pegaseweb.meteo.fr/api-token-auth/', [@$cred];
  
  $rp = $ua->request ($rq);
  
  die unless ($rp->is_success ());
  
  die unless (my $x = &decode_json ($rp->content));
  
  $rq = POST 'http://pegaseweb.meteo.fr/api/', 
        Authorization => "JWT $x->{token}",
        Content => [action => 'semaineA', 
                    dateDebSel => sprintf ('%4.4d%2.2d%2.2d', @monday0), 
                    dateFinSel => sprintf ('%4.4d%2.2d%2.2d', @monday1)];
  
  $rp = $ua->request ($rq);
  
  die unless ($W = &decode_json ($rp->content));

  &mkpath (&dirname ($cached));
  'FileHandle'->new (">$cached")->print (&Dumper ($W));

  return $W;
}

sub getCurrentWeek
{
  my @date = scalar (@_) ? @_ : &Today ();

  
  my ($week, $year) = &Week_of_Year (@date);
  
  my @monday = &Monday_of_Week ($week, $year);

  my $W = &getPegaseWeek (@date);

  my @d = ((0b11) x 5, (0b00) x 2);

  for my $f (@{ $W->{ferie} })
    {
      my $d = $f->{n_jour};
      $d[$d] = 0b00;
    }

  for my $a (@{ $W->{absences} })
    {
      my @date = &parseYYYYMMDD ($a->{dateDeb});
      my $Dd = &Delta_Days (@monday, @date);
      next if ($Dd >= scalar (@d));
      if ($a->{matin})
        {
          $d[$Dd] = $d[$Dd] & AM;
        }
      else
        {
          $d[$Dd] = $d[$Dd] & PM;
        }
    }

  return \@d;
}

sub workTodayAM
{
  my @date = scalar (@_) ? @_ : &Today ();
  my $w = &getCurrentWeek (@date);
  my $dow = &Day_of_Week (@date)-1;
  return ($w->[$dow] & AM) && 1;
}

sub workTodayPM
{
  my @date = scalar (@_) ? @_ : &Today ();
  my $w = &getCurrentWeek (@date);
  my $dow = &Day_of_Week (@date)-1;
  return ($w->[$dow] & PM) && 1;
}




1;

