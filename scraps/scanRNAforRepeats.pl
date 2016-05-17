#!/usr/bin/perl

use strict;
use Bio::EnsEMBL::Registry;
use Data::Dumper;

use util;
use ensembl;

$Data::Dumper::Maxdepth = 3;
my $registry = ensembl::setup('localhost','root');

my $species = $ARGV[0];
my $rnaFN = $ARGV[1];
my $toplevel = ensembl::toplevel($species);
my $common = $ensembl::genome->{$species};

my $slice_adaptor = $registry->get_adaptor($common,'Core','Slice');

my @badstuff = (43130677, 62105343, 71994543, 126337158, 79800558, 62181181,
                71658430, 64545679, 27628189, 92571907, 37771460, 21947890,
                81856559, 12608967, 103349707, 66566551, 20192777, 62821956,
                78623979, 47624344, 41119186, 48593011, 25227677, 35906878,
                31952990, 46044741, 54585614, 153984998, 147760758, 55778991,
                165516160, 120238349, 27820346, 96305441, 132667355, 93447323,
                117841670, 119809939, 144108871, 123879660, 110261132, 29744000,
                16624068, 115771538, 97200379, 65055087, 146077926, 76560861,
                52328010, 4112713, 34325911, 35413391, 95920294, 55296598,
                22809536, 133141682, 140802605, 144199525, 73113535, 20045080);

open RNA,$rnaFN;
my $header = <RNA>;
print $header;
my $count = 0;
my %classes = ();
while (<RNA>) {
  my @flds = split;
  my $line = $_;
  my $chrom = $flds[0];
  if ($chrom eq "Chrom") { 
    print STDERR "skipping $line";
    next;
  }
  if (substr($chrom,0,3) eq "chr") {
    $chrom = substr($flds[0],3);
  }
  if ($chrom eq "M") {
    $chrom = "MT";
  }
  my $start = $flds[2];
  my $end = $flds[3];
  my $aa = $flds[4];
  my $codon = util::revcomp($flds[5]);
  my $tag = "tRNA-$aa";
  if ($start > $end) {
    my $tmp = $start;
    $start = $end;
    $end = $tmp;
  }
  
  my $slice = $slice_adaptor->fetch_by_region($toplevel,$chrom,$start,$end);
  if (!defined($slice)) {
    print STDERR "WARNING: no slice for $toplevel $chrom:$start-$end\n";
    next;
  }
  my $repeats = $slice->get_all_RepeatFeatures();
  my $repcount = 0;
  foreach my $repeat (@$repeats) {
    my $repcon = $repeat->repeat_consensus;
    my $repclass = $repcon->repeat_class;
#    print STDERR Dumper($repeat);
    if (substr($repcon->name,0,8) eq $tag) {
      next;
    } else {
      if (!exists($classes{$repclass})) {
        $classes{$repclass} = 0;
      }
      $classes{$repclass} += 1;
#      if ($repclass =~ /scRNA/) {
#        print sprintf("type='%s' class='%s' name='%s' (%s %s:%d..%d)\n",
#                      $repcon->repeat_type,
#                      $repcon->repeat_class,
#                      $repcon->name,
#                      $tag,$chrom,$start,$end);
#        print $slice->seq,"\n";
#        $repcount++;
#      }
      my $sine = $repclass =~ /SINE|trf|dust|scRNA/;
      if ($sine) {
#        if ($start == 133141682) {
#          print $repclass," bork\n";
#        }
        my @stuff = grep {$_ == $start} @badstuff;
        if (scalar @stuff > 0) {
          print $start, " ", $repclass," bork\n";
        }
        $repcount++;
      }
    }
  }
  if ($repcount == 0) {
    print $line;
  }
  $count++;
  if ($count % 500 == 0) {
    print STDERR "$count\r";
  }
}

my @k = keys(%classes);
sort @k;
foreach my $key (@k) {
  print STDERR $key," ",$classes{$key},"\n";
}

exit;
