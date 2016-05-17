package IO::MacsXlsIO;

use strict; use warnings;
use Log::Log4perl qw(get_logger);
use IO::SeqIO;
use Seq::MacsXls;
use Seq::Position;

@IO::MacsXlsIO::ISA = qw(IO::SeqIO);

sub readseq {
  my $self = shift;
  my $xls = undef;
  if ($self->{fd}->eof) {
    return undef;
  }
  my $line = $self->{fd}->getline();
  while (substr($line,0,1) eq '#') {
    $line = $self->{fd}->getline();
  }
  chomp $line;
  my @flds = split("\t",$line);
  if ($flds[0] eq 'chr') {
    $line = $self->{fd}->getline();
    @flds = split("\t",$line);
  }
  my $fldlen = scalar @flds;
  if ($fldlen != 9) {
    get_logger()->warn("Skipping bad MacsXls line '$line'");
  } else {
    my $left = $flds[1];
    my $right = $flds[2];
    my $id = sprintf("%s_%s_%s",$flds[0],$flds[1],$flds[2]);
    my $peaklen = $flds[3];
    my $summit = $flds[4];
    my $tagcount = $flds[5];
    my $score = $flds[6];
    my $fold = $flds[7];
    my $fdr = $flds[8];
    if ($left > $right) {
      my $tmp = $left;
      $left = $right+1;
      $right = $tmp+1;
    }
    my $pos = Seq::Position->new($flds[0],$left,$right,'+');
    $xls = Seq::MacsXls->new(id=>$id,score=>$score,position=>$pos,
                             peaklen=>$peaklen,summit=>$summit,tags=>$tagcount,
                             fold=>$fold,fdr=>$fdr);
  }
  return $xls;
}

1
