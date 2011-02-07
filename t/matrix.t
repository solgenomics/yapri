#!/usr/bin/perl

=head1 NAME

  matrix.t
  A piece of code to test the YapRI::Data::Matrix module

=cut

=head1 SYNOPSIS

 perl matrix.t
 prove matrix.t

=head1 DESCRIPTION

 Test YapRI::Matrix module

=cut

=head1 AUTHORS

 Aureliano Bombarely Gomez
 (ab782@cornell.edu)

=cut

use strict;
use warnings;
use autodie;

use Data::Dumper;
use Test::More tests => 26;
use Test::Exception;
use Test::Warn;

use Cwd;

use FindBin;
use lib "$FindBin::Bin/../lib";

## TEST 1 and 2

BEGIN {
    use_ok('YapRI::Data::Matrix');
    use_ok('YapRI::Base')
}

## Add the object created to an array to clean them at the end of the script

my @rih_objs = ();

## First, create the empty object and check it, TEST 3 to 6

my $matrix0 = YapRI::Data::Matrix->new();

is(ref($matrix0), 'YapRI::Data::Matrix', 
    "testing new() for an empty object, checking object identity")
    or diag("Looks like this has failed");

throws_ok { YapRI::Data::Matrix->new('fake') } qr/ARGUMENT ERROR: Arg./, 
    'TESTING DIE ERROR when arg. supplied new() function is not hash ref.';

throws_ok { YapRI::Data::Matrix->new({fake => 1}) } qr/ARGUMENT ERROR: fake/, 
    'TESTING DIE ERROR when arg. key supplied new() function is not permited.';

throws_ok { YapRI::Data::Matrix->new({data => 1}) } qr/ARGUMENT ERROR: 1/, 
    'TESTING DIE ERROR when arg. val supplied new() function is not permited.';


#######################
## TESTING ACCESSORS ##
#######################

## name accessor, TEST 7 and 8

$matrix0->set_name('test0');

is($matrix0->get_name(), 'test0', 
    "testing get/set_name, checking name identity")
    or diag("Looks like this has failed");

throws_ok { $matrix0->set_name() } qr/ERROR: No defined name/, 
    'TESTING DIE ERROR when no arg. was supplied to set_name() function';

## coln accessor, TEST 9 to 11

$matrix0->set_coln(3);

is($matrix0->get_coln(), 3, 
    "testing get/set_coln, checking column number")
    or diag("Looks like this has failed");

throws_ok { $matrix0->set_coln() } qr/ERROR: No defined coln/, 
    'TESTING DIE ERROR when no arg. was supplied to set_coln() function';

throws_ok { $matrix0->set_coln('fake') } qr/ERROR: fake supplied/, 
    'TESTING DIE ERROR when arg. supplied to set_coln() function isnt digit';


## rown accessor, TEST 12 to 14

$matrix0->set_rown(2);

is($matrix0->get_rown(), 2, 
    "testing get/set_rown, checking row number")
    or diag("Looks like this has failed");

throws_ok { $matrix0->set_rown() } qr/ERROR: No defined rown/, 
    'TESTING DIE ERROR when no arg. was supplied to set_rown() function';

throws_ok { $matrix0->set_rown('fake') } qr/ERROR: fake supplied/, 
    'TESTING DIE ERROR when arg. supplied to set_rown() function isnt digit';


## colnames accessor, TEST 15 to 18

$matrix0->set_colnames([ 1, 2, 3]);
is(join(',', @{$matrix0->get_colnames()}), '1,2,3', 
    "testing get/set_colnames, checking column names")
    or diag("Looks like this has failed");

throws_ok { $matrix0->set_colnames() } qr/ERROR: No colname_aref/, 
    'TESTING DIE ERROR when no arg. was supplied to set_colnames() function';

throws_ok { $matrix0->set_colnames('fake') } qr/ERROR: fake supplied/, 
    'TESTING DIE ERROR when arg. supplied to set_colnames() isnt ARAYREF';

throws_ok { $matrix0->set_colnames([1, 2]) } qr/ERROR: Different number/, 
    'TESTING DIE ERROR when arg. supplied to set_colnames() has diff. coln';


## rownames accessor, TEST 19 to 22

$matrix0->set_rownames([ 'A', 'B']);
is(join(',', @{$matrix0->get_rownames()}), 'A,B', 
    "testing get/set_rownames, checking row names")
    or diag("Looks like this has failed");

throws_ok { $matrix0->set_rownames() } qr/ERROR: No rowname_aref/, 
    'TESTING DIE ERROR when no arg. was supplied to set_rownames() function';

throws_ok { $matrix0->set_rownames('fake') } qr/ERROR: fake supplied/, 
    'TESTING DIE ERROR when arg. supplied to set_rownames() isnt ARAYREF';

throws_ok { $matrix0->set_rownames(['A','B','C']) } qr/ERROR: Different numb/,
    'TESTING DIE ERROR when arg. supplied to set_rownames() has diff. rown';


## data accessor, TEST 23 to 26

$matrix0->set_data([ 1, 2, 3, 4, 5, 6] );
is(join(',', @{$matrix0->get_data()}), '1,2,3,4,5,6', 
    "testing get/set_data, checking data")
    or diag("Looks like this has failed");

throws_ok { $matrix0->set_data() } qr/ERROR: No data_aref/, 
    'TESTING DIE ERROR when no arg. was supplied to set_data() function';

throws_ok { $matrix0->set_data('fake') } qr/ERROR: fake supplied/, 
    'TESTING DIE ERROR when arg. supplied to set_data() isnt ARAYREF';

throws_ok { $matrix0->set_data([1, 2, 3, 4]) } qr/ERROR: data_n = 4/,
    'TESTING DIE ERROR when arg. supplied to set_data() has diff. rown';





##############################################################
## Finally it will clean the files produced during the test ##
##############################################################

foreach my $clean_rih (@rih_objs) {
    $clean_rih->cleanup()
}
  
####
1; #
####
