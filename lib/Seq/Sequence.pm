package Seq::Sequence;

use strict; use warnings;
use Seq::Position;
use Seq::SeqName;

sub new {
  my $class = shift;
  my %args = (id=>undef,seq=>undef,@_);

  my $obj = bless {},$class;
  $obj->{id} = Seq::SeqName->new($args{id});
  $obj->{seq} = $args{seq};
  return $obj;
}

sub id {
  my $self = shift;
  my %args = @_;
  if (defined $args{id}) {
    $self->{id} = $args{id};
  }
  return $self->{id};
}

sub seq {
  my $self = shift;
  my %args = @_;
  if (defined $args{seq}) {
    $self->{seq} = $args{seq};
  }
  return $self->{seq};
}

sub eq {
  my $self = shift;
  my $other = shift;
  return ref($other)
         && $other->isa('Seq::Sequence')
         && $self->{seq} eq $other->{seq};
}

1
