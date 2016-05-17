package Synteny::SyntenySyn;

use strict; use warnings;
use Log::Log4perl qw(get_logger);

@Synteny::SyntenySyn::ISA = qw(Synteny::Synteny);

sub init {
  my $self = shift;
  $self->{synteny_adaptor} = $self->{registry}->get_adaptor("Multi",
                                                            "compara",
                                                            "SyntenyRegion");
  $self->{fragment_adaptor} = $self->{registry}->get_adaptor("Multi",
                                                             "compara",
                                                             "DnaFrag");
}

sub getRegions {
  my $self = shift;
  my ($genome,$chrom,$left,$right) = @_;
  if (!defined($self->{mlss})) {
    get_logger()->warn("Cannot look up regions for '$genome': '$chrom'; mlss is null");
    return;
  }
  my $chrom_frag = $self->{fragment_adaptor}->fetch_by_GenomeDB_and_name($genome,$chrom);
  my $syntenies = $self->{synteny_adaptor}->fetch_all_by_MethodLinkSpeciesSet_DnaFrag($self->{'mlss'},$chrom_frag);
  my $blockset = [];
  foreach my $synt (@$syntenies) {
    my $frags = $synt->get_all_DnaFragRegions();
    my $block = {};
    foreach my $frag (@$frags) {
      my $taxid = $frag->genome_db->taxon_id;
      $block->{$taxid} = AlignedBlock->fromSyn($taxid,
                                               $frag->slice->seq_region_name,
                                               $frag->dnafrag_start,
                                               $frag->dnafrag_end,
                                               $frag->dnafrag_strand);
    }
    push @$blockset, $block;
  }
  return $blockset;
}

sub countRegions {
  my $self = shift;
  my ($genome,$chrom,$left,$right) = @_;
  my $chrom_frag = $self->{fragment_adaptor}->fetch_by_GenomeDB_and_name($genome,$chrom);
  my $syntenies = $self->{synteny_adaptor}->fetch_all_by_MethodLinkSpeciesSet_DnaFrag($self->{'mlss'},$chrom_frag);
  return scalar @$syntenies;
}

1
