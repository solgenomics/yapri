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
use Test::More tests => 78;
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
    'TESTING DIE ERROR when arg. supplied to set_data() has diff. expected n';


########################
## INTERNAL FUNCTIONS ##
########################

## TEST 27 to 32

my %imtx = $matrix0->_index_matrix();
is(scalar(keys %imtx), $matrix0->get_rown() * $matrix0->get_coln(),
    "testing _index_matrix, checking number of indexes")
    or diag("Looks like this has failed");

$matrix0->_set_indexes(\%imtx);
is(scalar(keys %{$matrix0->_get_indexes()}), 
   $matrix0->get_rown() * $matrix0->get_coln(),
    "testing _get/set_matrix, checking number of indexes")
    or diag("Looks like this has failed");

is(join(',', sort(keys %{$matrix0->_get_rev_indexes()})), 
   join(',', sort(values %{$matrix0->_get_indexes()})),
   "testing _get_rev_indexes(), checking id of the revb indexes")
    or diag("Looks like this has failed");


throws_ok { $matrix0->_set_indexes() } qr/ERROR: No index href/, 
    'TESTING DIE ERROR when no arg. was supplied to _set_indexes() function';

throws_ok { $matrix0->_set_indexes('fake') } qr/ERROR: fake supplied/, 
    'TESTING DIE ERROR when arg. supplied to _set_indexes() isnt HASHREF';

throws_ok { $matrix0->_set_indexes({ '1,2' => 1 }) } qr/ERROR: indexN = 1/,
    'TESTING DIE ERROR when arg. supplied to _set_indexes() has diff. expected';


####################
## DATA FUNCTIONS ##
####################

## set_coldata function, TEST 33 to 38

$matrix0->set_coldata(2, [8, 9]);
is(join(',', @{$matrix0->get_data()}), '1,8,3,4,9,6', 
    "testing set_coldata, checking data")
    or diag("Looks like this has failed");

throws_ok { $matrix0->set_coldata() } qr/ERROR: No colname/, 
    'TESTING DIE ERROR when no arg. was supplied to set_coldata() function';

throws_ok { $matrix0->set_coldata(2) } qr/ERROR: No column data aref/, 
    'TESTING DIE ERROR when no column data aref. was supplied to set_coldata()';

throws_ok { $matrix0->set_coldata(2, 1) } qr/ERROR: column data aref = 1/, 
    'TESTING DIE ERROR when col. aref. supplied to set_coldata() isnt ARRAYREF';

throws_ok { $matrix0->set_coldata('fake', [1]) } qr/ERROR: fake/, 
    'TESTING DIE ERROR when col. name supplied to set_coldata() doesnt exist';

throws_ok { $matrix0->set_coldata(2, [1]) } qr/ERROR: data supplied/, 
    'TESTING DIE ERROR when data supplied to set_coldata() doesnt have same N';

## set_rowdata function, TEST 39 to 44

$matrix0->set_rowdata('B', [11, 59, 12]);
is(join(',', @{$matrix0->get_data()}), '1,8,3,11,59,12', 
    "testing set_rowdata, checking data")
    or diag("Looks like this has failed");

throws_ok { $matrix0->set_rowdata() } qr/ERROR: No rowname/, 
    'TESTING DIE ERROR when no arg. was supplied to set_rowdata() function';

throws_ok { $matrix0->set_rowdata('B') } qr/ERROR: No row data aref/, 
    'TESTING DIE ERROR when no row data aref. was supplied to set_rowdata()';

throws_ok { $matrix0->set_rowdata('B', 1) } qr/ERROR: row data aref = 1/, 
    'TESTING DIE ERROR when row aref. supplied to set_rowdata() isnt ARRAYREF';

throws_ok { $matrix0->set_rowdata('fake', [1]) } qr/ERROR: fake/, 
    'TESTING DIE ERROR when row. name supplied to set_rowdata() doesnt exist';

throws_ok { $matrix0->set_rowdata('B', [1]) } qr/ERROR: data supplied/, 
    'TESTING DIE ERROR when data supplied to set_rowdata() doesnt have same N';

## add_column, TEST 45 to 50

$matrix0->add_column(4, [12, 34]);
is(join(',', @{$matrix0->get_data()}), '1,8,3,12,11,59,12,34', 
    "testing add_column, checking data")
    or diag("Looks like this has failed");

is($matrix0->get_coln(), 4, 
    "testing add_column, checking new column number")
    or diag("Looks like this has failed");

is($matrix0->get_rown(), 2, 
    "testing add_column, checking row number")
    or diag("Looks like this has failed");

throws_ok { $matrix0->add_column() } qr/ERROR: No column data/, 
    'TESTING DIE ERROR when no column data arg. was supplied to add_column()';

throws_ok { $matrix0->add_column(undef, 'fake') } qr/ERROR: column data/, 
    'TESTING DIE ERROR when column data was supplied to add_column() isnt AREF';

throws_ok { $matrix0->add_column(undef, [1]) } qr/ERROR: element N./, 
    'TESTING DIE ERROR when column elements arent equal to row N';


