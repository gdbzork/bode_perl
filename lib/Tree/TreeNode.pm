package TreeNode;

use strict; use warnings;
use Log::Log4perl qw(get_logger);

sub new {
  my ($class,$key) = @_;
  return bless {key=>$key,left=>undef,right=>undef,parent=>undef}, $class;
}

sub left {
  my $self = shift;
  return $self->{left};
}

sub setLeft {
  my ($self,$node) = @_;
  $self->{left} = $node;
}

sub right {
  my $self = shift;
  return $self->{right};
}

sub setRight {
  my ($self,$node) = @_;
  $self->{right} = $node;
}

sub parent {
  my $self = shift;
  return $self->{parent};
}

sub setParent {
  my ($self,$node) = @_;
  $self->{parent} = $node;
}

sub key {
  my $self = shift;
  return $self->{key};
}

sub dump {
  my ($self,$fd,$indent) = @_;
  print $indent,$self->isRed?"red":"black","  ",$self->{key},"\n";
  print $indent,"left\n";
  $self->left->dump($fd,$indent."  ") unless !defined $self->left;
  print $indent,"right\n";
  $self->right->dump($fd,$indent."  ") unless !defined $self->right;
}

1
