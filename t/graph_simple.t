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
use Test::More tests => 60;
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
    grfile     => '',
    device     => '',
    devargs    => {},
    grparams   => {},
    sgraph     => '',
    sgrargs    => {},
    gritems    => [],
    datamatrix => '',
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

my $devargs0 = { width => 150, height => 200, units => 'px' };
my $grparams0 = { bg  => "transparent", 
		  cex => 1, 
		  lab => [5, 5, 7], 
		  xpd => 'FALSE' };
my $sgrargs0 = { type => "p", main => "title" };
my $gritems0 = [ { func => 'points',
                   data => [10, 20],
                   args => { cex => 0.5, col => "dark read" },
                 } 
               ];
my $rmatrix0 = YapRI::Data::Matrix->new();


## They need to run in order

my @acsors = (
    [ 'rbase'     , $rbase0    ], 
    [ 'grfile'    , 'filetest' ],
    [ 'device'    , 'bmp'      ],
    [ 'devargs'   , $devargs0  ],
    [ 'grparams'  , $grparams0 ],
    [ 'sgraph'    , 'plot'     ],
    [ 'sgrargs'   , $sgrargs0  ],
    [ 'gritems'   , $gritems0  ],
    [ 'datamatrix', $rmatrix0  ],
    );

## Run the common checkings, TEST 8 to 25

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

## Check die for specific accessors, TEST 26 to 47

throws_ok { $rgraph0->set_rbase('fake')} qr/ERROR: fake obj./, 
    "TESTING DIE ERROR when arg supplied to set_rbase isnt YapRI::Base";

throws_ok { $rgraph0->set_device('fake')} qr/ERROR: fake isnt permited/, 
    "TESTING DIE ERROR when arg supplied to set_device isnt a permited dev";

throws_ok { $rgraph0->set_devargs('fake')} qr/ERROR: fake for/, 
    "TESTING DIE ERROR when arg supplied to set_devargs isnt a HASHREF";

$rgraph0->set_rbase('');
throws_ok { $rgraph0->set_devargs({ units => 'px'})} qr/ERROR: Rbase/, 
    "TESTING DIE ERROR when rbase was not set before run set_devargs()";
$rgraph0->set_rbase($rbase0);

$rgraph0->set_device('');
throws_ok { $rgraph0->set_devargs({ units => 'px'})} qr/ERROR: Device/, 
    "TESTING DIE ERROR when device was not set before run set_devargs()";
$rgraph0->set_device('bmp');

throws_ok { $rgraph0->set_devargs({ fake => 'px'})} qr/ERROR: key=fake/, 
    "TESTING DIE ERROR when arg.key used for set_devargs() isnt permited";

throws_ok { $rgraph0->set_grparams('fake')} qr/ERROR: fake for/, 
    "TESTING DIE ERROR when arg supplied to set_grparams isnt a HASHREF";

throws_ok { $rgraph0->set_grparams({ fake => 'px'})} qr/ERROR: fake isnt/, 
    "TESTING DIE ERROR when arg.key used for set_grparams() isnt permited";

throws_ok { $rgraph0->set_sgraph('fake')} qr/ERROR: fake isnt permited/, 
    "TESTING DIE ERROR when arg supplied to set_sgraph isnt a permited sgraph";

throws_ok { $rgraph0->set_sgrargs('fake')} qr/ERROR: fake for/, 
    "TESTING DIE ERROR when arg supplied to set_sgrargs isnt a HASHREF";

$rgraph0->set_rbase('');
throws_ok { $rgraph0->set_sgrargs({ col => "red"})} qr/ERROR: Rbase/, 
    "TESTING DIE ERROR when rbase was not set before run set_sgrargs()";
$rgraph0->set_rbase($rbase0);

$rgraph0->set_sgraph('');
throws_ok { $rgraph0->set_sgrargs({ col => "red"})} qr/ERROR: Sgraph/, 
    "TESTING DIE ERROR when sgraph was not set before run set_sgrargs()";
$rgraph0->set_sgraph('plot');

throws_ok { $rgraph0->set_sgrargs({ fake => "red"})} qr/ERROR: key=fake/, 
    "TESTING DIE ERROR when arg.key used for set_sgrargs() isnt permited";

throws_ok { $rgraph0->set_gritems('fake')} qr/ERROR: fake for/, 
    "TESTING DIE ERROR when arg supplied to set_gritems isnt an ARRAYREF";

$rgraph0->set_rbase('');
throws_ok { $rgraph0->set_gritems([{ func => 'title' }])} qr/ERROR: Rbase/, 
    "TESTING DIE ERROR when rbase was not set before run set_gritems()";
$rgraph0->set_rbase($rbase0);

throws_ok { $rgraph0->set_gritems(['fake'])} qr/ERROR: fake array member/, 
    "TESTING DIE ERROR when an array member supplied to set_gritems isnt HREF";

