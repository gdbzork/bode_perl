package Anno::AnnotationGroup;

use strict; use warnings;
use Log::Log4perl qw(get_logger);

our $BORING = {"Dust"=>1,
               "Tandem repeats"=>1,
               "intron"=>1,
               "CpG islands"=>1,
               "Simple reeats"=>1,
               "First EF"=>1};

sub new {
  my $class = shift;
  my %args = @_;
  my $obj = bless {}, $class;
  $obj->{annotations} = [];
  $obj->{position} = $args{position};
  return $obj;
}

sub add {
  my $self = shift;
  my %args = @_;
  if (defined $args{annotation} && $args{annotation}->isa('Anno::Annotation')) {
    push @{$self->{annotations}}, $args{annotation};
  } else {
    get_logger()->warn("AnnotationGroup: attempt to add non-Annotation");
  }
}

sub position {
  my $self = shift;
  return $self->{position};
}

sub _covers {
  my $self = shift;
  my ($a,$b) = @_;
  return $a->left <= $b->left && $a->right >= $b->right;
}

sub getBest {
  my $self = shift;
  my $best = undef;
  my $bestlen = 1000000000; # some number larger than the length of any one annotation
  my $anno = $self->{annotations};
  my $acount = scalar @$anno;
  my $i = 0;
  my $p = $self->position->string();
  print "position: $p\n";
  my @boring = ();
  while ($i < $acount) {
    my $candidate = $anno->[$i];
    if (exists $BORING->{$candidate->type()}) {
      push @boring, $candidate;
    } else {
      my $candidate_pos = $candidate->position;
      my $cs = $candidate->string();
      print "    candidate: $cs\n";
#    my $cand_length = $candidate_pos->right - $candidate_pos->left;
#    if ($self->_covers($candidate_pos,$self->position) 
#        && $cand_length < $bestlen)
#    {
      my $dist = $candidate_pos->distance($self->position);
      if ($dist < $bestlen) {
        $best = $candidate;
        $bestlen = $dist;
      }
    }
    $i++;
  }
  if (!defined $best) {
    while (@boring) {
      my $candidate = shift @boring;
      my $candidate_pos = $candidate->position;
      my $cs = $candidate->string();
      print "    candidate: $cs\n";
#    my $cand_length = $candidate_pos->right - $candidate_pos->left;
#    if ($self->_covers($candidate_pos,$self->position) 
#        && $cand_length < $bestlen)
#    {
      my $dist = $candidate_pos->distance($self->position);
      if ($dist < $bestlen) {
        $best = $candidate;
        $bestlen = $dist;
      }
    }
  }
  if (defined $best) {
    my $bs = $best->string();
    print "    best: $bs\n";
  } else {
    print "    best: none\n";
  }
  return $best;
}

sub iterator {
  my $self = shift;
  my $current = 0;
  my $total = scalar @{$self->{annotations}};
  return sub {
    if ($current == $total) {
      return undef;
    }
    return $self->{annotations}->[$current++];
  }
}

1
