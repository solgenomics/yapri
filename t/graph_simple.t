#!/usr/bin/perl

=head1 NAME
 
  graph_simple.t
  A piece of code to test the YapRI::Graph::Simple module

=cut

=head1 SYNOPSIS

 perl graph_simple.t
 prove graph_simple.t

=head1 DESCRIPTION

 Test YapRI::Graph::Simple module

=cut

=head1 AUTHORS

 Aureliano Bombarely Gomez
 (ab782@cornell.edu)

=cut

use strict;
use warnings;
use autodie;

use Data::Dumper;
use Test::More tests => 64;
use Test::Exception;
use Test::Warn;

use Cwd;

use FindBin;
use lib "$FindBin::Bin/../lib";

## TEST 1 and 3

BEGIN {
    use_ok('YapRI::Graph::Simple');
    use_ok('YapRI::Base');
    use_ok('YapRI::Data::Matrix');
}

## Add the object created to an array to clean them at the end of the script

my @rih_objs = ();

## First, create the empty object and check it, TEST 4 to 7

my %empty_args = (
    rbase      => '',
    rdata      => {},
    grfile     => '',
    device     => {},
    grparams   => {},
    sgraph     => {},
    gritems    => [],
    );

my $rgraph0 = YapRI::Graph::Simple->new(\%empty_args);

is(ref($rgraph0), 'YapRI::Graph::Simple', 
    "testing new() for an empty object, checking object identity")
    or diag("Looks like this has failed");

throws_ok { YapRI::Graph::Simple->new('fake') } qr/ARGUMENT ERROR: Arg./, 
    'TESTING DIE ERROR when arg. supplied new() function is not hash ref.';

throws_ok { YapRI::Graph::Simple->new({fake => 1}) } qr/ARGUMENT ERROR: fake/, 
    'TESTING DIE ERROR when arg. key supplied new() function is not permited.';

throws_ok { YapRI::Graph::Simple->new({rbase => undef})} qr/ARGUMENT ERROR: v/, 
    'TESTING DIE ERROR when arg. val supplied new() function is not defined.';


#######################
## TESTING ACCESSORS ##
#######################

## Create the objects

my $rbase0 = YapRI::Base->new();
push @rih_objs, $rbase0;


my $rdata0 = { x => YapRI::Data::Matrix->new( { name => 'fruitexp1' } ) };

my $device0 = { bmp => { width => 600, height => 600, units => 'px' } };
my $grparams0 = { par => { cex => 1, lab => [5, 5, 7], xpd => 'FALSE' } };
my $sgraph0 = { plot => { x => 'fruitexp1', main => "title" } };
my $gritems0 = [
    { points  => { 'x' => 100, 'y' =>  120, col => "red" } },
    ];



## They need to run in order

my @acsors = (
    [ 'rbase'     , $rbase0     ], 
    [ 'grfile'    , 'graph.bmp' ],
    [ 'rdata'     , $rdata0     ],
    [ 'device'    , $device0    ],
    [ 'grparams'  , $grparams0  ],
    [ 'sgraph'    , $sgraph0    ],
    [ 'gritems'   , $gritems0   ],
    );

## Run the common checkings, TEST 8 to 21

foreach my $accs (@acsors) {
    my $func = $accs->[0];
    my $setfunc = 'set_' . $func;
    my $getfunc = 'get_' . $func;
    my $args = $accs->[1];
    $rgraph0->$setfunc($args);
    is($rgraph0->$getfunc(), $args, 
	"Testing set/get_$func, checking data passing through the function")
	or diag("Looks like this has failed");

    throws_ok { $rgraph0->$setfunc()} qr/ERROR: No $func/, 
    "TESTING DIE ERROR when no args. were supplied to $setfunc function";
}

## Check die for specific accessors, TEST 22 to 38

throws_ok { $rgraph0->set_rbase('fake')} qr/ERROR: fake obj./, 
    "TESTING DIE ERROR when arg supplied to set_rbase isnt YapRI::Base";

throws_ok { $rgraph0->set_rdata('fake')} qr/ERROR: Rdata href/, 
    "TESTING DIE ERROR when arg supplied to set_rdata isnt HASHREF";

throws_ok { $rgraph0->set_rdata({ x => 'fake'})} qr/ERROR: fake/, 
    "TESTING DIE ERROR when val supplied to set_rdata isnt YapRI::Data::Matrix";

throws_ok { $rgraph0->set_device('fake')} qr/ERROR: Device href./, 
    "TESTING DIE ERROR when arg supplied to set_device isnt a HASHREF";

throws_ok { $rgraph0->set_device({ fake => {} })} qr/ERROR: fake isnt/, 
    "TESTING DIE ERROR when key.arg supplied to set_device isnt permited";

throws_ok { $rgraph0->set_device({ bmp => 'fake'})} qr/ERROR: arg. href./, 
    "TESTING DIE ERROR when value supplied to set_device isnt a HASHREF";

