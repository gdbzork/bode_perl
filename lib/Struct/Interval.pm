package Struct::Interval;

use strict; use warnings;
use Seq::Position;

sub new {
  my $class = shift;
  my %args = (position=>undef,label=>undef,@_);
  my $obj = {position=>$args{position},label=>$args{label}};
  bless $obj,$class;
  return $obj;
}

sub overlap {
  my ($self) = shift;
  my ($other) = shift;
  return $self->{position}->overlap($other);
}

sub label {
  my ($self) = shift;
  return $self->{label};
}

sub position {
  my ($self) = shift;
  return $self->{position};
}

1
