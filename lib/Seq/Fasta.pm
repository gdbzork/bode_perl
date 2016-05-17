package Seq::Fasta;

=head1 NAME

Seq::Fasta -- stores a Fasta file entry

=head1 SYNOPSIS

 $x = $fastaobj->string()

=head1 DESCRIPTION

Stores a Fasta file entry.

=cut

use strict; use warnings;
use Seq::Sequence;

@Seq::Fasta::ISA = qw(Seq::Sequence);

sub new {
  my $cls = shift;
  my %args = (id=>undef,descr=>undef,seq=>undef,@_);

  my $obj = $cls->SUPER::new(id=>$args{id},seq=>$args{seq});
  bless $obj,$cls;
  $obj->{descr} = $args{descr};
  return $obj;
}

sub fmt {
  my $self = shift;
  my %args = (data=>$self->seq,width=>200,@_);

  my $str = "";
  my $width = $args{'width'};
  my $data = $args{'data'};
  while (length $data > $width) {
    $str = $str . substr($data,0,$width) . "\n";
    $data = substr($data,$width);
  }
  if (length $data > 0) {
    $str = $str . $data . "\n";
  }
  return $str;
}

=head2 string

  Args: none

  Description: Returns a string representing this Fasta file entry, including
               a trailing newline.
  Returntype:  string

=cut 

sub string {
  my $self = shift;
  return sprintf(">%s %s\n%s",$self->id->name,$self->{descr},$self->fmt());
}

=head1 Background Material

The overall concept is of a main IO class with subclasses for each type we
want to read/write.  If you want to be general-purpose, you can just ask
SeqIO to open your file, and it'll open any type it understands (based on
suffix).

=cut

1