throws_ok { $rgraph0->set_gritems([{ data => 'title' }])} qr/ERROR: key='func/, 
    "TESTING DIE ERROR when key='func' doesnt exist for an el. set_gritems()";

throws_ok { $rgraph0->set_gritems([{ func => 'fake' }])} qr/ERROR: fake/, 
    "TESTING DIE ERROR when non permited R function is used for set_gritems()";

throws_ok { $rgraph0->set_gritems([{ func => 'axis', data => 1 }])} qr/'data'/, 
    "TESTING DIE ERROR when 'data' format used for set_gritems() isnt AREF";

throws_ok { $rgraph0->set_gritems([{ func => 'axis', args => 1 }])} qr/'args'/, 
    "TESTING DIE ERROR when 'args' format used for set_gritems() isnt HREF";

throws_ok { $rgraph0->set_gritems([{ func => 'axis', 
				     args => { fake => 1 } }])} qr/ERROR: fak/, 
    "TESTING DIE ERROR when 'args' key used for set_gritems() isnt permited";

throws_ok { $rgraph0->set_datamatrix('fake')} qr/ERROR: fake supplied/, 
    "TESTING DIE ERROR when arg supp. set_datamatrix isnt YapRI::Data::Matrix";


########################
## INTERNAL FUNCTIONS ##
########################

## Test _no_empty, TEST 48 to 53

my @noempty = qw/ rbase datamatrix grfile device sgraph/;

foreach my $noem (@noempty) {
    my $nogetfunc = 'get_' . $noem;
    my $nosetfunc = 'set_' . $noem;
    my $nocat = $rgraph0->$nogetfunc();   ## get the accessor
    $rgraph0->$nosetfunc('');             ## replace by empty value
    
    throws_ok { $rgraph0->_no_empty()} qr/ERROR: $noem accessor is empty/, 
    "TESTING DIE ERROR when requested accessor is empty for _no_empty ($noem)";

    $rgraph0->$nosetfunc($nocat);         ## restore the original data
}

## Extra check, the matrix should have 0 data

throws_ok { $rgraph0->_no_empty()} qr/ERROR: datamatrix object/, 
    "TESTING DIE ERROR when datamatrix has 0 data for _no_empty";


## To continue it will add data to the matrix0

$rmatrix0->set_name('fruit_exp1');
$rmatrix0->set_coln(3);
$rmatrix0->set_rown(10);
$rmatrix0->set_colnames(['mass', 'length', 'width']);
$rmatrix0->set_rownames(['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J']);
$rmatrix0->set_data( [ 120, 23, 12, 126, 24, 19, 154, 28, 18, 109, 28, 24,
		      98, 19, 10, 201, 17, 37, 165, 29, 34, 178, 15, 25,
		      139, 11, 32, 78, 13, 23 ] );

## Check _device_cmd

my $exp_devcmd = 'bmp(filename="filetest", height=200, units="px", width=150)';
is($rgraph0->_device_cmd(), $exp_devcmd, 
   "testing _device_cmd, command constructor, checking command line")
    or diag("Looks like this has failed");

## Check _par_cmd

my $exp_parcmd = 'par(bg="transparent", cex=1, lab=c(5, 5, 7), xpd=FALSE)';
is($rgraph0->_par_cmd(), $exp_parcmd, 
   "testing _par_cmd, command constructor, checking command line")
    or diag("Looks like this has failed");


## Check is_grdevice_enabled, 

my $tblock0 = 'TestDevice0';
$rbase0->create_block($tblock0);
$rbase0->add_command($exp_devcmd, $tblock0);

is( $rgraph0->is_grdevice_enabled('bmp', $tblock0), 1,
    "Testing is_grdevice_enabled for enabled block, checking boolean")
    or diag("Looks like this has failed");

$rbase0->add_command('dev.off()', $tblock0);

is( $rgraph0->is_grdevice_enabled('bmp', $tblock0), 0,
    "Testing is_grdevice_enabled for disabled block, checking boolean")
    or diag("Looks like this has failed");

$rbase0->delete_cmdfile($tblock0);

throws_ok { $rgraph0->is_grdevice_enabled()} qr/ERROR: No device/, 
    "TESTING DIE ERROR when no device was supplied to is_device_enabled";

throws_ok { $rgraph0->is_grdevice_enabled('bmp')} qr/ERROR: No block/, 
    "TESTING DIE ERROR when no block was supplied to is_device_enabled";

throws_ok { $rgraph0->is_grdevice_enabled('bmp', $tblock0)} qr/ERROR: TestDev/, 
    "TESTING DIE ERROR when block supplied to is_device_enabled isnt defined";



############################
## REMOVE THE rbase files ##
############################

foreach my $rbase_c (@rih_objs) {
    $rbase_c->cleanup();
}

####
1; #
####

