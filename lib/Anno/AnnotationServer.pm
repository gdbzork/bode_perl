package Anno::AnnotationServer;

use strict; use warnings;
use Log::Log4perl qw(get_logger);
use Data::Dumper;
use Ensembl;
use Anno::Annotation;
use Seq::Position;

sub new {
  my $class = shift;
  my %args = @_;
  if (!defined $args{genome}) {
    get_logger()->error("AnnotationServer: no genome specified");
    return undef;
  }
  my $obj = bless {},$class;
  $obj->{reg} = Ensembl::getRegistry(@_); # pass user, pass, etc to registry
  $obj->{slicead} = $obj->{reg}->get_adaptor($Ensembl::genome->{$args{genome}},
                                             "Core",
                                             "Slice");
  return $obj;
}

sub _loadRepeats {
  my $self = shift;
  my ($slice,$group) = @_;
  my $repeats = $slice->get_all_RepeatFeatures();
  foreach my $rep (@$repeats) {
    $rep = $rep->transform('chromosome');
    my $left = $rep->start;
    my $right = $rep->end;
    Ensembl::fixCoords(leftr=>\$left,rightr=>\$right);
    my $reptype = $rep->repeat_consensus->repeat_type;
    if ($reptype eq 'RNA repeats') {
      $reptype = $rep->repeat_consensus->repeat_class;
    }
    my $apos = Seq::Position->new($group->position->chrom,$left,$right);
    my $anno = Anno::Annotation->new(name=>$rep->repeat_consensus->name,
                                     type=>$reptype,
                                     position=>$apos);
    $group->add(annotation=>$anno);
  }
}

sub _loadExons {
  my $self = shift;
  my ($slice,$group) = @_;
  my $genes = $slice->get_all_Genes();
  foreach my $gene (@$genes) {
    my $exons = $gene->get_all_Exons();
    my $inExon = 0;
    foreach my $exon (@$exons) {
      $exon = $exon->transform('chromosome');
      my $left = $exon->start;
      my $right = $exon->end;
      Ensembl::fixCoords(leftr=>\$left,rightr=>\$right);
      my $exonPos = Seq::Position->new($group->position->chrom,$left,$right);
      if ($exonPos->overlap($group->position)) {
        my $anno = Anno::Annotation->new(name=>$gene->external_name,
                                         type=>$gene->biotype,
                                         position=>$exonPos);
        $group->add(annotation=>$anno);
        $inExon = 1;
      }
    }
    if (!$inExon) {
      my $left = $gene->start;
      my $right = $gene->end;
      Ensembl::fixCoords(leftr=>\$left,rightr=>\$right);
      my $pos = Seq::Position->new($group->position->chrom,$left,$right);
      my $anno = Anno::Annotation->new(name=>$gene->external_name,
                                       type=>'intron',
                                       position=>$pos);
      $group->add(annotation=>$anno);
    }
  }
  return $group;
}

sub _loadSimpleFeatures {
  my $self = shift;
  my ($slice,$group) = @_;
  my $features = $slice->get_all_SimpleFeatures();
  foreach my $feature (@$features) {
    $feature = $feature->transform('chromosome');
    my $left = $feature->start;
    my $right = $feature->end;
    Ensembl::fixCoords(leftr=>\$left,rightr=>\$right);
    my $pos = Seq::Position->new($group->position->chrom,$left,$right);
    my $name = $feature->display_label || 'SimpleFeature';
    my $anno = Anno::Annotation->new(name=>$name,
                                     type=>$feature->analysis->display_label,
                                     position=>$pos);
    $group->add(annotation=>$anno);
  }
}

sub fetchAnnotations {
  my $self = shift;
  my %args = @_;
  if (!defined $args{group}) {
    get_logger()->warn("AnnotationServer: no group/position provided!");
    return undef;
  }
  my $group = $args{group};
  my $pos = $group->position;
  my $chrEns = Ensembl::chrom2ensembl(chrom=>$pos->chrom);
  my $slice = $self->{slicead}->fetch_by_region('toplevel',$chrEns,
                                                           $pos->left,
                                                           $pos->right);
  if (!defined $slice) {
    my $left = $pos->left;
    my $right = $pos->right;
    get_logger()->warn("AnnotationServer: no slice for $chrEns:$left-$right");
    return undef;
  } else {
    $self->_loadRepeats($slice,$group);
    $self->_loadExons($slice,$group);
    $self->_loadSimpleFeatures($slice,$group);
  }
  return $group;
}

1
