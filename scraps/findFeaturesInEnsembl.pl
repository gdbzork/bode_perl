#!/usr/bin/perl

use strict;
use Bio::EnsEMBL::Registry;
use Data::Dumper;

use ensembl;

my $registry = 'Bio::EnsEMBL::Registry';
$Data::Dumper::Maxdepth = 2;
$registry->load_registry_from_db(
    -host => 'localhost',
    -user => 'root'
);

#my $genome = {'hsa' => 'Human',
#              'mmu' => 'Mouse',
#              'cfa' => 'Dog',
#              'mml' => 'macaca mulatta',
#              'rno' => 'rattus norvegicus',
#              'mdo' => 'monodelphis domestica',
#              'gga' => 'gallus gallus',
#              'xtr' => 'xenopus tropicalis'};

my $skip = {'Pseudo' => 1,
            'Undet' => 1};
my $skip_analysis = {'TSS' => 1,
                     'cpg_island' => 1,
                     'exon' => 1};
my $toplevel = "toplevel";

my $species = $ARGV[0];
my $common = $ensembl::genome->{$species};
if ($species eq "mml") {
  $toplevel = "chromosome";
}

my $slice_adaptor = $registry->get_adaptor($common,'Core','Slice');
my $feature_adaptor = $registry->get_adaptor($common,'Core','simple_feature');

my $chromosomes = $slice_adaptor->fetch_all($toplevel);
my %labelset = ();
my $count = 0;
foreach my $chrom (@$chromosomes) {
  my $chrname = $chrom->seq_region_name;
  my $features = $chrom->get_all_SimpleFeatures;
  my $prefix;
  if ($chrom->coord_system->name eq "chromosome") {
    $prefix = "chr";
  } else {
    $prefix = "";
  }
  foreach my $feature (@$features) {
    my $label = $feature->display_label;
    my $analysis = $feature->analysis->gff_feature;
    if (!(exists $skip->{$label}
          || exists $skip_analysis->{$analysis}
          || $label eq "" || substr($label,0,4) eq "oe =")) {
      print $prefix,$chrname," ",$feature->start," ",$feature->end," ",
            $label," ",$feature->score," ",
            $feature->strand == 1 ? "+" : "-","\n";
      $labelset{$label} = 1;
#      print STDERR keys %labelset;
#      print Dumper($feature);
      $count++;
    } else {
#      if (substr($label,0,4) eq "rank") {
#        print STDERR Dumper($feature);
#        $count++;
#      }
#      if ($count > 20) {
#        exit;
#      }
    }
  }
}

my @ls = keys %labelset;
@ls = sort @ls;
print STDERR "labels found: ",join(" ",@ls);
print STDERR "\n";

exit;
