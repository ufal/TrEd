#!/usr/bin/env perl
=head1 Automated installation of TrEd dependencies using CPAN script


Changelog:
	0.0.5 -- Alpha PPM support
	0.0.4 -- Added support for skipping tests during installation
	0.0.3 -- More sophisticated build & install parameters
	0.0.2 -- Rewrite to module instead of simple script

=head1 AUTHOR

Peter Fabian <peter.fabian1000@gmail.com>

=cut
package TRED::Dependencies::Install;

use strict;
use warnings;
use TRED::Dependencies::Config;
use version;
use IO::Handle;

use vars qw($VERSION);

our $VERSION = qv('0.0.5');

#TODO: use named args
sub new {
	my ($class, $install_base, $logfile_name) = @_;
	my $tred_install_config = TRED::Dependencies::Config->new();
	
	my $log_file;
	my $logfh;
	open($logfh, '>', $logfile_name) or die $!;
	
	$logfh->autoflush(1);
	STDOUT->autoflush(1);
	STDERR->autoflush(1);
	
	my $self = {
		'platform' 			=> $^O,
		'install_base'			=> $install_base,
		'logfh'				=> $logfh,
		'install_config'		=> $tred_install_config,
	};
	return bless($self, $class);
}


sub DESTROY {
	my ($self) = @_;
	close($self->{'logfh'});
}


1;

__END__