throws_ok { $rgraph0->set_grparams('fake')} qr/ERROR: fake for/, 
    "TESTING DIE ERROR when arg supplied to set_grparams isnt a HASHREF";

throws_ok { $rgraph0->set_grparams({ fake => 'px'})} qr/ERROR: 'par'/, 
    "TESTING DIE ERROR when par key was not used for set_grparams()";

throws_ok { $rgraph0->set_grparams({ par => 'px'})} qr/ERROR: hashref. arg./, 
    "TESTING DIE ERROR when par value used for set_grparams() isnt HASHREF";

throws_ok { $rgraph0->set_grparams({ par => {fk => 1} })} qr/ERROR: fk isnt/, 
    "TESTING DIE ERROR when arg. for par used at set_grparams() isnt permited";

throws_ok { $rgraph0->set_sgraph('fake')} qr/ERROR: fake supplied to/, 
    "TESTING DIE ERROR when arg supplied to set_sgraph isnt a HASHREF";

throws_ok { $rgraph0->set_sgraph({ fake => {}})} qr/ERROR: fake isnt/, 
    "TESTING DIE ERROR when function supplied to set_sgraph isnt permited";

throws_ok { $rgraph0->set_sgraph({ plot => 'fk'})} qr/ERROR: hashref. arg./, 
    "TESTING DIE ERROR when arg for function supplied to set_sgraph isnt HREF";

throws_ok { $rgraph0->set_gritems('fake')} qr/ERROR: fake /, 
    "TESTING DIE ERROR when arg supplied to set_gritems isnt an ARRAYREF";

throws_ok { $rgraph0->set_gritems(['fake'])} qr/ERROR: fake array/, 
    "TESTING DIE ERROR when aref member supplied to set_gritems isnt a HASHREF";

throws_ok { $rgraph0->set_gritems([{ fk => 1 }])} qr/ERROR: fk isnt a perm/, 
    "TESTING DIE ERROR when function supplied to set_gritems isnt permited";

throws_ok { $rgraph0->set_gritems([{ axis => 1 }])} qr/ERROR: value/, 
    "TESTING DIE ERROR when funct.arg supplied to set_gritems isnt a HASHREF";



########################
## INTERNAL FUNCTIONS ##
########################

## To continue it will add data to the matrix0

$rdata0->{x}->set_coln(3);
$rdata0->{x}->set_rown(10);
$rdata0->{x}->set_colnames(['mass', 'length', 'width']);
$rdata0->{x}->set_rownames(['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J']);
$rdata0->{x}->set_data( [ 120, 23, 12, 126, 24, 19, 154, 28, 18, 109, 28, 24,
		      98, 19, 10, 201, 17, 37, 165, 29, 34, 178, 15, 25,
		      139, 11, 32, 78, 13, 23 ] );


## Check by parts, _rbase_check TEST 39

$rgraph0->set_rbase('');
throws_ok { $rgraph0->_rbase_check() } qr/ERROR: Rbase is empty./, 
    "TESTING DIE ERROR when rbase is empty for _rbase_check()";


## _block_check, TEST 40 to 43

throws_ok { $rgraph0->_block_check() } qr/ERROR: Rbase is empty./, 
    "TESTING DIE ERROR when rbase is empty for _block_check()";

$rgraph0->set_rbase($rbase0);


is( $rgraph0->_block_check() =~ /GRAPH_BUILD_/, 1, 
    "testing _block_check for undef value, checking default block name")
    or diag("Looks like this has failed");

my %blocks0 = %{$rbase0->get_cmdfiles()};

is( $blocks0{'TESTBL1'}, undef, 
    "testing _block_check for def. new value, checking that block doesnt exist")
    or diag("Looks like this has failed");

$rgraph0->_block_check('TESTBL1');
my %blocks1 = %{$rbase0->get_cmdfiles()};

is( defined($blocks1{'TESTBL1'}), 1, 
    "testing _block_check for def. new value, checking block creation")
    or diag("Looks like this has failed");


## _sgraph_check, TEST 44 and 45

$rgraph0->set_sgraph({});

throws_ok { $rgraph0->_sgraph_check() } qr/ERROR: Sgraph doesnt/, 
    "TESTING DIE ERROR when sgraph is empty for _sgraph_check()";

$rgraph0->set_sgraph({ plot => {}, barplot => {} });

is($rgraph0->_sgraph_check, 'barplot', 
    "testing _sgraph_check with more than onwe funtion, checking return")
    or diag("Looks like this has failed");



my $block0 = $rgraph0->build_graph();
my %blocks2 = %{$rbase0->get_cmdfiles()};     



print STDERR "\n\n\n\n";

open my $tfh, '<', $blocks2{$block0};
while(<$tfh>) {
    print STDERR "$_";
} 


############################
## REMOVE THE rbase files ##
############################

foreach my $rbase_c (@rih_objs) {
    $rbase_c->cleanup();
}

####
1; #
####

