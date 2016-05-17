package Seq::SeqName;

use strict; use warnings;

sub new {
  my ($class,$name) = @_;
  my $self = {};
  if (ref($name) && $name->isa('Seq::SeqName')) {
    $self->{base} = $name->{base};
    $self->{name} = $name->{name};
    $self->{count} = $name->{count};
  } else {
    $self->{name} = $name;
    if ($name =~ /^(.*)_x(\d+)$/) {
      $self->{base} = $1;
      $self->{count} = $2;
    } else {
      $self->{base} = $name;
      $self->{count} = 1;
    }
  }
  bless $self,$class;
  return $self;
}

sub base {
  my ($self) = @_;
  return $self->{base};
}

sub count {
  my ($self) = @_;
  return $self->{count};
}

sub name {
  my ($self) = @_;
  return $self->{name};
}

sub equals {
  my ($self,$other) = @_;
  return ($self->{name} eq $other->{name});
}

1
