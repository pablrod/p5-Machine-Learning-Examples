#!/usr/bin/env perl 
use strict;
use warnings;
use utf8;
use 5.020;
use HTML::Show;
use aliased 'Chart::Plotly::Plot';
use aliased 'Chart::Plotly::Trace::Scatter';
use List::Util;
use PDL;
use PDL::Fit::Linfit;
use feature 'signatures';
no warnings qw(experimental::signatures);

my $number_of_points = 20;
my $x = [ 1 .. $number_of_points ];
my $y = [ map { $_ + 0.2 * NormalRandomNumber() } @$x ];# Noise 
my $yfit = FitLine($x, $y);# Model: y = ax

my $points = Scatter->new( x => $x, y => $y, mode => 'markers', name => 'Observations' );
my $model = Scatter->new( x => $x, y => $yfit, name => 'Model' );
my $plot = Plot->new( traces => [ $points, $model ] );
HTML::Show::show($plot->html);

sub NormalRandomNumber {
 return (grandom(1)->unpdl())->[0];
}

sub FitLine($x, $y) {
 my $fit = linfit1d pdl($y), cat pdl($x);
 return $fit->unpdl;
}

