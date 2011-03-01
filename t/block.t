#!/usr/bin/perl

=head1 NAME

  block.t
  A piece of code to test the R::YapRI::Block module

=cut

=head1 SYNOPSIS

 perl block.t
 prove block.t

=head1 DESCRIPTION

 Test R::YapRI::Block module

=cut

=head1 AUTHORS

 Aureliano Bombarely Gomez
 (ab782@cornell.edu)

=cut

use strict;
use warnings;
use autodie;

use Data::Dumper;
use Test::More;
use Test::Exception;
use Test::Warn;

use File::stat;
use File::Spec;
use Image::Size;
use Cwd;

use FindBin;
use lib "$FindBin::Bin/../lib";


## Before run any test it will check if R is available

BEGIN {
    my $r;
    if (defined $ENV{RBASE}) {
	$r = $ENV{RBASE};
    }
    else {
	my $path = $ENV{PATH};
	if (defined $path) {
	    my @paths = split(/:/, $path);
	    foreach my $p (@paths) {
		if ($^O =~ m/MSWin32/) {
		    my $wfile = File::Spec->catfile($p, 'Rterm.exe');
		    if (-e $wfile) {
			$r = $wfile;
		    }
		}
		else {
		    my $ufile = File::Spec->catfile($p, 'R');
		    if (-e $ufile) {
			$r = $ufile;
		    }
		}
	    }
	}
    }

    ## Now it will plan or skip the test

    unless (defined $r) {
	plan skip_all => "No R path was found in PATH or RBASE. Aborting test.";
    }

    plan tests => 14;
}


## TEST 1 and 2

BEGIN {
    use_ok('R::YapRI::Base');
    use_ok('R::YapRI::Block');
}

## Add the object created to an array to clean them at the end of the script

my @rbase_objs = ();

## Create an empty object and test the possible die functions. 

my $rbase0 = R::YapRI::Base->new();
push @rbase_objs, $rbase0;

## Create a new block, TEST 3 to 6

my $rblock0 = R::YapRI::Block->new($rbase0, 'BLOCK0');

is(ref($rblock0), 'R::YapRI::Block', 
    "Testing new(), checking object identity")
    or diag("Looks like this has failed");

throws_ok { R::YapRI::Block->new() } qr/ARG. ERROR: No rbase object/, 
    'TESTING DIE ERROR when no rbase object was supplied to new()';

throws_ok { R::YapRI::Block->new($rbase0) } qr/ARG. ERROR: No blockname/, 
    'TESTING DIE ERROR when no blockname was supplied to new()';

throws_ok { R::YapRI::Block->new('fake', 'BLOCK1') } qr/ARG. ERROR: fake/, 
    'TESTING DIE ERROR when rbase supplied to new() isnt a rbase object';

## accessors, TEST 7 to 9

is(ref($rblock0->get_rbase()), 'R::YapRI::Base',
    "Testing get_rbase accessor, checking object identity")
    or diag("Looks like this has failed");

is($rblock0->get_blockname(), 'BLOCK0',
    "Testing get_blockname accessor, checking name")
    or diag("Looks like this has failed");

is($rblock0->get_command_file(), $rbase0->get_cmdfiles('BLOCK0'),
    "Testing get_command_file, checking command filename")
    or diag("Looks like this has failed");


## Test add/read_command, TEST 10 to 12

my $cmd0 = 'x <- c(1,2,3,4,5)';

$rblock0->add_command($cmd0);
my @cmds = $rblock0->read_commands();

is($cmds[0], $cmd0, 
    "Testing add/read_commands, checking command line")
    or diag("Looks like this has failed");

throws_ok { $rblock0->add_command() } qr/ERROR: No arg. was/, 
    'TESTING DIE ERROR when no arg. was supplied to add_command()';

throws_ok { $rblock0->add_command([]) } qr/ERROR: ARRAY/, 
    'TESTING DIE ERROR when arg. supplied to add_command() isnt scalar or href';


## Test run_command and get results, TEST 13 and 14

$rblock0->add_command({ mean => { 'x' => '' }});
$rblock0->run_block();

is($rblock0->get_result_file(), $rbase0->get_resultfiles('BLOCK0'), 
    "Testing get_result_file, checking result file")
    or diag("Looks like this has failed");

my @results = $rblock0->read_results();

is($results[0], '[1] 3',
    "Testing run_block/read_results, checking results")
    or diag("looks like this has failed");





##############################################################
## Finally it will clean the files produced during the test ##
##############################################################

foreach my $clean_rbase (@rbase_objs) {
    $clean_rbase->cleanup()
}
  
####
1; #
####
