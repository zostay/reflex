package Reflex::POE::Wheel::ReadLine;
# vim: ts=2 sw=2 sts=2 noexpandtab

use Moose;
extends 'Reflex::POE::Wheel';
use POE::Wheel::ReadLine;

use Reflex::Event::ReadLine;

has '+wheel' => (
	isa          => 'Maybe[POE::Wheel::ReadLine]',
	handles      => [ qw(
		add_history
		get_history
		write_history
		read_history
		history_truncate_file
		bind_key
		add_defun
		clear
		terminal_size
		get
		attribs
		option
	) ],
);

my %event_to_index = (
	InputEvent => 0,
);

sub events_to_indices {
	return \%event_to_index;
}

my @index_to_event = (
	[ 'Reflex::Event::ReadLine', 'input', 'exception', 'wheel_id' ],
);

sub index_to_event {
	my ($class, $index) = @_;
	return @{$index_to_event[$index]};
}

sub wheel_class {
	return 'POE::Wheel::ReadLine';
}

sub valid_params {
	return(
		{
			PutMode => 1,
			IdleTime => 1,
			AppName => 1,
		}
	);
}

__PACKAGE__->meta->make_immutable;

1;

=head1 NAME

Reflex::POE::Wheel::ReadLine - Represent POE::Wheel::ReadLine as a Reflex class.

=head1 SYNOPSIS

	#!perl
	
	package Console;
	use Moose;
	extends 'Reflex::Base';
	use Reflex::POE::Wheel::ReadLine;
	use Reflex::Trait::Wheel qw(watches);

	watches term => (
		isa => 'Reflex::POE::Wheel::ReadLine',
		setup => {},
  );

	sub BUILD {
		my ($self) = @_;
		$self->term->get('> ');
	}

  sub on_term_input {
		my ($self, $event) = @_;

		if ($event->input eq 'exit') {
			$self->term->put("Exiting.");
		}
		else {
			$self->term->put($event->input);
			$self->term->get("> ");
		}
	}

	Console->new->run_all;

=head1 DESCRIPTION

Reflex::POE::Wheel::ReadLine is built on L<POE::Wheel::ReadLine> to provide a non-blocking interactive console. It is nothing more than a wrapper around the POE package.

All the methods available on L<POE::Wheel::ReadLine> are delegated here, all the options to that class may be passed to the constructor. 

=head2 Public Methods

The methods of L<POE::Wheel::ReadLine> may all be called directly on this class, this includes. You may want to read the documentation there for more details.

=head3 add_history

Takes one or more lines to add to the terminal history.

=head3 get_history

Returns a list of lines in the terminal history.

=head3 write_history

Writes the lines stored in the terminal history to a file. It will use C<~/.history> by default or may be passed a file name to use instead. Returns a true value on success.

=head3 read_history

Reads the lines stored in a file on the disk into the history. It will read the entire contents of C<~/.history> into the terminal history. It may be passed a filename to use instead. It can also be used to only load a subset of the named history file by passing a line number start and end:

	sub BUILD {
		my ($self) = @_;
		$self->read_history('~/.history', 42, 84);
	}

The end line number may be omitted to read to the end of the file from given start line.

Returns a true value on success.

=head3 history_truncate_file

This method takes two parameters. The first is the name of the file to work on and the second is the maximum number of history lines permitted. If the number of lines in the named file exceeds the maximum number given, earlier lines in the file will be removed so that the line length of the file matches the maximum.

The filename and number of lines may be omitted. If omitted (or passed as C<undef>) the default is to truncate F<~/.history> to 100 lines.

Returns a true value on success.

=head3 bind_key

Takes the keybinding as the first argument and a name of a function to call when the bound key sequence is performed as the second. The keybinding may be a keystroke definition as shown in L<readline(3)>.

=head3 add_defun

Takes two parameters. The first is the name of the function and the second is a code reference to execute. These are the functions executed by the key sequences defined by L</bind_key>.

=head3 clear

Clear the terminal.

=head3 terminal_size

Returns a list of two integers that are the size L<POE::Wheel::ReadLine> believes the terminal to be. The first value is the number of columns and the second is the number of rows.

=head3 get

This puts a prompt on the terminal and causes POE to start listening for key strokes and input from the user. Until this is called, the terminal will not receive any input events.

Pass this method a string argument to set the prompt to display:

	sub BUILD {
		my ($self) = @_;
		$self->get("C:\> ");
	}

=head3 put

This puts a line of text on the terminal. You should use this rather than C<print> or C<say> to prevent text being written to the terminal becoming mangled or confusing.
	
=head3 attribs

Returns a reference to a hash of readline options. Use this to query or modify the behavior of the object.

=head3 option

Given the name of an option, this is used to return a single value from the hash returned by L</attribs>.

=head2 Public Events

This emits the same events as L<POE::Wheel::Readline>.

=head3 input

This is the name in Reflex for the POE object's InputEvent. The event object passed in defines three attributes:

=over

=item input

This is the line of input typed by the user.

=item exception

This is a special exception. It may be set to one of the following or not defined.

=over

=item cancel

This is sent has canceled a line of input, triggering the abort function, usually by pressing Ctrl-G.

=item eot

This is sent when the user has requested the terminal be closed, generally by pressing Ctrl-D.

=item interrupt

This is sent when the user has requested teh terminal interrupt the current work, usually by pressing Ctrl-C.

=back

=item wheel_id

Thisi s the L<POE::Wheel::ReadLine> object's wheel ID.

=back

=head1 SEE ALSO

L<Moose::Manual::Concepts

L<Reflex>
L<Reflex::POE::Event>
L<Reflex::POE::Postback>
L<Reflex::POE::Session>
L<Reflex::POE::Wheel>

L<Reflex/ACKNOWLEDGEMENTS>
L<Reflex/ASSISTANCE>
L<Reflex/AUTHORS>
L<Reflex/BUGS>
L<Reflex/CONTRIBUTORS>
L<Reflex/COPYRIGHT>
L<Reflex/LICENSE>
L<Reflex/TODO>

=cut
