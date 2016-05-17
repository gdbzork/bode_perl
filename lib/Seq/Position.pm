package Seq::Position;

=head1 NAME

Position -- stores the position of a region on a DNA strand.

=head1 SYNOPSIS

  $pos = Position->new($chrom,$left,$right,$strand);

  $c = $pos->chrom;
  $l = $pos->left;
  $r = $pos->right;
  $s = $pos->strand;

  if ($pos->overlap($other_pos)) {
    ... do something ...
  }

  $upstream = $pos->cmp($other_pos) < 0;

  print $pos->string;

=head1 DESCRIPTION

Stores a position and strand on a DNA sequence (typically a chromosome).
Coordinates are 0-relative (i.e. the leftmost position is 0), and half-open
(i.e. the right value is one past the end of the sequence).  It is the
responsibility of the software using this class to ensure that this convention
is maintained.

C<left> must always be less than or equal to C<right>; they will be swapped
(and the strand set to "-") if this condition is violated.  It will also
generate a warning.  Strand is either '+', '-', or undefined.

=cut

use strict; use warnings;
use Log::Log4perl qw (get_logger);
use Util;

=head2 new

 Args: C<chrom> -- the name of the DNA sequence
       C<left> -- leftmost position relative to the sequence
       C<right> -- rightmost end of the position (plus 1)
       C<strand> -- which strand this region is associated with (optional)
 OR:
       C<position> -- pass a C<position> as the parameter, to clone that
                      C<Position> object and return the clone.

 Description: Returns a new C<Position> object.

 Returntype:  C<Position>

=cut

sub new {
  my $class = shift;
  my $self = {};
  bless $self, $class;

  my $chrom = shift;
  if (ref($chrom) eq 'Seq::Position') {
    $self->{chrom} = $chrom->chrom;
    $self->{left} = $chrom->left;
    $self->{right} = $chrom->right;
    $self->{strand} = $chrom->strand;
  } else {
    $self->{chrom} = $chrom;
    $self->{left} = shift;
    $self->{right} = shift;
    $self->{strand} = undef;
    if (scalar @_ > 0) {
      $self->{strand} = shift;
    }
    if ($self->right < $self->left) {
      get_logger("")->warn(sprintf("Position: %s:%d-%d left > right, flipping",$self->chrom,$self->left,$self->right));
      my $tmp = $self->right;
      $self->{right} = $self->left;
      $self->{left} = $tmp;
      $self->{strand} = '-';
    }
  }
  return $self;
}

=head2 string

 Args: none

 Description: returns a string representation of this C<Position>, suitable
              for cutting and pasting into the UCSC genome browser.  Output
              is "chrom:left-right" or "chrom:left-right(strand)" if the
              strand is defined.

 Returntype: string

=cut

sub string {
  my ($self) = shift;
  my $strand = "";
  if (defined $self->{strand}) {
    $strand = sprintf("(%s)",$self->{strand});
  }
  return sprintf("%s:%d-%d%s",$self->{chrom},$self->{left},$self->{right},$strand);
}
  
=head2 chrom

 Args: chromname (optional)

 Description: Get/Set the chromosome name.

 Returntype: string

=cut

sub chrom {
  my ($self) = shift;
  return $self->{chrom};
}

=head2 shortChrom

 Args: none

  Description: Get the chromosome name, without the "chr"

  Returntype: string

=cut

sub shortChrom {
  my ($self) = shift;
  my $chr = $self->{chrom};
  if ($chr =~ /^chr/) {
    $chr = substr $chr,3;
  }
  if ($chr eq "M") {
    $chr = "MT";
  }
  return $chr;
}

=head2 left

 Args: left position (optional)

 Description: Get/Set the left end of the position.

 Returntype: integer

=cut

sub left {
  my ($self) = shift;
  return $self->{left};
}

=head2 right

 Args: right position (optional)

 Description: Get/Set the right end of the position.

 Returntype: integer

=cut

sub right {
  my ($self) = shift;
  return $self->{right};
}

=head2 strand

 Args: strand (optional)

 Description: Get/Set the strand.  Legal values are '+', '-', 'undef'.

 Returntype: string (or undef)

=cut

sub strand {
  my ($self) = shift;
  return $self->{strand};
}

sub _chromComp {
  my ($self,$other) = @_;
  my ($n1,$t1) = $self->chrom =~ /^chr(\d+)(_\w+)?$/;
  my ($n2,$t2) = $other->chrom =~ /^chr(\d+)(_\w+)?$/;
  if (defined $n1 && defined $n2) {
    if ($n1 == $n2) {
      return $t1 <=> $t2;
    } else {
      return $n1 <=> $n2;
    }
  } elsif (defined $n1) {
    return -1;
  } elsif (defined $n2) {
    return 1;
  } else {
    return $self->chrom cmp $other->chrom;
  }
}

=head2 cmp

 Args: position -- the other position to compare this one to

 Description: Returns less than 0, 0, or greater than 0 depending on whether
              this position is less than, equal to, or greater than the other
              one.  If the two positions are on different chromosomes, they
              are ordered by chromosome name (e.g. chr1 < chr2).  If they are
              on the same chromosome, they are ordered by left end, right end,
              and strand ('+' < '-'), in that order.

 Returntype: string (or undef)

=cut

sub cmp {
  my ($self,$other) = @_;
  my $cc = $self->_chromComp($other);
  if ($cc == 0) {
    if ($self->left == $other->left && $self->right == $other->right) {
      return $self->strand cmp $other->strand;
    } elsif ($self->left == $other->left) {
      return $self->right <=> $other->right;
    } else {
      return $self->left <=> $other->left;
    }
  } else {
    return $cc;
  }
}

=head2 overlap

 Args: position -- another position to compare this one to
       span -- how many nucleotides they must overlap by (optional, default 1)

 Description: returns true value if this position and the passed-in position
              overlap by at least C<span> nucleotides.

  Returntype: boolean

=cut

sub overlap {
  my $self = shift;
  my $other = shift;
  my $span = 1;
  if (scalar @_ > 0) {
    $span = shift;
  }
  my $left = Util::max($self->left,$other->left);
  my $right = Util::min($self->right,$other->right);
  return $right - $left >= $span;
}

sub distance {
  my $self = shift;
  my $other = shift;
  my $d = abs($self->right - $other->right) + abs($self->left - $other->left);
  return $d;
}

sub flength {
  my $self = shift;
  return $self->right - $self->left;
}

1
