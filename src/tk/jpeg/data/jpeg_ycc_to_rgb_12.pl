#!/usr/bin/perl
use strict;

sub fix
{
	return int((shift)*(1 << 16) + 0.5);
}

my @v = ([ fix(1.40200), 1 << 15],	# red(v)
			[ fix(1.77200), 1 << 15],	# blue(u)
			[-fix(0.34414), 1 << 15],	# green(u)
			[-fix(0.71414), 0      ]);	# green(u)

my $max_sample = 1 << 12;

foreach my $c (@v) {
	print "{";

	my $f = $c->[0];
	my $k = $c->[1];

	for (my $x = -$max_sample/2; $x < $max_sample/2; ++$x) {
		printf(($x + $max_sample) % 8 == 0 ? "\n\t" : " ");
		printf("%10d,%s", int($f*$x + $k));
	}

	print "\n},\n";
}
