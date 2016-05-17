package IO::CigarIO;

use strict; use warnings;
use Log::Log4perl qw(get_logger);
use IO::SeqIO;
use Seq::Cigar;
use Seq::Position;

@IO::CigarIO::ISA = qw(IO::SeqIO);

sub readseq {
  my $self = shift;
  my $cigar = undef;
  if ($self->{fd}->eof) {
    return undef;
  }
  my $line = $self->{fd}->getline();
  chomp $line;
  my @flds = split(" ",$line);
  my $fldlen = scalar @flds;
  if ($fldlen < 11) {
    get_logger()->warn("Skipping short cigar line '$line'");
  } else {
    my $id = $flds[1];
    my $myleft = $flds[2];
    my $myright = $flds[3];
    my $mystrand = $flds[4];
    my $chrom = $flds[5];
    my $left = $flds[6];
    my $right = $flds[7];
    my $strand = $flds[8];
    my $score = $flds[9];
    my $cigarstring = join(" ",splice(@flds,10));
    if ($left > $right) {
      if (defined $strand && $strand eq '+') {
        get_logger()->warn(sprintf("CigarIO %d: %s:%d-%d left > right but strand = '+' (fixing)",
                                   $self->{linenum},$chrom,$left,$right));
      }
      my $tmp = $left;
      $left = $right+1;
      $right = $tmp+1;
      $strand = '-';
    }
    if ($myleft > $myright) {
      if (defined $mystrand && $mystrand eq '+') {
        get_logger()->warn(sprintf("CigarIO %d: %s:%d-%d left > right but strand = '+' (fixing)",
                                   $self->{linenum},$id,$myleft,$myright));
      }
      my $tmp = $myleft;
      $myleft = $myright+1;
      $myright = $tmp+1;
      $mystrand = '-';
    }
    my $pos = Seq::Position->new($chrom,$left,$right,$strand);
    my $mypos = Seq::Position->new($id,$myleft,$myright,$mystrand);
    $cigar = Seq::Cigar->new(id=>$id,score=>$score,position=>$pos,cigar=>$cigarstring,mypos=>$mypos);
  }
  return $cigar;
}

1
