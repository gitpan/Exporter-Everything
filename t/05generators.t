use Test::More tests => 9;

BEGIN {
	package Local::Exporter;
	use Exporter::Everything;
	sub _build_foo {
		my ($class, $name, $arg) = @_;
		return sub { $arg->{'foobar'} || 'FOOBAR' };
	}
	sub _build__quux {
		my ($class, $name, $arg) = @_;
		return sub { $arg->{'quux'} || 'QUUX' };
	}
	no thanks;
}

BEGIN {
	package Local::Importer1;
	use Local::Exporter;
	no thanks;
}

BEGIN {
	package Local::Importer2;
	use Local::Exporter (
		foo     => { foobar => 'Foo1' },
		_quux   => { quux => 'Quux1', -as => 'quux' },
	);
	no thanks;
}

can_ok('Local::Importer1', 'foo');
is(Local::Importer1->foo, 'FOOBAR', "Local::Importer1->foo works ok");

ok(!Local::Importer1->can('_quux'), "Local::Importer1 can't '_quux'");
ok(!Local::Importer1->can('quux'), "Local::Importer1 can't 'quux'");

can_ok('Local::Importer2', 'foo');
is(Local::Importer2->foo, 'Foo1', "Local::Importer2->foo works ok");

ok(!Local::Importer2->can('_quux'), "Local::Importer2 can't '_quux'");

can_ok('Local::Importer2', 'quux');
is(Local::Importer2->quux, 'Quux1', "Local::Importer2->quux works ok");
