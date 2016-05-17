#!/usr/bin/perl

use strict;
use Bio::EnsEMBL::Registry;
use Data::Dumper;

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_registry_from_db(
    -host => 'localhost',
    -user => 'root'
);

sub max {
  my ($left,$right) = @_;
  return $left > $right ? $left : $right;
}
sub min {
  my ($left,$right) = @_;
  return $left < $right ? $left : $right;
}

my $slice_adaptor = $registry->get_adaptor( 'Human', 'Core', 'Slice' );

my $count;
$count = 0;
while (<>) {
  my (@fields,$name,$chrom,$start,$end,$tmp,$slice,$readlen,$is_repeat,$line);
  $count++;
  if ($count % 1000 == 0) {
    print STDERR $count,"\r";
  }
  $line = $_;
  @fields = split;
  $name = $fields[3];
  $chrom = substr($fields[0],3);
  $start = $fields[1];
  $end = $fields[2];
  if ($start > $end) {
    $tmp = $start;
    $start = $end;
    $end = $tmp;
  }
  $readlen = $end - $start + 1;
  if ($chrom eq "M") {
    next;
  }
  $slice = $slice_adaptor->fetch_by_region( 'chromosome', $chrom, $start, $end);
  if ($slice == undef) {
    print STDERR "ERROR: no slice: ",$name," ",$chrom," ",$start," ",$end,"\n";
    next;
  } else {
    my ($rep);
    my $reps = $slice->get_all_RepeatFeatures();
#    print STDERR "Read: ",$name," (",$start,"-",$end,")\n";
    $is_repeat = 0;
    my $maxoverlap = 0.0;
    foreach $rep (@$reps) {
      $rep = $rep->transform('chromosome');
      my $overlap = (min($rep->end,$end) - max($rep->start,$start) + 1.0)
                    / ($end-$start+1.0);
      if ($overlap > 0.5) {
#      if ($rep->start < 1 and $rep->end >= $readlen) {
        print STDERR "  ",$rep->start," - ",$rep->end," : ",$rep->repeat_consensus->repeat_type," -- ",$rep->repeat_consensus->repeat_class,"\n";
        $is_repeat = 1;
      }
    }
    if (!$is_repeat) {
      print $line;
    }
  }
}
