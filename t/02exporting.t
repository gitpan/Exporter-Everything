use Test::More tests => 66;

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

BEGIN {
	package Local::Importer1;
	use Local::Exporter qw(a C _p _R);
	use constant SHOULD     => qw(a C _p _R);
	use constant SHOULD_NOT => qw(b D _q _S __w __x __Y __Z import);
	no thanks;
}

BEGIN {
	package Local::Importer2;
	use Local::Exporter;
	use constant SHOULD     => qw(a b C D);
	use constant SHOULD_NOT => qw(_p _q _R _S __w __x __Y __Z import);
	no thanks;
}

BEGIN {
	package Local::Importer3;
	use Local::Exporter -const;
	use constant SHOULD     => qw(C D);
	use constant SHOULD_NOT => qw(a b _p _q _R _S __w __x __Y __Z import);
	no thanks;
}

BEGIN {
	package Local::Importer4;
	use Local::Exporter -default, '_p' => { -as => 'P'};
	use constant SHOULD     => qw(a b C D P);
	use constant SHOULD_NOT => qw(_p _q _R _S __w __x __Y __Z import);
	no thanks;
}

for my $class ('Local::Exporter') {
	for my $f ($class->_SHOULD)
	{
		my ($letter) = map { +lc } ($f =~ /([A-Z])/i);
		ok($class->can($f) && $class->$f eq $letter, "'$class' defines '$f' properly");
	}
	for my $f ($class->_SHOULD_NOT)
	{
		ok(!$class->can($f), "'$class' does not define '$f'");
	}
}

for my $n (1 .. 4)
{
	my $class = "Local::Importer$n";
	for my $f ($class->SHOULD)
	{
		my ($letter) = map { +lc } ($f =~ /([A-Z])/i);
		ok($class->can($f) && $class->$f eq $letter, "'$class' imports '$f' properly");
	}
	for my $f ($class->SHOULD_NOT)
	{
		ok(!$class->can($f), "'$class' does not import '$f'");
	}
}
