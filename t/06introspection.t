use Test::More tests => 7;

BEGIN {
	package Local::Exporter;
	use Exporter::Everything;
	sub _build_foo {
		my ($class, $name, $arg) = @_;
		return sub { $arg->{'foobar'} || 'FOOBAR' };
	}
	sub bar {
		42;
	}
	sub _build__quux {
		my ($class, $name, $arg) = @_;
		return sub { $arg->{'quux'} || 'QUUX' };
	}
	sub __flibble {
		17;
	}
	no thanks;
}

# The introspection API is very limited at the moment!
my %exported = Local::Exporter->Exporter::Everything::exportable_subs;

ok(exists $exported{$_}, "exists \$exported{$_}") for qw( foo bar _quux );
ok(!exists $exported{$_}, "not exists \$exported{$_}") for qw( __flibble );
ok(ref $exported{$_} eq 'CODE', "ref \$exported{$_} eq 'CODE'") for qw( foo _quux );
ok(!defined $exported{$_}, "not defined \$exported{$_}") for qw( bar );

