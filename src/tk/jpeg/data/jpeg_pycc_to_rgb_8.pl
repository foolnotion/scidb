#!/usr/bin/perl
use strict;

sub fix
{
	return int((shift)*(1 << 16) + 0.5);
}

my @v = ([ fix(1.3584),        0,   1 << 15],	# L(y)
			[ fix(1.8215),       -137, 0      ],	# R(v)
			[ fix(2.2179),       -156, 0      ],	# B(u)
			[-fix(0.509*1.8215), -137, 0      ],	# G(v)
			[-fix(0.194*2.2179), -156, 0      ]);	# G(u)

my $max_sample = 1 << 8;

foreach my $c (@v) {
	print "{";

	my $f = $c->[0];
	my $k = $c->[1];
	my $h = $c->[2];

	for (my $x = -$max_sample/2; $x < $max_sample/2; ++$x) {
		printf(($x + $max_sample) % 8 == 0 ? "\n\t" : " ");
		printf("%9d,%s", int($f*($x + $k) + $h));
	}

	print "\n},\n";
}
