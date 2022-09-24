package Meteo::Credentials;

use strict;

sub getARRAYRef
{
  my $f = '.credentials.pl';
  die unless (-f $f);
  my $c = do ("./$f");
  $@ && die ($@);
  return $c;
}

sub getJSON
{
  my $c = &getARRAYRef ();
  my %c = @$c;
  return sprintf ('{"username":"%s","password":"%s"}', $c->{username}, $c->{password});
}

1;
