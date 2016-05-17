package IO::SeqIO;

use strict; use warnings;
use Log::Log4perl qw(get_logger);
use FileHandle;
use IO::BedIO;
use IO::CigarIO;
use IO::FastaIO;
use IO::MacsXlsIO;

our $suffix2cls = {'.fq'=>'IO::FastqIO',
                   '.fa'=>'IO::FastaIO',
                   '.bed'=>'IO::BedIO',
                   '.qseq'=>'IO::QseqIO',
                   '.exon'=>'IO::ExonerateIO',
                   '.swembl'=>'IO::SwemblIO',
                   '.tRNAscan'=>'IO::tRNAscanIO',
                   '.exonx'=>'IO::ExonXIO',
                   '.cove'=>'IO::CoveIO',
                   '.cigar'=>'IO::CigarIO',
                   '.xls'=>'IO::MacsXlsIO'
                  };

sub newBySuffix {
  my $class = shift;
  my %args = @_;
  my $obj = undef;
  if (exists $args{fn}) {
    if ($args{fn} =~ /.*(\.\w+)$/) {
      my $suffix = $1;
      if (exists $suffix2cls->{$suffix}) {
        $obj = $suffix2cls->{$suffix}->new(@_);
      } else {
        get_logger()->error("Unknown suffix '$suffix', cannot open file.");
      }
    } else {
      get_logger()->error("Cannot find suffix in '${args{fn}}'");
    }
  } else {
    get_logger()->error("Must supply fn parameter");
  }
  return $obj;
}

sub new {
  my $class = shift;
  my %args = @_;
  my $obj = undef;
  if (exists $args{fn}) {
    $obj = bless {},$class;
    $obj->{fn} = $args{fn};
    $obj->{fd} = FileHandle->new();
    $obj->{fd}->open($args{fn});
    $obj->{linenum} = 0;
    $obj->{count} = 0;
    $obj->{isatty} = -t STDERR;
    if (exists $args{verbose}) {
      $obj->{verbose} = $args{verbose};
    } else {
      $obj->{verbose} = 0;
    }
  } else {
    get_logger()->error("Must supply fn parameter");
  }
  return $obj;
}

sub close {
  my $self = shift;
  $self->{fd}->close();
}

sub linenum {
  my $self = shift;
  return $self->{linenum};
}

sub next {
  my $self = shift;
  my $seq = $self->readseq();
  if (defined $seq && substr($seq,0,5) eq 'track') {
    $seq = $self->readseq();
  }
  if (defined $seq) {
    $self->{count} += 1;
    if ($self->{verbose} && $self->{count} % $self->{verbose} == 0) {
      print STDERR sprintf("%9d\r",$self->{count})
    }
  }
  return $seq;
}

1
