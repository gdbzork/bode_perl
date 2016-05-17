package Synteny::Synteny;

use strict; use warnings;
use Log::Log4perl qw(get_logger);
use Data::Dumper;
use Bio::EnsEMBL::Registry;
use Ensembl;
use Synteny::SyntenySyn;
use Synteny::SyntenyAln;

sub new {
  my $class = shift;
  my ($root,$method,$genomes) = @_;
  my $genset = {};
  my $taxids = {};
  foreach my $genome (keys %$genomes) {
    $genset->{$genome} = 1;
    $taxids->{$Ensembl::taxid->{$genome}} = $genome;
  }
  my $obj = {root => $root,
             method => $method,
             genomes => $genset,
             taxids => $taxids};
  $obj->{registry} = "Bio::EnsEMBL::Registry";
  $obj->{registry}->load_registry_from_db(-host=>"ensembldb.ensembl.org",
                                          -user=>"anonymous");
#  $obj->{registry}->load_registry_from_db(-host=>"morangie.crnet.org",
#                                          -user=>"ensembl",
#                                          -pass=>"ensembl");
  $obj->{mlss_adaptor} = $obj->{registry}->get_adaptor("Multi",
                                                       "compara",
                                                       "MethodLinkSpeciesSet");
  if ($method eq "SYNTENY") {
    bless $obj, "Synteny::SyntenySyn";
  } else {
    bless $obj, "Synteny::SyntenyAln";
  }
  $obj->init();
  return $obj;
}

sub displaySet {
  my ($self,$mlss,$fd,$names,$indent,$common) = @_;
  my $sset = $mlss->species_set;
  my $sscount = scalar @$sset;
  print $fd $indent,$mlss->method_link_type," n=",$sscount," ";
  if ($names) {
    if ($common) {
      print $fd join ", ", (map { $_->taxon->{'_tags'}->{'genbank common name'} } @$sset);
    } else {
      print $fd join ", ", (map { $_->name } @$sset);
    }
  }
  print $fd "\n";
}

sub listGenomeSets {
  my ($self,$method,$indent,$common) = @_;
  my $mlsses = $self->{mlss_adaptor}->fetch_all_by_method_link_type($method);
  my $names = {};
  foreach my $m (@$mlsses) {
    $self->displaySet($m,\*STDOUT,1,$indent,$common);
  }
}

sub listMethods {
  my ($self,$listsets) = @_;
  my $mlsses = $self->{mlss_adaptor}->fetch_all();
  my $names = {};
  foreach my $m (@$mlsses) {
    $names->{$m->method_link_type} = 1;
  }
  my @flavours = sort keys(%$names);
  foreach my $f (@flavours) {
    print $f,"\n";
    $self->listGenomeSets($f,"  ") if $listsets;
  }
}

sub getGenomeDB {
  my ($self) = @_;
  my $x = $self->{registry}->get_adaptor("Multi","compara","GenomeDB");
  my $y = $x->fetch_by_name_assembly($Ensembl::genome->{$self->{'root'}},undef);
  return $y;
}

sub genomesAreInMLSS {
  my ($self,$mlss) = @_;
  my $genomesInMLSS = {};
  my $gen;
  my $okay = 1;
  foreach $gen ( map { $_->taxon_id } @{$mlss->species_set} ) {
    $genomesInMLSS->{$gen} = 1;
  }
  foreach $gen (keys %{$self->{'genomes'}}) {
    if (!exists($genomesInMLSS->{$Ensembl::taxid->{$gen}})) {
      $okay = 0;
    }
  }
  return $okay;
}

sub loadMLSS {
  my ($self) = @_;
  my $mlsses = $self->{mlss_adaptor}->fetch_all_by_method_link_type($self->{method});
  $self->{'mlss'} = undef;
  my $count = 10000; # an arbitrary large number
  foreach my $m (@$mlsses) {
    # the "count" weirdness is to ensure that we get the smallest set which
    # contains all the species of interest (e.g. there's an EPO 4 and an EPO 9;
    # if the EPO 4 has all the genomes we want, we prefer it to EPO 9).
    if (scalar @{$m->species_set} < $count && $self->genomesAreInMLSS($m)) {
      $self->{'mlss'} = $m;
      $count = scalar @{$m->species_set};
      $self->{count} = $count;
    }
  }
  if (!defined $self->{mlss}) {
    get_logger()->warn("failed to find MLSS for method='",$self->{method},
                       "', taxa=",join(" ",keys(%{$self->{genomes}})));
  } else {
    get_logger()->info("found ", $self->{method}," ",$self->{'count'},
                       ": ",join(", ",
                       (map {$_->name} @{$self->{mlss}->species_set})), "\n");
  }
  return defined $self->{mlss};
}

sub getChromosomes {
  my ($self,$root) = @_;
}

################################################################################

1
