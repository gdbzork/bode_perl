package Seq::MacsXls;

=head1 NAME

Seq::MacsXls -- stores a Macs XLS file entry

=head1 SYNOPSIS

 $x = $bedobj->string()

=head1 DESCRIPTION

Stores a Macs XLS file entry.  Coordinates are 0-based, half-open.  Most of the
functionality is inherited from C<AlignedSeq>.

=cut

use strict; use warnings;
use Seq::AlignedSeq;

@Seq::MacsXls::ISA = qw(Seq::AlignedSeq);

sub new {
  my $class = shift;
  my %args = @_;
  my $obj = $class->SUPER::new(id=>$args{id},
                               score=>$args{score},
                               position=>$args{position});
  bless $obj,$class;
  $obj->{peaklen} = $args{peaklen};
  $obj->{summit} = $args{summit};
  $obj->{tags} = $args{tags};
  $obj->{fold} = $args{fold};
  $obj->{fdr} = $args{fdr};
  return $obj;
}

=head2 string

  Args: none

  Description: Returns a string representing this entry, including
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

sub peaklen {
  my $self = shift;
  return $self->{length};
}

sub summit {
  my $self = shift;
  return $self->{summit};
}

sub tagcount {
  my $self = shift;
  return $self->{tags};
}

sub fold {
  my $self = shift;
  return $self->{fold};
}

sub fdr {
  my $self = shift;
  return $self->{fdr};
}

=head1 Background Material

The overall concept is of a main IO class with subclasses for each type we
want to read/write.  If you want to be general-purpose, you can just ask
SeqIO to open your file, and it'll open any type it understands (based on
suffix).

=cut

1
