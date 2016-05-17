package Synteny::SyntenyAln;

use strict; use warnings;
use Log::Log4perl qw(get_logger);
use Data::Dumper;
use Synteny::AlignedBlock;

use Util;

@Synteny::SyntenyAln::ISA = qw(Synteny::Synteny);

sub init {
  my $self = shift;
  $self->{slice_adaptor} = $self->{registry}->get_adaptor($Ensembl::genome->{$self->{root}},"core","Slice");
  $self->{align_adaptor} = $self->{registry}->get_adaptor("Multi",
                                                          "compara",
                                                          "AlignSlice");
  $self->{gab_adaptor} = $self->{registry}->get_adaptor("Multi",
                                                        "compara",
                                                        "GenomicAlignBlock");
}

sub overlaps {
  my $self = shift;
  my ($lefta,$righta,$leftb,$rightb) = @_;
  if ($leftb == $rightb + 1) {
    return 0;
  }
  if ($lefta > $righta) {
    get_logger()->warn("lefta > righta: $lefta > $righta");
  }
  if ($leftb > $rightb) {
    get_logger()->warn("leftb > rightb: $leftb > $rightb");
  }
  my $left = Util::max($lefta,$leftb);
  my $right = Util::min($righta,$rightb);
  return $right - $left >= 1;
}

sub getRegions {
  my $self = shift;
  my ($genome,$chrom,$left,$right,$strand,$fa,$seqname) = @_;
  if ($strand eq '-') {
    $fa = Util::revcomp(seq=>$fa);
  }
  if (!defined($self->{mlss})) {
    get_logger()->warn("Cannot look up regions for '$genome': '$chrom'; mlss is null");
    return;
  }
  my $slice = $self->{slice_adaptor}->fetch_by_region("toplevel",$chrom,$left+1,$right);
  if (!defined $slice) {
    get_logger()->error("No slice for chr='$chrom':$left-$right");
    return [];
  }
  my $gn = $genome->name . "--" . $genome->assembly;
  #get_logger()->info("incoming:\t$gn\t$chrom\t$left\t$right");
  my $sseq = $slice->seq;
  if (uc $sseq ne uc $fa) {
    print "WARNING: FA <-> Genome mismatch\n";
    print sprintf("%s:%d-%d %s\n%s\n%s\n\n",$chrom,$left,$right,$strand,$sseq,$fa);
  }
  my $blocks = $self->{gab_adaptor}->fetch_all_by_MethodLinkSpeciesSet_Slice($self->{mlss},$slice);
  my $blockset = [];
  foreach my $block (@$blocks) {
    my ($oldstart,$oldend,$oldlen);
    my $alnsorig = $block->get_all_GenomicAligns();
    my %origset = ();
    foreach my $aln (@$alnsorig) {
#      print Dumper($aln);
      my $taxid = $aln->genome_db->taxon_id;
      if (exists $self->{taxids}->{$taxid}) {
        if (exists $origset{$aln->dbID}) {
          get_logger()->error("Found duplicate taxa in alignment for id $taxid, $seqname");
        }
        $origset{$aln->dbID} = $aln;
      } else {
        #my $id = $aln->dbID;
        #get_logger()->warn("Failed to find taxid $taxid for id $id");
      }
    }

    my $newblock = $block->restrict_between_reference_positions($left+1,$right);
#    my $newblock = $block;
    if (!defined $newblock) {
      get_logger()->error("Empty 'newblock', quitting.");
      exit(-1);
    }
    my $alns = $newblock->get_all_GenomicAligns();
#    print Dumper($alns);
    my $nblock = {};
    my $foundHome = 0;
    foreach my $aln (@$alns) {
      my $taxid = $aln->genome_db->taxon_id;
      if ($aln->genome_db == $genome && $self->overlaps($left,$right,$aln->dnafrag_start,$aln->dnafrag_end)) {
#        print sprintf("%s: %s:%d-%d  frag: %d-%d\n",$seqname,$chrom,$left,$right, $aln->dnafrag_start,$aln->dnafrag_end);
        my $raw = $aln->original_sequence;
        my $start = $aln->dnafrag_start;
        my $frag;
        if ($left+1 > $start) {
          my $rlen = length($raw);
          my $lend = $left - $start + 1;
          my $rlen2 = $right - $left;
          get_logger()->warn("len(raw) = $rlen, (l=$lend, r=$rlen2)");
          get_logger()->warn($raw);
          get_logger()->warn($fa);
          $frag = substr($raw,$left - $start + 1,$right-$left);
          get_logger()->warn($frag);
        } else {
          $frag = '-' x ($start - $left - 1) . substr($raw,0,$right-$start+1);
        }
        if (length($frag) < length($fa)) {
          $frag = $frag . ('-' x (length($fa) - length($frag)));
        }
#        print sprintf("compare:\nfa: %s\ngn: %s\n\n",$fa,$frag);
        $foundHome = 1;
      }
      if (exists $self->{taxids}->{$taxid}) {
        $nblock->{$taxid} = Synteny::AlignedBlock->fromGAB($aln);
        my $origid = $aln->{original_dbID};
        if (!defined $origid) {
          $origid = $aln->dbID;
        }
        if (exists $origset{$origid}) {
          my $oaln = $origset{$origid};
          $nblock->{$taxid}->setOrigCoords($oaln->dnafrag_start,$oaln->dnafrag_end);
        } else {
          get_logger()->error("Cannot find orig id $origid, alas.");
        }
#        print $block->{$taxid},"\n";
      }
    }
    if ($foundHome == 0) {
      get_logger()->error("Didn't find home.");
    }
    push @$blockset, $nblock;
  }
#  print "\n";
  return $blockset;
}

