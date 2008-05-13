#!/usr/bin/perl
use YAML; use Data::Dumper; local $/; $_=<>; print "OK\n";  my ($yaml, $arrayref, $string) = Load($_); #print Dumper($yaml);
