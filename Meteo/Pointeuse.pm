package Meteo::Pointeuse;

use strict;
use WWW::Mechanize;
use HTTP::Request::Common;
use JSON;
use Data::Dumper;
use Meteo::Credentials;


sub pointage
{

  my $ua = 'WWW::Mechanize'->new ();
  $ua->agent_alias ('Linux Mozilla');
  
  my ($rq, $rp);
  
  my $cred = &Meteo::Credentials::getJSON ();

  $rq = POST 'http://pointeuse.meteo.fr/api/auth/token/',
        Content_Type => 'application/json;charset=utf-8',
        Content      => $cred;
  
  
  $rp = $ua->request ($rq);
  
  die unless ($rp->is_success ());
  
  die unless (my $x = &decode_json ($rp->content));
  
  my ($token, $id) = ($x->{token}, $x->{infos}{id});
  
  $rq = GET "http://pointeuse.meteo.fr/api/user/isadminf/$id/",
        Accept => 'application/json, text/plain, */*',
        Accept_Language => 'fr,fr-FR;q=0.8,en-US;q=0.5,en;q=0.3',
        Accept_Encoding => 'gzip, deflate',
        Referer => 'http://pointeuse.meteo.fr/app/tally',
        Authorization => "JWT $token";
  
  $rp = $ua->request ($rq);
  
  die unless ($rp->is_success ());
  
  $rq = POST 'http://pointeuse.meteo.fr/api/tally/',
        Accept => 'application/json, text/plain, */*',
        Accept_Language => 'fr,fr-FR;q=0.8,en-US;q=0.5,en;q=0.3',
        Accept_Encoding => 'gzip, deflate',
        Referer      => 'http://pointeuse.meteo.fr/api/tally/',
        Content_Type => 'application/json;charset=utf-8',
        Authorization => "JWT $token",
        Origin => 'http://pointeuse.meteo.fr',
        Content      => '{}';
  
  eval 
    {
      $rp = undef;
      $rp = $ua->request ($rq);
    };
  
  if ((my $c = $@) =~ m,^Error POSTing http://pointeuse.meteo.fr/api/tally/,o)
    {
      die "STOP";
    }
  
  die unless ($rp->is_success ());
  
  print $rp->as_string;

}

1;

