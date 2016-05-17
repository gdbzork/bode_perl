package Seq::Bed;

=head1 NAME

Seq::Bed -- stores a Bed file entry

=head1 SYNOPSIS

 $x = $bedobj->string()

=head1 DESCRIPTION

Stores a Bed file entry.  Coordinates are 0-based, half-open.  Most of the
functionality is inherited from C<AlignedSeq>.

=cut

use strict; use warnings;
use Seq::AlignedSeq;

@Seq::Bed::ISA = qw(Seq::AlignedSeq);

=head2 string

  Args: none

  Description: Returns a string representing this Bed file entry, including
               a trailing newline.
  Returntype:  string

=cut 

sub string {
  my $self = shift;
  my $pos = $self->position;
  my $base = sprintf("%s\t%d\t%d",$pos->chrom,$pos->left,$pos->right);
  if ($self->id->name) {
    $base .= "\t" . $self->id->name;
    if (defined $self->{score}) {
      $base .= "\t" . $self->score;
      if (defined $pos->strand) {
        $base .= "\t" . $pos->strand;
      }
    }
  }
  $base .= "\n";
  return $base;
}

=head1 Background Material

The overall concept is of a main IO class with subclasses for each type we
want to read/write.  If you want to be general-purpose, you can just ask
SeqIO to open your file, and it'll open any type it understands (based on
suffix).

=cut

1
