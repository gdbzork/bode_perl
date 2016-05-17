#!/usr/bin/perl

use strict;
use Bio::EnsEMBL::Registry;
use Data::Dumper;

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_registry_from_db(
    -host => 'localhost',
    -user => 'root'
);

my $slice_adaptor = $registry->get_adaptor( 'Human', 'Core', 'Slice' );
my $gene_adaptor = $registry->get_adaptor( 'Human', 'Core', 'Gene' );

my (@fields,$slice,$trlink,$gene,@choices,@repchoices,$reps);
my ($name,$chrom,$start,$end,$types,$tmp);
my $hkey;
my (@gnames,$namestr);

my %cache = ();
my %namecache = ();

my $count;
$count = 0;
while (<>) {
  $count++;
  if ($count % 1000 == 0) {
    print STDERR $count,"\r";
  }
  @fields = split;
  $name = $fields[1];
  $chrom = substr($fields[5],3);
  $start = $fields[6];
  $end = $fields[7];
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
    $slice = $slice_adaptor->fetch_by_region( 'chromosome', $chrom, $start, $end);
    if ($slice == undef) {
      print STDERR "ERROR: no slice: ",$name," ",$chrom," ",$start," ",$end,"\n";
      next;
    } else {
      $trlink = $gene_adaptor->fetch_all_by_Slice($slice);
      my $reps = $slice->get_all_RepeatFeatures();

      @choices = map $_->biotype, @$trlink;
      push @choices, map ($_->repeat_consensus->repeat_type == 'RNA'
                          ? $_->repeat_consensus->repeat_class
                          : $_->repeat_consensus->repeat_type), @$reps;
      map s/\s/_/g, @choices;
      if (scalar @choices == 0) {
        $types = "nomatch";
      } else {
        $types = join ",",@choices;
      }
      $cache{$hkey} = $types;
      @gnames = map $_->description, @$trlink;
      push @gnames, map ($_->repeat_consensus->repeat_class == 'tRNA'
                         ? $_->repeat_consensus->name
                         : $_->repeat_consensus->repeat_class), @$reps;
      map s/\s/_/g, @gnames;
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
  print $name,"\t",$fields[5],"\t",$start,"\t",$end,"\t",$types,"\t",$namestr,"\n";
}

#print Dumper($trlink);
