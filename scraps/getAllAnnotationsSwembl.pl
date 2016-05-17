#!/usr/bin/perl

use strict;
use AnnotationServer;
use Position;

my $species = $ARGV[0];
my $server = AnnotationServer->new(genome=>$species);

my (@fields,$slice,$trlink,$gene,@choices,@repchoices,$reps);
my ($name,$chrom,$start,$end,$types,$tmp);
my $hkey;
my (@gnames,$namestr);

my $count = 0;
open FD, $ARGV[1];
while (<FD>) {
  $count++;
  if ($count % 1000 == 0) {
    print STDERR $count,"\r";
  }
  if (substr($_,0,1) eq "#" || substr($_,0,6) eq "Region") {
    next;
  }
  @fields = split;
  $chrom = substr($fields[0],3);
  $start = $fields[1];
  $end = $fields[2];
  my $pos = Position->new(substr($fields[0],3),$fields[1],$fields[2]);
  my $annots = $server->fetchAnnotations(position=>$pos);
  my $first = 1;
  foreach my $annot (@$annots) {
    if ($first) {
      print sprintf("chr%s\t%d\t%d\t",$chrom,$start,$end);
      $first = 0;
    } else {
      print "\t\t\t";
    }
    print sprintf("chr%s\t%s\t%s\n",$annot->position->string(),
                                    $annot->type,
                                    $annot->name);
  }
}

print sprintf("count=%d\n",$count);

