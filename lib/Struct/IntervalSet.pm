package Struct::IntervalSet;

use strict; use warnings;
use IO::SeqIO;
use Struct::Interval;

sub new {
  my $class = shift;
  my %args = (fn=>undef,@_);
  my $obj = {fn=>$args{fn},data=>[]};
  bless $obj,$class;
  my $handle = IO::SeqIO->newBySuffix(fn=>$args{fn});
  my $seq;
  while ($seq = $handle->next()) {
    my $lab = $args{species} . "_" . $seq->id->name;
    my $inter = Struct::Interval->new(position=>$seq->position,label=>$lab);
    push @{$obj->{data}}, $inter;
  }
  $handle->close();
  return $obj;
}

sub summary {
  my $self = shift;
  print $self->{fn}, ": ", scalar @{$self->{data}}, " seqs\n";
}

sub overlap {
  my $self = shift;
  my $pos = shift;
  foreach my $seq (@{$self->{data}}) {
    if ($seq->overlap($pos)) {
      return $seq;
    }
  }
  return undef;
}

1
