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

$Data::Dumper::Maxdepth = 2;
my $WINDOW = 1000;
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

my ($count,$skipped);
$count = 0;
$skipped = 0;
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
      foreach my $gene (@$genes) {
        my $hit_tss = 0;
        next unless $gene->is_known();
        $gene = $gene->transform('chromosome');
        my $transcripts = $gene->get_all_Transcripts();
        foreach my $transcript (@$transcripts) {
          $transcript = $transcript->transform('chromosome');
          my $tss;
          if ($transcript->strand > 0) {
            $tss = $transcript->start;
          } else {
            $tss = $transcript->end;
          }
#          print sprintf("trans %s start=%d end=%d strand=%d tss=%d  peakstart=%d peakend=%d\n",$transcript->stable_id,$transcript->start,$transcript->end,$transcript->strand,$tss,$start,$end);
          if ($tss >= $start && $tss <= $end) {
            $hit_tss++;
          }
        }
        if ($hit_tss > 0) {
#          print sprintf("%s:%d-%d: ",$chrom,$start,$end);
#          print sprintf(" status=%s id=%s '%s'\n",$gene->status,$gene->stable_id,$gene->description);
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
  my $p = $psrt[0];
  print sprintf("chr%s\t%d\t%d\t%s\t%d\t%d\t%d\t%s\t%s\t'%s'\n",$gene->seq_region_name,
                 $gene->start,$gene->end,$gene->strand,
                 $p->{start},$p->{end},$p->{tags},$p->{height},
                 $gene->stable_id,$gene->description);
#  foreach my $p (@psrt) {
#    print sprintf("\tchr%s\t%d\t%d\t%d\t%d\n",$p->{chrom},$p->{start},$p->{end},$p->{tags},$p->{height});
#  }
}
print STDERR "genes: $genecount  nogenes: $no_genes  skipped: $skipped\n";
print STDERR "distinct genes: ",scalar keys(%$geneset),"\n";
