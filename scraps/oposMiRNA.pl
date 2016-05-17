#!/usr/bin/perl

use strict;
use Data::Dumper;

use Bio::EnsEMBL::Registry;
my $reg = "Bio::EnsEMBL::Registry";
$reg->load_registry_from_db(-host => 'ensembldb.ensembl.org',
                            -user => 'anonymous');

my $opoSlice = $reg->get_adaptor("Monodelphis domestica", "core", "Slice");
my $opoGene = $reg->get_adaptor("Monodelphis domestica", "core", "Gene");

my $mirnaset = $opoGene->fetch_all_by_biotype("mirna");
my $known = 0;
my $unk = 0;
for my $mirna (@$mirnaset) {
  print ">",$mirna->display_id," ",$mirna->description,"\n";
  if (defined $mirna->description && $mirna->description ne "") {
    $known++;
  } else {
    $unk++;
  }
  my $slice = $mirna->feature_Slice;
  print $slice->seq,"\n"
}
print STDERR "$known known, $unk unknown.\n";
