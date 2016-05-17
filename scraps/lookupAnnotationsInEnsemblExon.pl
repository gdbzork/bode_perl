#!/usr/bin/perl

use strict;
use Bio::EnsEMBL::Registry;
use Data::Dumper;

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_registry_from_db(
    -host => 'morangie',
    -user => 'ensembl',
    -pass => 'ensembl'
);

my $genome = {'hsa' => 'Human',
              'mmu' => 'Mouse',
              'cfa' => 'Dog',
              'mml' => 'macaca mulatta',
              'rno' => 'rattus norvegicus',
              'cja' => 'callithrix jacchus',
              'mdo' => 'monodelphis domestica',
              'gga' => 'gallus gallus',
              'xtr' => 'xenopus tropicalis'};

#my $species = substr($ARGV[0],0,3);
my $species = $ARGV[0];
my $common = $genome->{$species};

my $slice_adaptor = $registry->get_adaptor( $common, 'Core', 'Slice' );

my (@fields,$slice,$trlink,$gene,@choices,@repchoices,$reps);
my ($name,$chrom,$start,$end,$types,$tmp);
my $hkey;
my (@gnames,$namestr);

my %cache = ();
my %namecache = ();

my $count;
$count = 0;
open FD, $ARGV[1];
while (<FD>) {
  $count++;
  if ($count % 1000 == 0) {
    print STDERR $count,"\r";
  }
  @fields = split;
#  $chrom = substr($fields[0],3);
  $chrom = substr($fields[5],3);
  $start = $fields[6];
  $end = $fields[7];
  my $number = $fields[9];
  if ($number == 1) {
    next;
  }
  if ($start > $end) {
    $tmp = $start;
    $start = $end;
    $end = $tmp;
  }
  $hkey = $chrom."_".$start;
  if (exists $cache{$hkey}) {
    $types = $cache{$hkey};
    $namestr = $namecache{$hkey};
  } else {
    if ($chrom eq "M") {
      next;
    }
    $slice = $slice_adaptor->fetch_by_region('chromosome', $chrom, $start, $end);
    if ($slice == undef) {
      print STDERR "ERROR: no slice: ",$name," ",$chrom," ",$start," ",$end,"\n";
      next;
    } else {
      my $reps = $slice->get_all_RepeatFeatures();

#      my $rpp;
#      foreach $rpp (@$reps) {
#        print STDERR Dumper($rpp);
#      }

      @choices = ();
#      push @choices, map $_->repeat_consensus->repeat_type, @$reps;
      push @choices, map(($_->repeat_consensus->repeat_type == 'RNA repeats'
                          ? $_->repeat_consensus->repeat_class
                          : $_->repeat_consensus->repeat_type), @$reps);
#      push @choices, map $_->repeat_consensus->repeat_type . " --- " . $_->repeat_consensus->repeat_class, @$reps;
      map s/,/_/g, @choices;
      map s/\t/\ /g, @choices;
      if (scalar @choices == 0) {
        $types = "nomatch";
      } else {
        $types = join ",",@choices;
      }
      $cache{$hkey} = $types;
      @gnames = map $_->description, @$trlink;
      push @gnames, map $_->repeat_consensus->name, @$reps;
#      push @gnames, map(($_->repeat_consensus->repeat_class == 'tRNA'
#                         ? $_->repeat_consensus->name
#                         : $_->repeat_consensus->repeat_class), @$reps);
#      push @gnames, map $_->repeat_consensus->repeat_class . " --- " . $_->repeat_consensus->name, @$reps;

      map s/,/_/g, @gnames;
      map s/\t/\ /g, @gnames;
      if (scalar @gnames == 0) {
        $namestr = "nomatch";
      } else {
        $namestr = join ",",@gnames;
      }
      $namecache{$hkey} = $namestr;

#      my $reps = $slice->get_all_RepeatFeatures();
#      my $rep;
#      foreach $rep (@$reps) {
#        print STDERR $rep->repeat_consensus->repeat_type," -- ",$rep->repeat_consensus->repeat_class,"\n";
#      }
  
    }
  }
  print $fields[1],"\t",$start,"\t",$end,"\t",$types,"\t",$namestr,"\n";
}

#print Dumper($trlink);
