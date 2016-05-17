package RedBlackTree;

use strict; use warnings;
use Log::Log4perl qw(get_logger);
use RedBlackNode;

sub new {
  my $class = shift;
  return bless {root=>undef}, $class;
}

sub root {
  my $self = shift;
  return $self->{root};
}

sub setRoot {
  my ($self,$node) = @_;
  $self->{root} = $node;
}

sub insert {
  my ($self,$z) = @_;
  my $y = undef;
  my $x = $self->root;
  while (defined $x) {
    $y = $x;
    if ($z->key < $x->key) {
      $x = $x->left;
    } else {
      $x = $x->right;
    }
  }
  $z->setParent($y);
  if (!defined $y) {
    $self->setRoot($z);
  } elsif ($z->key < $y->key) {
    $y->setLeft($z);
  } else {
    $y->setRight($z);
  }
}

sub rbInsert {
  my ($self,$xkey) = @_;
  my $x = RedBlackNode->new($xkey);
  $self->insert($x);
  $x->setRed();
  while ($x != $self->{root} && $x->parent->isRed) {
    if (defined $x->parent->parent->left && $x->parent == $x->parent->parent->left) {
      my $y = $x->parent->parent->right;
      if (defined $y && $y->isRed) {
        $x->parent->setBlack();
        $y->setBlack();
        $x->parent->parent->setRed();
        $x = $x->parent->parent;
      } else {
        if (defined $x->parent->right && $x == $x->parent->right) {
          $x = $x->parent;
          $self->leftRotate($x);
        }
        $x->parent->setBlack();
        $x->parent->parent->setRed();
        $self->rightRotate($x->parent->parent);
      }
    } else {
      my $y = $x->parent->parent->left;
      if (defined $y && $y->isRed) {
        $x->parent->setBlack();
        $y->setBlack();
        $x->parent->parent->setRed();
        $x = $x->parent->parent;
      } else {
        if (defined $x->parent->left && $x == $x->parent->left) {
          $x = $x->parent;
          $self->rightRotate($x);
        }
        $x->parent->setBlack();
        $x->parent->parent->setRed();
        $self->leftRotate($x->parent->parent);
      }
    }
  }
  $self->{root}->setBlack();
}

sub leftRotate {
  my ($self,$x) = @_;
  my $y = $x->right;
  $x->setRight($y->left);
  if (defined $y->left) {
    $y->left->setParent($x);
  }
  $y->setParent($x->parent);
  if (!defined $x->parent) {
    $self->setRoot($y);
  } elsif ($x == $x->parent->left) {
    $x->parent->setLeft($y);
  } else {
    $x->parent->setRight($y);
  }
  $y->setLeft($x);
  $x->setParent($y);
}

sub rightRotate {
  my ($self,$x) = @_;
  my $y = $x->left;
  $x->setLeft($y->right);
  if (defined $y->right) {
    $y->right->setParent($x);
  }
  $y->setParent($x->parent);
  if (!defined $x->parent) {
    $self->setRoot($y);
  } elsif ($x == $x->parent->right) {
    $x->parent->setRight($y);
  } else {
    $x->parent->setLeft($y);
  }
  $y->setRight($x);
  $x->setParent($y);
}

1
