package IO::FastaIO;

use strict; use warnings;
use Log::Log4perl qw(get_logger);
use IO::SeqIO;
use Seq::Fasta;

@IO::FastaIO::ISA = qw(IO::SeqIO);

sub readseq {
  my $self = shift;
  my $fa = undef;
  my $id;
  my $descr;
  if ($self->{fd}->eof) {
    return undef;
  }
  my $line;
  if (exists $self->{bufferline}) {
    $line = $self->{bufferline};
  } else {
    $line = $self->{fd}->getline();
  }
  if ($line =~ /^\s*\>\s*([^\s]+)(\s+(\S.*\S?))?\s*$/) {
    $id = $1;
    $descr = $3;
  } else {
    get_logger()->error("Cannot parse fasta header from line '$line'");
    exit(-1);
  }
  $line = $self->{fd}->getline();
  my @lines = ();
  while ($line && !($line =~ /^\s*\>/)) {
    chomp $line;
    push @lines, $line;
    my $lc = scalar @lines;
    $line = $self->{fd}->getline();
  }

  if (defined $line && length $line > 0) {
    $self->{bufferline} = $line;
  } else {
    $self->{bufferline} = undef;
  }
  my $seq = join "", @lines;
  $fa = Seq::Fasta->new(id=>$id,descr=>$descr,seq=>$seq);
  return $fa;
}

1
