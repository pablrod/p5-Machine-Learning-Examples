#!/usr/bin/env perl 

use strict;
use warnings;
use utf8;
use 5.010;

use Data::Dataset::Classic::Iris;
use HTML::Show;

my $iris = Data::Dataset::Classic::Iris::get(as => 'Data::Table');

my ($train_dataset, $test_dataset) = SplitDataSetTrainAndTest($iris, 'species');

my $problem = $test_dataset->clone();
my $species = $problem->delCol('species');

my $result = Predict($problem);
$problem->addCol($result, "kNN Classified");
$problem->addCol($species, 'Species');

HTML::Show::show($problem->html);

sub SplitDataSetTrainAndTest {
    my ($dataset, $column_name) = @_;
    
    my $rows_for_test = [];
    $dataset->each_group([$column_name], sub {
        my ($group_table, $rows_id) = @_;
        push @$rows_for_test, $rows_id->[0];
    });
    my $test_dataset = $dataset->subTable($rows_for_test);
    $dataset->delRows($rows_for_test);
    return ($dataset, $test_dataset);
}

sub Predict {
    my ($problem_dataset) = @_;
    my $k = 3;
    my $next_problem = $problem_dataset->iterator();
    my $result = [];
    while (my $problem = $next_problem->()) {
        my $k_nearest = GetkNN($k, $train_dataset, $problem);
        # Vote counting
        my $votes = {};
        for my $neighbour (@$k_nearest) {
            $votes->{$train_dataset->elm($neighbour->[1], 'species')} += 1;
        }
        my ($most_voted) = map {$_->[1]} sort {$b->[0] <=> $a->[0]} map {[$votes->{$_}, $_]} keys %$votes;
        push @$result, $most_voted;
    }
    return $result;
}

sub GetkNN {
    my ($k, $dataset, $problem) = @_;
    my $next_data = $dataset->iterator();
    my $distance_index = [];
    while (my $data = $next_data->()) {
        my $distance = 0;
        for my $dimension (keys %$problem) {
            $distance += ($problem->{$dimension} - $data->{$dimension})**2;
        }
        push @$distance_index, [$distance, $next_data->(1)];
    }
    @$distance_index = sort {$a->[0] <=> $b->[0]} @$distance_index;

    return [@{$distance_index}[0.. ($k - 1)]];
}

