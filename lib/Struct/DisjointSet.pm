package Struct::DisjointSet;

use strict; use warnings;
use Struct::DisjointNode;

sub new {
  my $class = shift;
  my $self = {nodes=>{}};
  bless $self, $class;
  return $self;
}

sub makeSet {
  my ($self,$id) = @_;
  my $node = Struct::DisjointNode->new($id);
  $self->{nodes}->{$id} = $node;
}

sub union {
  my ($self,$x,$y) = @_;
  $self->linkSets($self->findSet($x),$self->findSet($y));
}

sub linkSets {
  my ($self,$x,$y) = @_;
  if ($x->rank() > $y->rank()) {
    $y->setParent($x);
  } else {
    $x->setParent($y);
    if ($x->rank() == $y->rank()) {
      $y->incrRank();
    }
  }
}

sub findSet {
  my ($self,$x) = @_;
  if ($x != $x->parent()) {
    $x->setParent($self->findSet($x->parent()));
  }
  return $x->parent();
}

sub getNode {
  my ($self,$id) = @_;
  if (exists $self->{nodes}->{$id}) {
    return $self->{nodes}->{$id};
  } else {
    return undef;
  }
}

sub getParentId {
  my ($self,$x) = @_;
  return $self->findSet($x)->id();
}

sub dumpSets {
  my ($self) = @_;
  my $sets = {};
  foreach my $id (keys %{$self->{nodes}}) {
    my $p = $self->getParentId($self->getNode($id));
    if (!exists $sets->{$p}) {
      $sets->{$p} = {};
    }
    $sets->{$p}->{$id} = 1;
  }

  foreach my $k (keys %$sets) {
    my @s = keys %{$sets->{$k}};
    print join " ", @s;
    print "\n";
  }
}

1
