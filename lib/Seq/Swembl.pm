package Seq::Swembl;

use strict; use warnings;
use Log::Log4perl qw(get_logger);
use Seq::AlignedSeq;

@Seq::Swembl::ISA = qw(Seq::AlignedSeq);

our @fields = qw(position count length unique score
                 refcount coverage summit);

sub new {
  my $class = shift;
  my %args = @_;

  my $obj = $class->SUPER::new(id=>$args{id},
                               score=>$args{score},
                               position=>$args{position});
  bless $obj,$class;
  foreach my $fld (@Swembl::fields) {
    if (exists $args{$fld}) {
      $obj->{$fld} = $args{$fld} unless exists $obj->{$fld};
    } else {
      get_logger()->error("Missing argument '$fld' in Swembl::new");
    }
  }
  return $obj;
}

sub string {
  my $self = shift;

  my $p = $self->{position};
  return sprintf("%s\t%d\t%d\t%d\t%d\t%d\t%f\t%d\t%f\t%f\n",
                 $p->chrom,$p->left+1,$p->right,$self->count,$self->length,
                 $self->unique,$self->score,$self->refcount,$self->coverage,
                 $self->summit);
}

sub count {
  my $self = shift;
  return $self->{count};
}

sub length {
  my $self = shift;
  return $self->{length};
}

sub unique {
  my $self = shift;
  return $self->{unique};
}

sub refcount {
  my $self = shift;
  return $self->{refcount};
}

sub coverage {
  my $self = shift;
  return $self->{coverage};
}

sub summit {
  my $self = shift;
  return $self->{summit};
}

1
