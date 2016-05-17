package Seq::Cigar;

=head1 NAME

Seq::Cigar -- stores a Cigar file entry

=head1 SYNOPSIS

 $x = $cigarobj->string()

=head1 DESCRIPTION

Stores a Cigar file entry.  Coordinates are 0-based, half-open.  Most of the
functionality is inherited from C<AlignedSeq>.

=cut

use strict; use warnings;
use Seq::AlignedSeq;

@Seq::Cigar::ISA = qw(Seq::AlignedSeq);

=head2 string

  Args: none

  Description: Returns a string representing this Cigar file entry, including
               a trailing newline.
  Returntype:  string

=cut 

sub new {
  my $class = shift;
  my %args = (id=>undef,score=>undef,position=>undef,@_);
  my $obj = $class->SUPER::new(id=>$args{id},
                               score=>$args{score},
                               position=>$args{position});
  bless $obj,$class;
  $obj->{cigar} = $args{cigar};
  $obj->{mypos} = $args{mypos};
  return $obj;
}

sub string {
  my $self = shift;
  my $chrpos = $self->position;
  my $mypos = $self->{mypos};
  my ($chrleft,$chrright,$myleft,$myright);
  if ($chrpos->strand eq "-") {
    $chrleft = $chrpos->right - 1;
    $chrright = $chrpos->left - 1;
  } else {
    $chrleft = $chrpos->left;
    $chrright = $chrpos->right;
  }
  if ($mypos->strand eq "-") {
    $myleft = $mypos->right - 1;
    $myright = $mypos->left - 1;
  } else {
    $myleft = $mypos->left;
    $myright = $mypos->right;
  }
  my $cigar = sprintf("cigar: %s %d %d %s %s %d %d %s %d  %s\n",
                      $self->id->name,
                      $myleft,$myright,$mypos->strand,
                      $chrpos->chrom,$chrleft,$chrright,$chrpos->strand,
                      $self->{score},$self->{cigar});
  return $cigar;
}

=head1 Background Material

The overall concept is of a main IO class with subclasses for each type we
want to read/write.  If you want to be general-purpose, you can just ask
SeqIO to open your file, and it'll open any type it understands (based on
suffix).

=cut

1
