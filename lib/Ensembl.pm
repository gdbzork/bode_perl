package Ensembl;

=head1 NAME

Ensembl -- utilities and constants useful for interacting with Ensembl

=head1 SYNOPSIS

 $x = Ensembl::getRegistry(user="Bob",pass="Mary",host="morangie");

=head1 DESCRIPTION

Odds and ends for interacting with Ensembl

=cut

use strict; use warnings;
use Bio::EnsEMBL::Registry;
use Conf;

use vars qw($genome $taxid $taxid2short);

$genome = {'hsa' => 'homo sapiens',
           'mmu' => 'mus musculus',
           'cfa' => 'canis familiaris',
           'mml' => 'macaca mulatta',
           'rno' => 'rattus norvegicus',
           'mdo' => 'monodelphis domestica',
           'gga' => 'gallus gallus',
           'xtr' => 'xenopus tropicalis'};

$taxid = {'hsa' => 9606,
          'mmu' => 10090,
          'cfa' => 9615,
          'mml' => 9544,
          'rno' => 10116,
          'mdo' => 13616,
          'gga' => 9031,
          'xtr' => 8364};

my %taxid2shortp = reverse %$taxid;
$taxid2short = \%taxid2shortp;

=head2 getRegistry

 Args: host -- host name of the Ensembl server (optional, default in Conf.pm)
       user -- userid on the Ensembl server (optional, default in Conf.pm)
       pass -- password for the Ensembl server (optional, default in Conf.pm)

 Description: Creates a connection to the Ensembl database, returning the
              Registry object.  If no password is needed (as in Ensembl's
              public database), use "C<pass=undef>" to override the default
              password.

 Returntype: Bio::EnsEMBL::Registry

=cut

sub getRegistry {
  my %args = (host => $Conf::ENSEMBL_HOST,
              user => $Conf::ENSEMBL_USER,
              pass => $Conf::ENSEMBL_PASS,
              @_);
  my $reg = 'Bio::EnsEMBL::Registry';
  if (defined $args{pass}) {
    $reg->load_registry_from_db(-host => $args{host},
                                -user => $args{user},
                                -pass => $args{pass});
  } else {
    $reg->load_registry_from_db(-host => $args{host},
                                -user => $args{user});
  }
  return $reg;
}

=head2 toplevel

 Args: species -- species 3-letter code

 Description: Unfortunate hack to find the name of the "top level" coordinate
              system for a species.  Usually "toplevel" works, but not for
              macaques.

              NOTE: this may have been fixed in more recent versions of
              the Ensembl database.  Really should check someday.

 Returntype: string

=cut

sub toplevel {
  my %args = @_;
  Util::checkArgs(args=>\%args,req=>['species']);
  my $species = $args{species};
  my ($toplevel);
  if ($species eq "mml") {
    $toplevel = "chromosome";
  } else {
    $toplevel = "toplevel";
  }
  return $toplevel;
}

=head2 chrom2ensembl

 Args: chrom -- a chromosome name, in UCSC standard format

 Description: Converts a chromosome name into Ensembl notations:
              1) Remove any leading "chr"
              2) Convert "M" to "MT"

 Returntype: string

=cut

sub chrom2ensembl {
  my %args = @_;
  Util::checkArgs(args=>\%args,req=>['chrom']);
  my $chrom = $args{chrom};
  my $chrshort = substr($chrom,0,3) eq "chr" ? substr($chrom,3) : $chrom;
  if ($chrshort eq "M") {
    $chrshort = "MT";
  }
  return $chrshort;
}

=head2 fixCoords

 Args: leftr -- a reference to a number
       rightr -- a reference to a number

 Description: Converts Ensembl coordinates into local coordinates 
              (0-relative, half-open)
              1) If left > right, swap them.
              2) Decrement left, to convert it to 0-relative coords.
              Leave "right" unchanged, since in 0-relative coords, it's already
              one past the end of the string.

 Returntype: none, destructively modifies the numbers whose references were
             passed in.

=cut

sub fixCoords {
  my %args = @_;
  Util::checkArgs(args=>\%args,req=>['leftr','rightr']);
  my ($leftr,$rightr) = ($args{leftr},$args{rightr});
  my ($l,$r);
  $l = $$leftr;
  $r = $$rightr;
  if ($l > $r) {
    my $t = $l;
    $l = $r;
    $r = $t;
  }
  $l--;
  $$leftr = $l;
  $$rightr = $r;
}

1
