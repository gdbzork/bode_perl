#!/usr/bin/perl

use strict;
use Bio::EnsEMBL::Registry;
use Data::Dumper;

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_registry_from_db(
    -host => 'localhost',
    -user => 'root'
);

$Data::Dumper::Maxdepth = 2;
my $WINDOW = 10000;
my $genome = {'hsa' => 'Human',
              'mmu' => 'Mouse',
              'cfa' => 'Dog',
              'mml' => 'macaca mulatta',
              'rno' => 'rattus norvegicus',
              'cja' => 'callithrix jacchus',
              'mdo' => 'monodelphis domestica',
              'gga' => 'gallus gallus',
              'xtr' => 'xenopus tropicalis'};

my $bestpeaks = {};
###############################################################################

sub bestPeak {
  my ($peaks) = @_;
  my $tagmax = 0;
  my $best;
  foreach my $peak (@$peaks) {
    my $ptags = $peak->{tags};
    if ($ptags > $tagmax) {
      $best = $peak;
      $tagmax = $ptags;
    }
  }
  return $best;
}

sub sortP {
  return $b->{tags} <=> $a->{tags};
}

sub sortPeaks {
  return $bestpeaks->{$b}->{tags} <=> $bestpeaks->{$a}->{tags};
}
###############################################################################

my $species = $ARGV[0];
my $common = $genome->{$species};

my $slice_adaptor = $registry->get_adaptor( $common, 'Core', 'Slice' );
my $gene_adaptor = $registry->get_adaptor( $common, 'Core', 'Gene' );

my ($count,$skipped,$no_genes,$genecount);
$count = 0;
$skipped = 0;
$no_genes = 0;
$genecount = 0;
my $geneset = {};
my $peakset = {};
open FD, $ARGV[1];
while (<FD>) {
  if (substr($_,0,3) ne "chr") {
    $skipped++;
    next;
  }
  $count++;
  if ($count % 1000 == 0) {
    print STDERR $count,"\r";
  }
  my @fields = split;
  my $chrom = substr($fields[0],3);
  if ($chrom eq "M") {
    next;
  }
  my $start = $fields[1];
  my $end = $fields[2];
  if ($start > $end) {
    my $tmp = $start;
    $start = $end;
    $end = $tmp;
  }
  my $slice = $slice_adaptor->fetch_by_region('toplevel', $chrom, $start-$WINDOW, $end+$WINDOW);
  if ($slice == undef) {
    print STDERR "ERROR: no slice: $chrom:$start-$end\n";
    next;
  } else {
    my $genes = $slice->get_all_Genes();
    if (scalar @$genes > 0) {
#      if (scalar @$genes > 1) {
#        print STDERR sprintf("multiple genes: %s:%d-%d -- %d\n",$chrom,$start,$end,scalar @$genes);
#      }
      foreach my $gene (@$genes) {
        my $hit_tss = 0;
        next unless $gene->is_known();
        $gene = $gene->transform('chromosome');
        my $stab = $gene->stable_id;
        if (!exists $geneset->{$stab}) {
          $geneset->{$stab} = $gene;
          $peakset->{$stab} = [];
        }
        my $phash = {chrom=>$chrom,start=>$start,end=>$end,tags=>$fields[5],height=>$fields[7]};
        push @{$peakset->{$stab}},$phash;
        $geneset->{$gene->stable_id} = $gene;
      }
    }
  }
}

my @glist = keys(%$geneset);
foreach my $x (@glist) {
  $bestpeaks->{$x} = &bestPeak($peakset->{$x});
}
my @gsort = sort sortPeaks @glist;
print "Chrom\tGeneStart\tGeneEnd\tGeneStrand\tPeakStart\tPeakEnd\tTagCount\tFoldChange\tEnsemblId\tDescription\n";
foreach my $g (@gsort) {
  my $gene = $geneset->{$g};
  my $peaks = $peakset->{$g};
  my @psrt = sort sortP @$peaks;
  my $p = shift @psrt;
  print sprintf("chr%s\t%d\t%d\t%s\t%d\t%d\t%d\t%s\t%s\t'%s'\n",$gene->seq_region_name,
                 $gene->start,$gene->end,$gene->strand,
                 $p->{start},$p->{end},$p->{tags},$p->{height},
                 $gene->stable_id,$gene->description);
#  foreach my $pg (@psrt) {
#    print sprintf("\t\t\t\t%d\t%d\t%d\t%s\n",$pg->{start},$pg->{end},$pg->{tags},$pg->{height});
#  }
}
print STDERR "genes: $genecount  nogenes: $no_genes  skipped: $skipped\n";
print STDERR "distinct genes: ",scalar keys(%$geneset),"\n";
