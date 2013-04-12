#!/usr/bin/perl
# vim: ts=2 sw=2 sts=2 noexpandtab

use warnings;
use strict;
use lib qw(../lib);

# Demonstrate a very simple readline console.

{
	package REPLConsole;
	use Moose;
	extends 'Reflex::Base';
	use Reflex::POE::Wheel::ReadLine;
	use Reflex::Trait::Watched qw(watches);

	watches term => (
		isa => 'Reflex::POE::Wheel::ReadLine',
		setup => {},
	);

	sub BUILD {
		my ($self) = @_;
		$self->term->put( $x );
		$self->term->put($self->term->wheel->rl_poe_wheel_debug);
		$self->term->put('This is a very simple Perl REPL.');
		$self->term->put('Use Ctrl-D or type "exit" to quit.');
		$self->term->get('eval> ');
	}

	sub on_term_input {
		my ($self, $event) = @_;

		if ($event->exception // '' eq 'eot') {
			$self->term->put('Exiting.');
			return;
		}
		elsif (defined $event->input) {
			my $result = eval $event->input;
			$self->term->put($result);
		}

		$self->term->get('eval> ');
	}
}

exit REPLConsole->new->run_all;
