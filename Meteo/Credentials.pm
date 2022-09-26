package Meteo::Credentials;

use strict;

my $HOME = (getpwuid ($>))[7];

sub getARRAYRef
{
  my $f = "$HOME/.pointeuse/credentials.pl";
  die $f unless (-f $f);
  my $c = do ("$f");
  $@ && die ($@);
  return $c;
}

sub getJSON
{
  my $c = &getARRAYRef ();
  my %c = @$c;
  return sprintf ('{"username":"%s","password":"%s"}', $c{username}, $c{password});
}

1;
