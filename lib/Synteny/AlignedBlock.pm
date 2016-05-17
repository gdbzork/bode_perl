package Synteny::AlignedBlock;

use strict; use warnings;
use Log::Log4perl qw(get_logger);
use Ensembl;

sub fromGAB {
  my $class = shift;
  my $gab = shift;

  my $obj = {};
  $obj->{taxid} = $gab->genome_db->taxon_id;
  $obj->{chrom} = $gab->dnafrag->name;
  $obj->{left} = $gab->dnafrag_start - 1;
  $obj->{right} = $gab->dnafrag_end;
  $obj->{strand} = $gab->dnafrag_strand > 0 ? "+" : "-";
  $obj->{sequence} = $gab->aligned_sequence;
  $obj->{cigar} = $gab->cigar_line;
  if ($obj->{left} > $obj->{right}) {
    my $tmp = $obj->{left};
    $obj->{left} = $obj->{right};
    $obj->{right} = $tmp;
  }
  bless $obj, $class;
  return $obj;
}

sub fromSyn {
  my $class = shift;
  my ($tax,$chrom,$left,$right,$strand) = @_;
  my $obj = {};
  $obj->{taxid} = $tax;
  $obj->{chrom} = $chrom;
  $obj->{left} = $left - 1;
  $obj->{right} = $right;
  $obj->{strand} = $strand > 0 ? "+" : "-";
  $obj->{sequence} = "";
  $obj->{cigar} = "";
  if ($obj->{left} > $obj->{right}) {
    my $tmp = $obj->{left};
    $obj->{left} = $obj->{right};
    $obj->{right} = $tmp;
  }
  bless $obj, $class;
  return $obj;
}

sub setOrigCoords {
  my ($self,$start,$end) = @_;
  if ($start > $end) {
    my $tmp = $start;
    $start = $end;
    $end = $tmp;
  }
  $self->{orig_left} = $start;
  $self->{orig_right} = $end;
}

sub taxid {
  my $self = shift;
  return $self->{taxid};
}

sub genome {
  my $self = shift;
  return $Ensembl::taxid2short->{$self->{taxid}};
}

sub genomename {
  my $self = shift;
  return $Ensembl::genome->{$Ensembl::taxid2short->{$self->{taxid}}};
}

sub chrom {
  my $self = shift;
  return $self->{chrom};
}

sub left {
  my $self = shift;
  return $self->{left};
}

sub right {
  my $self = shift;
  return $self->{right};
}

sub orig_left {
  my $self = shift;
  return $self->{orig_left};
}

sub orig_right {
  my $self = shift;
  return $self->{orig_right};
}

sub strand {
  my $self = shift;
  return $self->{strand};
}

sub seq {
  my $self = shift;
  return $self->{sequence};
}

sub cigar {
  my $self = shift;
  return $self->{cigar};
}

sub string {
  my $self = shift;
  return sprintf("%s %s:%d-%d%s",$self->genome,$self->chrom,
                                 $self->left,$self->right,$self->strand);
}

1
