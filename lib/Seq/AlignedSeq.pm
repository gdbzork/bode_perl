package Seq::AlignedSeq;

use strict; use warnings;
use Log::Log4perl qw(get_logger);
use Seq::Sequence;

@Seq::AlignedSeq::ISA = qw(Seq::Sequence);

sub new {
  my $class = shift;
  my %args = (id=>undef,score=>undef,position=>undef,@_);
  my $obj = $class->SUPER::new(id=>$args{id});
  bless $obj,$class;
  $obj->{score} = $args{score};
  $obj->{position} = $args{position};
  return $obj;
}
  
sub position {
  my $self = shift;
  my %args = @_;
  if (defined $args{position}) {
    if ($args{position}->isa('Seq::Position')) {
      $self->{position} = $args{position};
    } else {
      get_logger()->warn("AlignedSeq: attempt to set position with non-Position object");
    }
  }
  return $self->{position};
}

sub score {
  my $self = shift;
  my %args = @_;
  if (defined $args{score}) {
    $self->{score} = $args{score};
  }
  return $self->{score};
}

sub cmp {
  my $self = shift;
  my $other = shift;

  my $rv = 0;
  if (!($other->isa('Seq::AlignedSeq'))) {
    get_logger()->error("Attempt to compare AlignedSeq with non-AlignedSeq object");
  } else {
    $rv = $self->{position}->cmp($other->{position});
  }
  return $rv;
}

1
