package Conf;

=head1 NAME

Conf -- odds and ends of configuration constants.

=head1 SYNOPSIS

 $x = $Conf::LOGGER_CONFIG_FILE;

=head1 DESCRIPTION

This is just a central location to store configuration defaults.

=cut

use Log::Log4perl qw(:levels);
use vars qw($LOGGER_CONFIG_FILE $LOGGER_DEFAULT_LEVEL
            $ENSEMBL_HOST $ENSEMBL_USER $ENSEMBL_PASS);

$LOGGER_CONFIG_FILE = "/away/brown22/etc/Log4perl.conf";
$LOGGER_DEFAULT_LEVEL = $INFO;

#$ENSEMBL_HOST = 'morangie';
#$ENSEMBL_USER = 'ensembl';
#$ENSEMBL_PASS = 'ensembl';

$ENSEMBL_HOST = 'ensembldb.ensembl.org';
$ENSEMBL_USER = 'anonymous';
$ENSEMBL_PASS = undef;

1
