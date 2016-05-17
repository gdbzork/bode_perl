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
  $chrom = substr($fields[0],3);
  $start = $fields[1];
  $end = $fields[2];
  my $strand;
  if (scalar @fields > 6) {
    $strand = $fields[6];
  } else {
    $strand = '+';
  }
  $slice = $slice_adaptor->fetch_by_region('toplevel', $chrom, $start, $end);
  if ($slice == undef) {
    print STDERR "ERROR: no slice: ",$name," ",$chrom," ",$start," ",$end,"\n";
    next;
  } else {
    my $started = 0;
    print sprintf("%s\t%d\t%d\tchr%s:%d-%d",$chrom,$start,$end,$chrom,$start,$end);
    my $genes = $slice->get_all_RepeatFeatures();
    foreach my $rep (@$genes) {
      my $prefix;
      if ($started) {
        $prefix = "\t\t\t";
      } else {
        $prefix = "";
        $started = 1;
      }
      print sprintf("%s\t%s %s %s\n",$prefix,
                    $rep->repeat_consensus->name,
                    $rep->repeat_consensus->repeat_type,
                    $rep->analysis->logic_name);
    }                    

    my $genes = $slice->get_all_Genes();
    foreach my $gene (@$genes) {
      my $prefix;
      if ($started) {
        $prefix = "\t\t\t";
      } else {
        $prefix = "";
        $started = 1;
      }
      my $descr = $gene->description;
      if ($descr == undef or $descr eq "") {
        $descr = $gene->biotype;
      } 
      print sprintf("%s\t%s %s\n",$prefix,$gene->biotype,$gene->description);
    }
  }
}

print "genic=$genic sense=$sense antisense=$antisense exonic=$exonic\n";
