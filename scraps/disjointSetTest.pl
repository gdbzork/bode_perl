#!/usr/bin/perl

use strict; use warnings;
use Struct::DisjointSet;

my $nodes = ['alpha','bravo','charlie','delta','echo','foxtrot','golf'];
my $pairs = [ ['alpha','bravo'],
              ['charlie','bravo'],
              ['delta','echo'],
              ['echo','alpha'],
              ['golf','foxtrot'] ];
my $same = [ ['golf','foxtrot'],
             ['foxtrot','golf'],
             ['alpha','echo'],
             ['alpha','delta'],
             ['alpha','charlie'],
             ['delta','charlie'],
             ['charlie','delta'] ];
my $diff = [ ['alpha','foxtrot'],
             ['alpha','golf'],
             ['bravo','foxtrot'],
             ['bravo','golf'],
             ['foxtrot','bravo'],
             ['golf','bravo'] ];


my $djs = Struct::DisjointSet->new();
foreach my $n (@$nodes) {
  $djs->makeSet($n);
}

foreach my $p (@$pairs) {
  my $a = $p->[0];
  my $b = $p->[1];
  $djs->union($djs->getNode($a),$djs->getNode($b));
}

my $passed = 0;
my $failed = 0;

foreach my $p (@$same) {
  my $a = $djs->getNode($p->[0]);
  my $b = $djs->getNode($p->[1]);
  my $pa = $djs->findSet($a);
  my $pb = $djs->findSet($b);
  if ($pa == $pb) {
    $passed++;
  } else {
    $failed++;
    print "FAIL: parent mismatch: ",$p->[0],",",$p->[1],": ",$pa->id()," != ",$pb->id(),"\n";
  }
}

foreach my $p (@$diff) {
  my $a = $djs->getNode($p->[0]);
  my $b = $djs->getNode($p->[1]);
  my $pa = $djs->findSet($a);
  my $pb = $djs->findSet($b);
  if ($pa != $pb) {
    $passed++;
  } else {
    $failed++;
    print "FAIL: parent match: ",$p->[0],",",$p->[1],": ",$pa->id()," == ",$pb->id(),"\n";
  }
}

print "passed=",$passed,"  failed=",$failed,"\n";

