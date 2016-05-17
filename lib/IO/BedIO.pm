package IO::BedIO;

use strict; use warnings;
use Log::Log4perl qw(get_logger);
use IO::SeqIO;
use Seq::Bed;
use Seq::Position;

@IO::BedIO::ISA = qw(IO::SeqIO);

sub readseq {
  my $self = shift;
  my $bed = undef;
  if ($self->{fd}->eof) {
    return undef;
  }
  my $line = $self->{fd}->getline();
  chomp $line;
  my @flds = split(" ",$line);
  my $fldlen = scalar @flds;
  if ($fldlen < 3) {
    get_logger()->warn("Skipping short bed line '$line'");
  } else {
    my $left = $flds[1];
    my $right = $flds[2];
    my $id = undef;
    my $score = undef;
    my $strand = undef;
    if ($fldlen >= 4) {
      $id = $flds[3];
      if ($fldlen >= 5) {
        $score = $flds[4];
        if ($fldlen >= 6) {
          $strand = $flds[5];
        }
      }
    }
    if ($left > $right) {
      if (defined $strand && $strand eq '+') {
        get_logger()->warn(sprintf("BedIO %d: %s:%d-%d left > right but strand = '+' (fixing)",
                                   $self->{linenum},$flds[0],$left,$right));
      }
      my $tmp = $left;
      $left = $right+1;
      $right = $tmp+1;
      $strand = '-';
    }
    my $pos = Seq::Position->new($flds[0],$left,$right,$strand);
    $bed = Seq::Bed->new(id=>$id,score=>$score,position=>$pos);
  }
  return $bed;
}

1
