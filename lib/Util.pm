package Util;

=head1 NAME

Util -- miscellaneous utility functions.

=head1 SYNOPSIS

  Util::log_init(level=>$WARN,config=>"/home/brown22/etc/Log4perl.conf");

  my $x = Util::max(4,2,1);
  my $x = Util::min(4,2,1);
  my $x = Util::sum(4,2,1);
  my $seq = Util::revcomp($seq);

=head1 DESCRIPTION

Odds and ends of utilities which are used multiple places, but don't belong
to any particular package.

=cut

use strict; use warnings;
use Carp;
use Log::Log4perl qw(get_logger);
use Scalar::Util qw(looks_like_number);
use Conf;

=head2 log_init

 Args: C<level>  -- Log4perl log level to use (default in Conf.pm)
       C<config> -- location of logging config file (default in Conf.pm)

 Description: initializes the logging system.

 Returntype: none

=cut

sub log_init {
  my %args = (level=>$Conf::LOGGER_DEFAULT_LEVEL,
              config=>$Conf::LOGGER_CONFIG_FILE,
              @_);
  Log::Log4perl->init($args{config});
  get_logger("")->level($args{level});
}

=head2 revcomp

 Args: C<seq> -- a string to reverse-complement

 Description: Reverse complements a string.  Does not currently handle
              IUPAC ambiguity codes.

 Returntype: string

=cut

sub revcomp {
  my %args = @_;
  Util::checkArgs(args=>\%args,req=>['seq']);
  my $seq = $args{seq};
  $seq = reverse($seq);
  $seq =~ tr/ACGTacgt/TGCAtgca/;
  return $seq;
}

=head2 sum

 Args: C<nums> -- zero or more numbers

 Description: Computes the sum of a list of numbers.  Non-numbers are skipped,
              with a warning.  Returns 0 if no arguments are provided.

 Returntype: number

=cut

sub sum {
  my $s = 0;
  foreach my $i (@_) {
    if (looks_like_number $i) {
      $s += $i;
    } else {
      get_logger()->warn("Skipping non-number '$i' in sum");
    }
  }
  return $s;
}

=head2 max

 Args: C<nums> -- zero or more numbers

 Description: Computes the max of a list of numbers.  Non-numbers are skipped,
              with a warning.  Returns undef if no numbers are provided.

 Returntype: number

=cut

sub max {
  my $num = -1000000000000;
  foreach my $nn (@_) {
    if (looks_like_number $nn) {
      if ($nn > $num) {
        $num = $nn;
      }
    } else {
      get_logger()->warn("Skipping non-number '$nn' in max");
    }
  }
  if ($num == -1000000000000) {
    $num = undef;
  }
  return $num;
}

=head2 min

 Args: C<nums> -- zero or more numbers

 Description: Computes the min of a list of numbers.  Non-numbers are skipped,
              with a warning.  Returns undef if no numbers are provided.

 Returntype: number

=cut

sub min {
  my $num = 1000000000000;
  foreach my $nn (@_) {
    if (looks_like_number $nn) {
      if ($nn < $num) {
        $num = $nn;
      }
    } else {
      get_logger()->warn("Skipping non-number '$nn' in max");
    }
  }
  if ($num == 1000000000000) {
    $num = undef;
  }
  return $num;
}

=head2 checkArgs

 Args: args -- the argument hash passed into the function
       req -- list of required arguments

 Description: Checks to see if all required args exist in the args list.
              Complains about any missing ones, and dies if there are any
              missing.

              Let me say that again: the function DOES NOT RETURN if an
              argument is missing; instead it dies verbosely (and hopefully
              informatively).

 Returntype: none

=cut

sub checkArgs {
  my %args = @_;
  if (!defined $args{args} || !defined $args{req}) {
    get_logger()->error("Missing 'args' or 'req' arguments to checkArgs, crashing at ");
    confess "Missing 'args' or 'req' arguments to checkArgs";
  }
  my @missing = ();
  foreach my $r (@{$args{req}}) {
    if (!exists $args{args}->{$r}) {
      push @missing, $r;
    }
  }
  if (scalar @missing > 0) {
    my $msg = "Missing required arguments: ".join(",",@missing);
    get_logger()->error($msg);
    confess $msg;
  }
}

1
