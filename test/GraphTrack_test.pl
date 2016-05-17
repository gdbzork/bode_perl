#!/usr/bin/perl

use strict; use warnings;
use Test::More qw(no_plan);

use Tree::GraphTrack;

my $tree = Tree::GraphTrack::new();
ok($tree->isa("_p_graphTrackP"),"object creation test");
Tree::GraphTrack::addSegment($tree,20,40,10);
my $x = Tree::GraphTrack::search($tree,30);
ok($x->isa("_p_redBlackNodeP"),"object search result");
is(Tree::GraphTrack::getHeight($x),10,"test height");
ok(Tree::GraphTrack::isNull(Tree::GraphTrack::search($tree,99)),"search missing node");
Tree::GraphTrack::addSegment($tree,30,50,20);
$x = Tree::GraphTrack::search($tree,25);
is(Tree::GraphTrack::getHeight($x),10,"test height 1");
$x = Tree::GraphTrack::search($tree,35);
is(Tree::GraphTrack::getHeight($x),30,"test height 2");
$x = Tree::GraphTrack::search($tree,45);
is(Tree::GraphTrack::getHeight($x),20,"test height 3");
Tree::GraphTrack::addSegment($tree,0,18,20);
Tree::GraphTrack::addSegment($tree,10,25,10);
$x = Tree::GraphTrack::search($tree,5);
is(Tree::GraphTrack::getHeight($x),20,"test height 4");
$x = Tree::GraphTrack::search($tree,0);
is(Tree::GraphTrack::getHeight($x),20,"test height 5");
$x = Tree::GraphTrack::search($tree,10);
is(Tree::GraphTrack::getHeight($x),30,"test height 6");
Tree::GraphTrack::addSegment($tree,100,140,90);
$x = Tree::GraphTrack::search($tree,70);
ok(Tree::GraphTrack::isNull($x),"test height 7");
$x = Tree::GraphTrack::search($tree,99);
ok(Tree::GraphTrack::isNull($x),"test height 8");
$x = Tree::GraphTrack::search($tree,100);
is(Tree::GraphTrack::getHeight($x),90,"test height 9");
$x = Tree::GraphTrack::search($tree,139);
is(Tree::GraphTrack::getHeight($x),90,"test height 10");
$x = Tree::GraphTrack::search($tree,140);
ok(Tree::GraphTrack::isNull($x),"test height 11");
Tree::GraphTrack::dumpIntervals($tree);

#my @saved = ();
#for (my $i=0;$i<5000000;$i++) {
#  my $r = int(rand(100000000));
#  if ($r > 0) {
#    Tree::GraphTrack::insert($tree,$r,36,$i);
#  }
#  if ($i % 100000 == 0) {
#    print STDERR sprintf("%9d\r",$i);
#    push @saved, $r+10;
#  }
#}
#
#my $found = 0;
#my $kept = scalar @saved;
#foreach my $k (@saved) {
#  my $x = Tree::GraphTrack::search($tree,$k);
#  if (defined($x) && !Tree::GraphTrack::isNull($x)) {
#    $found++;
#  }
#}
#print "saved $kept, found $found\n";
#
#$found = 0;
#for (my $i=0;$i<$kept;$i++) {
#  my $r = int(rand(10000000));
#  my $x = Tree::GraphTrack::search($tree,$r);
#  if (defined $x && !Tree::GraphTrack::isNull($x)) {
#    $found++;
#  }
#}
#print "generated $kept, found $found\n";
