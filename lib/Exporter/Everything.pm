package Exporter::Everything;

use 5.008;
use strict qw(vars subs);
use warnings FATAL => 'all';
no warnings qw(void once uninitialized);

BEGIN {
	$Exporter::Everything::AUTHORITY = 'cpan:TOBYINK';
	$Exporter::Everything::VERSION   = '0.001';
}

use Package::Stash  0 qw();
use Sub::Exporter   0 qw();
use Sub::Name       0 qw(subname);

sub import
{
	my $caller = caller;
	my $import = "$caller\::import";
	my $exporter;
	*$import = subname $import, sub {
		$exporter ||= Exporter::Everything::build_exporter($caller);
		goto $exporter;
	}
}

sub exportable_subs
{
	my $caller = shift;
	my $subs   = Package::Stash::->new($caller)->get_all_symbols('CODE');
	
	my %R;
	for (keys %$subs)
	{
		if (/^_build_(.+)$/) {
			$R{$1} ||= $subs->{$_};
		}
		elsif (lc $_ eq 'import') {
			# no
		}
		elsif (not /^_{2}/) {
			$R{$_} ||= undef;
		}
	}
	
	return %R;
}

sub build_exporter
{
	my %subs  = exportable_subs( @_ ? $_[0] : caller );
	
	return Sub::Exporter::build_exporter({
		exports    => [ %subs ],
		groups     => {
			default  => [ grep { not /^_/ } keys %subs ],
			const    => [ grep { /^[A-Z]([A-Z0-9_]*[A-Z0-9])?$/ } keys %subs ],
		}
	});
}

'won';

__END__

=head1 NAME

Exporter::Everything - just export everything

=head1 SYNOPSIS

   package My::Utils;
   use Exporter::Everything;
   sub foo { ... }
   sub bar { ... }
   sub baz { ... }
   1;

   package My::Script;
   use My::Utils;
   if ( foo() ) {
      bar();
   }
   else {
      baz();
   }

=head1 DESCRIPTION

L<Exporter>, L<Sub::Exporter> and so on make it pretty easy to export
subs from your package into the caller package. But not as easy as
Exporter::Everything!

Just C<< use Exporter::Everything >> and suddenly your package will be
able to export everything.

=head1 FAQ

=head2 What is exported by default?

Everything except functions which start with an underscore.

(Also, your C<import> method itself is not exported.)

=head2 Isn't that a little dumb?

A I<little>?!

=head2 But I have some helper functions I don't want to export.

If you name a function with a leading underscore then it is not exported by
default. Your caller can still request it explicitly:

   use My::Utils '_helper';

=head2 But it really, really shouldn't be exported I<at all>!

OK, name it with two leading underscores then. But you should be aware that
your caller will still be able to call that sub using its package-qualified
name. If you really don't want anybody else calling it, make it a lexical
sub.

=head2 What if I import functions like L<Scalar::Util> C<blessed> and don't want to re-export them.

Then clean up your namespace with something like C<namespace::autoclean>.

=head2 I need cool features like Exporter.pm's tags, or Sub::Exporter's generators.

Exporter::Everything sets up three tags for you automatically:

=over

=item * C<-default> 

All public functions (i.e. those without a leading underscore).

=item * C<-all>

All public and helper functions (i.e. those with zero or one leading underscore).

=item * C<-const>

All functions with names matching C<< /^[A-Z]([A-Z0-9_]*[A-Z0-9])?$/ >>.
The assumption is that these are "constants".

=back

But there is not currently any facility to define your own tags.

You can create a generated sub C<foo> by naming your generator C<_build_foo>.
You can safely define both C<foo> and C<_build_foo>. When people import your
sub, they'll get the generated version.

Exporter::Everything uses Sub::Exporter behind the scenes, so the caller-side
features of Sub::Exporter (such as the ability to rename imported subs)
should just work.

If you need any other fancy Sub::Exporter features (e.g. collectors, custom
installers, etc), then you're out of luck.

=head2 I need to do some other fancy stuff in my C<import> method.

=begin trustme

=item build_exporter

=end trustme

OK...

   sub import
   {
      my ($class, @args) = @_;  # copy @_, don't alter it!
      
      ...;
      
      require Exporter::Everything;
      state $exporter = $class->Exporter::Everything::build_exporter;
      goto $exporter;
   }

=head2 How can I know what subs my package exports?

=begin trustme

=item exportable_subs

=end trustme

Exporter::Everything provides a tiny bit of introspection.

   my %exported = My::Utils->Exporter::Everything::exportable_subs;

The C<< %exported >> hash has sub names as keys, and generator coderefs
as values (or undef when there is no generator).

=head2 Add Perl 5.6 support!

I<You> add Perl 5.6 support!

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=Exporter-Everything>.

=head1 SEE ALSO

L<Sub::Exporter>, L<namespace::clean>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2012 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