sub getRegionsList {
  my $self = shift;
  my ($genome,$chrom,$left,$right,$strand,$fa,$seqname) = @_;
  if ($strand eq '-') {
    $fa = Util::revcomp(seq=>$fa);
  }
  if (!defined($self->{mlss})) {
    get_logger()->warn("Cannot look up regions for '$genome': '$chrom'; mlss is null");
    return;
  }
  my $slice = $self->{slice_adaptor}->fetch_by_region("toplevel",$chrom,$left+1,$right);
  if (!defined $slice) {
    get_logger()->error("No slice for chr='$chrom':$left-$right");
    return [];
  }
  my $gn = $genome->name . "--" . $genome->assembly;
  #get_logger()->info("incoming:\t$gn\t$chrom\t$left\t$right");
  my $sseq = $slice->seq;
  if (uc $sseq ne uc $fa) {
    print "WARNING: FA <-> Genome mismatch\n";
    print sprintf("%s:%d-%d %s\n%s\n%s\n\n",$chrom,$left,$right,$strand,$sseq,$fa);
  }
  my $blocks = $self->{gab_adaptor}->fetch_all_by_MethodLinkSpeciesSet_Slice($self->{mlss},$slice);
  my $blockset = [];
  foreach my $block (@$blocks) {
    my ($oldstart,$oldend,$oldlen);
    my $alnsorig = $block->get_all_GenomicAligns();
    my %origset = ();
    foreach my $aln (@$alnsorig) {
#      print Dumper($aln);
      my $taxid = $aln->genome_db->taxon_id;
      if (exists $self->{taxids}->{$taxid}) {
        $origset{$aln->dbID} = $aln;
      } else {
        #my $id = $aln->dbID;
        #get_logger()->warn("Failed to find taxid $taxid for id $id");
      }
    }

    my $newblock = $block->restrict_between_reference_positions($left+1,$right);
#    my $newblock = $block;
    if (!defined $newblock) {
      get_logger()->error("Empty 'newblock', quitting.");
      exit(-1);
    }
    my $alns = $newblock->get_all_GenomicAligns();
#    print Dumper($alns);
    my $nblock = [];
    my $foundHome = 0;
    foreach my $aln (@$alns) {
      my $taxid = $aln->genome_db->taxon_id;
      if ($aln->genome_db == $genome && $self->overlaps($left,$right,$aln->dnafrag_start,$aln->dnafrag_end)) {
#        print sprintf("%s: %s:%d-%d  frag: %d-%d\n",$seqname,$chrom,$left,$right, $aln->dnafrag_start,$aln->dnafrag_end);
        my $raw = $aln->original_sequence;
        my $start = $aln->dnafrag_start;
        my $frag;
        if ($left+1 > $start) {
          my $rlen = length($raw);
          my $lend = $left - $start + 1;
          my $rlen2 = $right - $left;
          get_logger()->warn("len(raw) = $rlen, (l=$lend, r=$rlen2)");
          get_logger()->warn($raw);
          get_logger()->warn($fa);
          $frag = substr($raw,$left - $start + 1,$right-$left);
          get_logger()->warn($frag);
        } else {
          $frag = '-' x ($start - $left - 1) . substr($raw,0,$right-$start+1);
        }
        if (length($frag) < length($fa)) {
          $frag = $frag . ('-' x (length($fa) - length($frag)));
        }
#        print sprintf("compare:\nfa: %s\ngn: %s\n\n",$fa,$frag);
        $foundHome = 1;
      }
      if (exists $self->{taxids}->{$taxid}) {
        my $bl = Synteny::AlignedBlock->fromGAB($aln);
        push @$nblock,$bl;
        my $origid = $aln->{original_dbID};
        if (!defined $origid) {
          $origid = $aln->dbID;
        }
        if (exists $origset{$origid}) {
          my $oaln = $origset{$origid};
          $bl->setOrigCoords($oaln->dnafrag_start,$oaln->dnafrag_end);
        } else {
          get_logger()->error("Cannot find orig id $origid, alas.");
        }
#        print $block->{$taxid},"\n";
      }
    }
    if ($foundHome == 0) {
      get_logger()->error("Didn't find home.");
    }
    push @$blockset, $nblock;
  }
#  print "\n";
  return $blockset;
}

sub countRegions {
  my $self = shift;
  my ($genome,$chrom,$left,$right) = @_;
  my $slice = $self->{slice_adaptor}->fetch_by_region("toplevel",$chrom,$left,$right);
  my $blocks = $self->{gab_adaptor}->fetch_all_by_MethodLinkSpeciesSet_Slice($self->{mlss},$slice);
  return scalar @$blocks;
}

sub countCoverage {
  my $self = shift;
  my $bset = $self->{gab_adaptor}->fetch_all_by_MethodLinkSpeciesSet($self->{mlss});
  my $cov = 0;
  my $bcount;
  my $i;
  my $taxa = {};
  $bcount = scalar @$bset;
  print "blocks: ",$bcount,"\n";

  for ($i=0;$i<$bcount;$i++) {
    print sprintf("%06d\r",$i);
    my $alnsorig = $bset->[$i]->get_all_GenomicAligns();
    for my $aln (@$alnsorig) {
      my $gid = $aln->genome_db->taxon_id;
      my $len = $aln->dnafrag_end - $aln->dnafrag_start;
      if (!defined $taxa->{$gid}) {
        $taxa->{$gid} = 0;
      }
      $taxa->{$gid} += $len;
    }
  }
  return $taxa;
}

1