## add_row, TEST 51 to 56

$matrix0->add_row('C', [15, 98, 37, 1]);
is(join(',', @{$matrix0->get_data()}), '1,8,3,12,11,59,12,34,15,98,37,1', 
    "testing add_row, checking data")
    or diag("Looks like this has failed");

is($matrix0->get_coln(), 4, 
    "testing add_row, checking column number")
    or diag("Looks like this has failed");

is($matrix0->get_rown(), 3, 
    "testing add_row, checking new row number")
    or diag("Looks like this has failed");

throws_ok { $matrix0->add_row() } qr/ERROR: No row data/, 
    'TESTING DIE ERROR when no row data arg. was supplied to add_row()';

throws_ok { $matrix0->add_row(undef, 'fake') } qr/ERROR: row data/, 
    'TESTING DIE ERROR when row data was supplied to add_row() isnt ARRAYREF';

throws_ok { $matrix0->add_row(undef, [1]) } qr/ERROR: element N./, 
    'TESTING DIE ERROR when row elements arent equal to col N';


## delete_column, TEST 57 to 62

my @deleted_col = $matrix0->delete_column(3);
is(join(',', @{$matrix0->get_data()}), '1,8,12,11,59,34,15,98,1',
    "testing delete_column, checking data")
    or diag("Looks like this has failed");

is($matrix0->get_coln(), 3, 
    "testing delete_column, checking new column number")
    or diag("Looks like this has failed");

is($matrix0->get_rown(), 3, 
    "testing delete_column, checking row number")
    or diag("Looks like this has failed");

is(join(',', @deleted_col), '3,12,37',
    "testing delete_column, checkin deleted data")
    or diag("Looks like this has failed");

throws_ok { $matrix0->delete_column() } qr/ERROR: No colname/, 
    'TESTING DIE ERROR when no colname arg. was supplied to delete_column()';

throws_ok { $matrix0->delete_column('fake') } qr/ERROR: fake used for/, 
    'TESTING DIE ERROR when colname supplied to delete_column() doesnt exist';


## delete_column, TEST 63 to 68

my @deleted_row = $matrix0->delete_row('B');
is(join(',', @{$matrix0->get_data()}), '1,8,12,15,98,1',
    "testing delete_row, checking data")
    or diag("Looks like this has failed");

is($matrix0->get_coln(), 3, 
    "testing delete_row, checking column number")
    or diag("Looks like this has failed");

is($matrix0->get_rown(), 2, 
    "testing delete_row, checking new row number")
    or diag("Looks like this has failed");

is(join(',', @deleted_row), '11,59,34',
    "testing delete_row, checkin deleted data")
    or diag("Looks like this has failed");

throws_ok { $matrix0->delete_row() } qr/ERROR: No rowname/, 
    'TESTING DIE ERROR when no rowname arg. was supplied to delete_row()';

throws_ok { $matrix0->delete_row('fake') } qr/ERROR: fake used for/, 
    'TESTING DIE ERROR when rowname supplied to delete_row() doesnt exist';


## Change_columns, TEST 69 to 73

$matrix0->change_columns(1, 4);
is(join(',', @{$matrix0->get_data()}), '12,8,1,1,98,15',
    "testing change_columns, checking data")
    or diag("Looks like this has failed");

is(join(',', @{$matrix0->get_colnames()}), '4,2,1',
    "testing change_columns, checking column names order")
    or diag("Looks like this has failed");

throws_ok { $matrix0->change_columns() } qr/ERROR: no colname1 arg./, 
    'TESTING DIE ERROR when no colname1 arg. was supplied to change_columns()';

throws_ok { $matrix0->change_columns(1) } qr/ERROR: no colname2 arg./, 
    'TESTING DIE ERROR when no colname2 arg. was supplied to change_columns()';

throws_ok { $matrix0->change_columns('fake', 1) } qr/ERROR: one or two/, 
    'TESTING DIE ERROR when colname supplied to change_columns() doesnt exist';


## Change_rows, TEST 74 to 78

$matrix0->change_rows('A', 'C');
is(join(',', @{$matrix0->get_data()}), '1,98,15,12,8,1',
    "testing change_rows, checking data")
    or diag("Looks like this has failed");

is(join(',', @{$matrix0->get_rownames()}), 'C,A',
    "testing change_rows, checking row names order")
    or diag("Looks like this has failed");

throws_ok { $matrix0->change_rows() } qr/ERROR: no rowname1 arg./, 
    'TESTING DIE ERROR when no rowname1 arg. was supplied to change_rows()';

throws_ok { $matrix0->change_rows('C') } qr/ERROR: no rowname2 arg./, 
    'TESTING DIE ERROR when no rowname2 arg. was supplied to change_rows()';

throws_ok { $matrix0->change_rows('fake', 'C') } qr/ERROR: one or two/, 
    'TESTING DIE ERROR when rowname supplied to change_rows() doesnt exist';




##############################################################
## Finally it will clean the files produced during the test ##
##############################################################

foreach my $clean_rih (@rih_objs) {
    $clean_rih->cleanup()
}
  
####
1; #
####
