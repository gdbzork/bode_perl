#!/usr/bin/perl

use strict;
use Bio::EnsEMBL::Registry;
use Data::Dumper;

my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_registry_from_db(
    -host => 'ensembldb.ensembl.org',
    -user => 'anonymous'
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

my $species = $ARGV[0];
my $common = $genome->{$species};
$Data::Dumper::Maxdepth = 2;

my $slice_adaptor = $registry->get_adaptor( $common, 'Core', 'Slice' );
my $gene_adaptor = $registry->get_adaptor( $common, 'Core', 'Gene' );

my (@fields,$slice,$trlink,$gene,@choices,@repchoices,$reps);
my ($name,$chrom,$start,$end,$types,$tmp);
my $hkey;
my (@gnames,$namestr);

my %cache = ();
my %namecache = ();

my $count;
$count = 0;
my $genic;
my ($sense,$antisense,$exonic);
$genic = 0;
$sense = 0;
$antisense = 0;
$exonic = 0;
open FD, $ARGV[1];
while (<FD>) {
  $count++;
  if ($count % 1000 == 0) {
    print STDERR $count,"\r";
  }
  if (substr($_,0,1) eq "#") {
    next;
  }
  @fields = split;
  $chrom = $fields[0];
  $start = $fields[3];
  $end = $fields[4];
  my $strand = $fields[6];
  $slice = $slice_adaptor->fetch_by_region('toplevel', $chrom, $start, $end);
  if ($slice == undef) {
    print STDERR "ERROR: no slice: ",$name," ",$chrom," ",$start," ",$end,"\n";
    next;
  } else {
    my $genes = $slice->get_all_Genes();
    if (scalar @$genes > 0) {
      my $local_genic = 0;
      my $local_exonic = 0;
      foreach my $gene (@$genes) {
        my $gname = $gene->description();
        if (substr($gname,0,7) eq "mmu-mir") {
          next;
        }
        $local_genic++;
        print sprintf("%s\t%d\t%d\t%s\t%d\t%d\t%s\t%s\t%s\n",$chrom,$start,$end,$strand,$gene->start(),$gene->end(),$gene->strand(),$gene->stable_id(),$gene->description);
        my $exons = $gene->get_all_Exons();
        if (scalar @$exons > 0) {
          foreach my $exon (@$exons) {
            if ($exon->start < 1 && $exon->end > 60) {
              $local_exonic++;
#              print sprintf("%s\t%d\t%d\t%s\n",$chrom,$start,$end,$strand);
              print sprintf("\t\t\t\t%d\t%d\t%s\t%s\t%s\n",$exon->start(),$exon->end(),$exon->strand(),"","exon");
            }
          }
        }
      }
      if ($local_exonic > 0) {
        $exonic++;
      }
      if ($local_genic > 0) {
        $genic++;
        my $gstrand = $genes->[0]->strand();
        if ($gstrand == 1) {
          $gstrand = "+";
        } else {
          $gstrand = "-";
        }
        if ($gstrand eq $strand) {
          $sense++;
        } else {
          $antisense++;
        }
      }
    }
  }
}

print "genic=$genic sense=$sense antisense=$antisense exonic=$exonic\n";
