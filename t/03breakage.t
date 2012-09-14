use Test::More tests => 8;
use Test::Exception;

BEGIN {
	package Local::Exporter::Other;
	use Exporter::Everything;
	sub a { 'a' }
	no thanks;
}

BEGIN {
	package Local::Exporter;
	use Exporter::Everything;
	# don't want to export these constants, give them underscores!
	use constant _SHOULD     => qw(a b C D _p _q _R _S __w __x __Y __Z);
	use constant _SHOULD_NOT => qw(break);
	use Local::Exporter::Other;
	sub b { 'b' }
	sub C { 'c' }
	sub D { 'd' }
	sub _p { 'p' }
	sub _q { 'q' }
	sub _R { 'r' }
	sub _S { 's' }
	sub __w { 'w' }
	sub __x { 'x' }
	sub __Y { 'y' }
	sub __Z { 'z' }
	no thanks;
}

for my $f (qw( __w __x __Y __Z these do not exist ))
{
	throws_ok { Local::Exporter->import($f) }
	qr        {is not exported by the Local::Exporter module};
}
