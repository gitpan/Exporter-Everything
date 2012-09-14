use Test::More;
use Test::Exception;

BEGIN {
	eval 'require namespace::clean; 1'
		or plan skip_all => "need namespace::clean for this test";
	plan tests => 9;
}

BEGIN {
	package Local::Exporter;
	use Scalar::Util qw(blessed);
	sub a { 'a' }
	use namespace::clean;
	use Exporter::Everything;
	use Scalar::Util qw(reftype);
	sub b { 'b' }
	no thanks;
}

BEGIN {
	package Local::Importer;
	use Local::Exporter;
	no thanks;
}

for my $class (qw(Local::Exporter Local::Importer))
{
	ok(!$class->can('blessed'), "$class cannot 'blessed'");
	ok(!$class->can('a'), "$class cannot 'a'");
	ok($class->can('reftype'), "$class can 'reftype'");
	ok($class->can('b'), "$class can 'b'");
}

throws_ok { Local::Exporter->import('a') }
qr        {is not exported by the Local::Exporter module};
