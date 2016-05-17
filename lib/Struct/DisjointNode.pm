package Struct::DisjointNode;

use strict; use warnings;

sub new {
  my $class = shift;
  my $name = shift;
  my $self = {rank=>0,id=>$name};
  $self->{parent} = $self;
  bless $self, $class;
  return $self;
}

sub rank {
  my $self = shift;
  return $self->{rank};
}

sub parent {
  my $self = shift;
  return $self->{parent};
}

sub id {
  my $self = shift;
  return $self->{id};
}

sub incrRank {
  my $self = shift;
  $self->{rank} += 1;
}

sub setParent {
  my ($self,$parent) = @_;
  $self->{parent} = $parent;
}

1
