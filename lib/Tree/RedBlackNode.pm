package RedBlackNode;

use strict; use warnings;
use Log::Log4perl qw(get_logger);
use Tree::TreeNode;

@Tree::RedBlackNode::ISA = qw(Tree::TreeNode);

sub new {
  my ($class,$key) = @_;
  my $obj = $class->SUPER::new($key);
  $obj->{isRed} = 1;
  return $obj;
}

sub isRed {
  my $self = shift;
  return $self->{isRed};
}

sub setRed {
  my $self = shift;
  $self->{isRed} = 1;
}

sub setBlack {
  my $self = shift;
  $self->{isRed} = 0;
}

1
