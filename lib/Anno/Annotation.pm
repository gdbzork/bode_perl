package Anno::Annotation;

use strict; use warnings;
use Log::Log4perl qw(get_logger);

sub new {
  my $class = shift;
  my %args = @_;

  my $obj = bless {}, $class;
  $obj->{name} = $args{name};
  $obj->{type} = $args{type};
  if (!defined $args{position}) {
    get_logger()->warn("Undefined position for name=${args{name}}, type=${args{type}}");
  }
  $obj->{position} = $args{position};
  return $obj;
}

sub string {
  my ($self) = shift;
  my $zork = $self->{name};
  if (!defined $zork) {
    $zork = "unk";
  }
  return sprintf("%s\t%s\t%s",$self->{position}->string(),$self->{type},$zork);
}

sub name {
  my ($self) = shift;
  return $self->{name};
}

sub type {
  my ($self) = shift;
  return $self->{type};
}

sub position {
  my ($self) = shift;
  return $self->{position};
}

1
