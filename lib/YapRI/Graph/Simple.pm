
package YapRI::Graph::Simple;

use strict;
use warnings;
use autodie;

use Carp qw| croak cluck |;
use String::Random qw/ random_regex random_string/;

use YapRI::Base;
use YapRI::Data::Matrix;


###############
### PERLDOC ###
###############

=head1 NAME

YapRI::Graph::Simple.pm
A module to create simple graphs using R through YapRI::Base

=cut

our $VERSION = '0.01';
$VERSION = eval $VERSION;

=head1 SYNOPSIS

  use YapRI::Graph::Simple;

  


=head1 DESCRIPTION

 


=head1 AUTHOR

Aureliano Bombarely <ab782@cornell.edu>


=head1 CLASS METHODS

The following class methods are implemented:

=cut 



############################
### GENERAL CONSTRUCTORS ###
############################

=head1 (*) CONSTRUCTORS:

=head2 ---------------


=head2 constructor new

  Usage: my $rgraph = YapRI::Graph->new($arguments_href);

  Desc: Create a new R graph object

  Ret: a YapRI::Graph object

  Args: A hash reference with the following parameters:
        rbase   => A YapRI::Base object
        grfile  => A filename
        device  => a scalar, a R grDevice 
        devargs => a hash ref. with grDevice arguments.
        grparam => a hash ref. with graphical parameters for 'par' R function
        sgraph  => a scalar, a R high-level plotting command (example: hist)
        sgrargs => a hash ref. with R plot function args.
        gritems => a hash ref. with key=R low-level plotting command and
                                    val=hash ref. with args. for that command.
        datamatrix => A YapRI::Data::Matrix object 
        
        
  Side_Effects: Die if the argument used is not a hash or its values arent 
                right.

  Example: ## Default method:
              my $rih = YapRI::Graph->new();
          
          
=cut

sub new {
    my $class = shift;
    my $args_href = shift;

    my $self = bless( {}, $class ); 

    my %permargs = (
	rbase      => 'YapRI::Base',
	grfile     => '\w+',
	device     => '\w+',
	devargs    => {},
	grparams   => {},
	sgraph     => '\w+',
	sgrargs    => {},
	gritems    => [],
	datamatrix => 'YapRI::Data::Matrix',
	);

    ## Check variables.

    my %args = ();
    if (defined $args_href) {
	unless (ref($args_href) eq 'HASH') {
	    croak("ARGUMENT ERROR: Arg. supplied to new() isnt HASHREF");
	}
	else {
	    %args = %{$args_href}
	}
    }

    foreach my $arg (keys %args) {
	unless (exists $permargs{$arg}) {
	    croak("ARGUMENT ERROR: $arg isnt permited arg for new() function");
	}
	else {
	    unless (defined $args{$arg}) {
		croak("ARGUMENT ERROR: value for $arg isnt defined for new()");
	    }
	}
    }

    ## After check it will add default values and add in an specific order

    unless (defined $args{rbase}) {
	$args{rbase} = YapRI::Base->new();
    }

    my %defargs = ( 
	1 => [ 'grfile',     'grfile_' . random_regex('\w\w\w\w\w\w')       ],
	2 => [ 'device',     'bmp'                                          ],
	3 => [ 'devargs',    { width => 600, height => 600, units => "px" } ],
	4 => [ 'grparams',   {}                                             ],
	5 => [ 'sgraph',     'barplot'                                      ],
	6 => [ 'sgrargs',    {}                                             ],
	7 => [ 'gritems',    []                                             ],
        8 => [ 'datamatrix', ''                                             ],
	);
    
    foreach my $idx (sort {$a <=> $b} keys %defargs) {
	my @def_pair = @{$defargs{$idx}};
	my $def = $def_pair[0];
	unless (exists $args{$def}) {
	    $args{$def} = $def_pair[1];
	}
    }
    
    ## Finally it will set all the args

    foreach my $keyarg (keys %args) {
	my $function = 'set_' . $keyarg;
	$self->$function($args{$keyarg});
    }
    
    return $self;
}


###############
## ACCESSORS ##
###############

=head1 (*) ACCESSORS:

=head2 ---------------


=head2 get/set_rbase

  Usage: my $rbase = $rgraph->get_rbase();
         $rgraph->set_rbase($rbase);

  Desc: Get or set the rbase (YapRI::Base object) accessor

  Ret: Get: $rbase, a YapRI::Base object
       Set: none

  Args: Get: none
        Set: $rbase, a YapRI::Base object
        
  Side_Effects: Get: None
                Set: Die if no rbase object is supplied or if it isnt a 
                     YapRI::Base object

  Example: my $rbase = $rgraph->get_rbase();
           $rgraph->set_rbase($rbase);
          
          
=cut

sub get_rbase {
    my $self = shift;
    return $self->{rbase};
}

sub set_rbase {
    my $self = shift;
    my $rbase = shift;
    
    unless (defined $rbase) {
	croak("ERROR: No rbase object was supplied to set_rbase()");
    }

    if($rbase =~ m/\w+/) {
	unless (ref($rbase) eq 'YapRI::Base') {
	    croak("ERROR: $rbase obj. supplied to set_rbase isnt YapRI::Base");
	}
    }
    $self->{rbase} = $rbase;
}

=head2 get/set_grfile

  Usage: my $grfile = $rgraph->get_grfile();
         $rgraph->set_grfile($grfile);

  Desc: Get or set the grfile accessor

  Ret: Get: $grfile, a scalar, a filename
       Set: none

  Args: Get: none
        Set: $grfile, a scalar, filename
        
  Side_Effects: Get: None
                Set: Die if no grfile is supplied

  Example: my $grfile = $rgraph->get_grfile();
           $rgraph->set_grfile('myfile.bmp');
          
          
=cut

sub get_grfile {
    my $self = shift;
    return $self->{grfile};
}

sub set_grfile {
    my $self = shift;
    my $grfile = shift;
    
    unless (defined $grfile) {
	croak("ERROR: No grfile object was supplied to set_grfile()");
    }

    $self->{grfile} = $grfile;
}


=head2 get/set_device

  Usage: my $device = $rgraph->get_device();
         $rgraph->set_device($device);

  Desc: Get or set the device accessor

  Ret: Get: $device, a R grDevice (bmp, jpeg, tiff, png)
       Set: none

  Args: Get: none
        Set: $device, a R grDevice (bmp, jpeg, tiff, png)
        
  Side_Effects: Get: None
                Set: Die if no device is supplied or if it isnt the permited
                     list

  Example: my $device = $rgraph->get_device();
           $rgraph->set_device('tiff');
          
          
=cut

sub get_device {
    my $self = shift;
    return $self->{device};
}

sub set_device {
    my $self = shift;
    my $dev = shift;
    
    unless (defined $dev) {
	croak("ERROR: No device object was supplied to set_device()");
    }

    my %permdev = ( bmp => 1, jpeg => 1, tiff => 1, png => 1 );
    
    if ($dev =~ m/./) {
	unless (exists $permdev{$dev}) {
	    my $list = join(',', keys %permdev);
	    croak("ERROR: $dev isnt permited device ($list) for set_device()");
	}
    }
    
    $self->{device} = $dev;
}

=head2 get/set_devargs

  Usage: my $devargs_href = $rgraph->get_devargs();
         $rgraph->set_devargs($devargs_href);

  Desc: Get or set the device arguments accessor.
        Use help(bmp) at the R terminal for more info.

q  Ret: Get: $devargs_href, a hash reference (see below)
       Set: none

  Args: Get: none
        Set: $device_href, a hash reference.

  Side_Effects: Get: None
                Set: Die if no device argument is supplied.
                     Die if it isnt a hash reference
                     Die if device or rbase were not set before.
                     Die if it use a no-permited argument pair. It will get
                     the permited values using YapRI::Base::r_function_args 
                     function from device as R function

  Example: my %dev_args = %{$rgraph->get_devargs()};
           $rgraph->set_device({ width => 500, height => 500 });
          
          
=cut

sub get_devargs {
    my $self = shift;
    return $self->{devargs};
}

sub set_devargs {
    my $self = shift;
    my $devargs_href = shift ||
	croak("ERROR: No devargs was supplied to set_devargs()");

    if ($devargs_href =~ m/./) {  ## It is not empty
	unless (ref($devargs_href) eq 'HASH') {
	    croak("ERROR: $devargs_href for set_devargs() isnt a HASH REF.");
	}
    }

    my %devs = %{$devargs_href};
    
    if (scalar(keys %devs) > 0) { ## Means that it isnt empty

	## Check if rbase and device are defined

	my $rbase = $self->get_rbase();
	unless ($rbase =~ m/\w+/) {
	    croak("ERROR: Rbase was not set before set_devargs. Method fails");
	}

	my $device = $self->get_device();
	unless ($device =~ m/\w+/) {
	    croak("ERROR: Device was not set before set_devargs. Method fails");
	}

	## Get args for the R function defined for device, deleting filename

	my %permargs = $rbase->r_function_args($device);;
	delete($permargs{filename});               ## defined for grfile args
    

	foreach my $karg (keys %devs) {
	    unless (exists $permargs{$karg}) {
		my $l = "(device=$device, args=".join(',', keys %permargs).")";
		croak("ERROR: key=$karg for set_devargs() isnt permited $l");
	    }
	}
    }
    
    $self->{devargs} = $devargs_href;
}


=head2 get/set_grparams

  Usage: my $grparams_href = $rgraph->get_grparams();
         $rgraph->set_grparams($grparams_href);

  Desc: Get or set the graphical parameter accessor.
        Use help(par) at the R terminal for more info.

  Ret: Get: $grparam_href, a hash reference (see below)
       Set: none

  Args: Get: none
        Set: $grparam_href, a hash reference.

  Side_Effects: Get: None
                Set: Die if no graphical parameter argument is supplied.
                     (empty hashref. is permited)
                     Die if it isnt a hash reference
                     Die if it doesnt use a permited parameter

  Example: my %grparams = %{$rgraph->get_grparam()};
           $rgraph->set_grparams({});
          
          
=cut

sub get_grparams {
    my $self = shift;
    return $self->{grparams};
}

sub set_grparams {
    my $self = shift;
    my $grparam_href = shift ||
	croak("ERROR: No grparams were supplied to set_grparam()");

    if ($grparam_href =~ m/./) {  ## It is not empty
	unless (ref($grparam_href) eq 'HASH') {
	    croak("ERROR: $grparam_href for set_grparam() isnt a HASH REF.");
	}
    }

    my %grparam = %{$grparam_href};

    ## Define the graphical parameters permited (it cannot be catched with
    ## r_function_args function)

    my @permgrp = qw/ adj ann ask bg bty cex cex.axis cex.lab cex.main 
		    cex.sub cin col col.axis col.lab col.main col.sub cra crt
                    csi cxy din err family fg fig fin font font.axis font.lab
                    font.main font.sub lab las lend lheight ljoin lmitre lty
                    lwd mai mar mex mfcol mfrow mfg mgp mkh new oma omd omi
                    pch pin plt ps pty smo srt tck tcl usr xaxp xaxs xaxt xlog 
		    xpd yaxp yaxs yaxt ylog /;

    my %permgrp = ();
    foreach my $perm (@permgrp) {
	$permgrp{$perm} = 1;
    }


    foreach my $param (keys %grparam) {
	unless (exists $permgrp{$param}) {
	    my $t = "Use in the R terminal help(par) for more information.";
	    croak("ERROR: $param isnt a permited arg. for par R function. $t.");
	}
    }
    
    $self->{grparams} = $grparam_href;
}



=head2 get/set_sgraph

  Usage: my $sgraph = $rgraph->get_sgraph();
         $rgraph->set_sgraph($sgraph);

  Desc: Get or set the simple graph accessor

  Ret: Get: $sgraph, a R simple graph function (high-level plot command)
            (plot, pairs, coplot, hist, dotchart, barplot, pie, boxplot)
       Set: none

  Args: Get: none
        Set: $sgraph, a R simple graph function (high-level plot command)
            (plot, pairs, coplot, hist, dotchart, barplot, pie, boxplot)
        
  Side_Effects: Get: None
                Set: Die if no sgraph is supplied or if it isnt the permited
                     list

  Example: my $sgraph = $rgraph->get_sgraph();
           $rgraph->set_sgraph('barplot');
          
          
=cut

sub get_sgraph {
    my $self = shift;
    return $self->{sgraph};
}

sub set_sgraph {
    my $self = shift;
    my $sgraph = shift;
 
    unless (defined $sgraph) {
	croak("ERROR: No sgraph arg. was supplied to set_sgraph()");
    }

    my %permgraph = ( 
	plot     => 1,
	pairs    => 1,
	coplot   => 1,
	hist     => 1, 
	dotchart => 1, 
	barplot  => 1, 
	pie      => 1, 
	boxplot  => 1
	);

    if ($sgraph =~ m/./) {
	unless (exists $permgraph{$sgraph}) {
	    my $l = join(',', keys %permgraph);
	    croak("ERROR: $sgraph isnt permited sgraph ($l) for set_sgraph()");
	}
    }
    
    $self->{sgraph} = $sgraph;
}

=head2 get/set_sgrargs

  Usage: my $sgrargs_href = $rgraph->get_sgrargs();
         $rgraph->set_sgrargs($sgrargs_href);

  Desc: Get or set the simple graph arguments accessor.
        Use help() with a concrete sgraph at the R terminal for more info.

  Ret: Get: $sgrargs, a hash reference with args. for sgraph (high level plot)
       Set: none

  Args: Get: none
        Set: $sgrargs_href, a hash reference with args. for sgraph

  Side_Effects: Get: None
                Set: Die if no simple graph argument is supplied.
                     Die if it isnt a hash reference
                     Die if sgraph argument was not set before
                     Die if it use a no-permited argument pair. It will get
                     the permited values using YapRI::Base::r_function_args 
                     function from sgraph as R function

  Example: my %sgrargs = %{$rgraph->get_sgrargs()};
           $rgraph->set_sgrargs({ width => 2, space => 0.5 });
          
          
=cut

sub get_sgrargs {
    my $self = shift;
    return $self->{sgrargs};
}

sub set_sgrargs {
    my $self = shift;
    my $sgrargs_href = shift ||
	croak("ERROR: No sgrargs were supplied to set_sgrargs()");

    if ($sgrargs_href =~ m/./) {  ## It is not empty
	unless (ref($sgrargs_href) eq 'HASH') {
	    croak("ERROR: $sgrargs_href for set_sgrargs() isnt a HASH REF.");
	}
    }

    my %sgrargs = %{$sgrargs_href};

    ## Check if rbase and device are defined, if sgraph has arguments 

    if (scalar(keys %sgrargs)) {

	my $rbase = $self->get_rbase();
	unless ($rbase =~ m/\w+/) {
	    croak("ERROR: Rbase was not set before set_sgrargs. Method fails");
	}

	my $sgraph = $self->get_sgraph();
	unless ($sgraph =~ m/\w+/) {
	    croak("ERROR: Sgraph was not set before set_sgrargs. Method fails");
	}

	## Get args for the R function defined for sgraph, deleting the 
	## arguments without values (usually input.data)

	my %permargs = $rbase->r_function_args($sgraph);
	foreach my $parg (keys %permargs) {
	    if ($permargs{$parg} eq '<without.value>') {
		delete($permargs{$parg});
	    }
	}    

	foreach my $karg (keys %sgrargs) {
	    unless (exists $permargs{$karg}) {
		my $l = "sgraph=$sgraph, args=" . join(',', keys %permargs);
		croak("ERROR: key=$karg at set_sgrargs() isnt permited\n($l)");
	    }
	}
    }
        
    $self->{sgrargs} = $sgrargs_href;
}


=head2 get/set_gritems

  Usage: my $gritems_href = $rgraph->get_gritems();
         $rgraph->set_gritems($gritems_href);

  Desc: Get or set the graph items arguments (low-level plotting commands) 
        accessor.
        Use help() with a concrete gritem at the R terminal for more info.

  Ret: Get: $gritems, an array reference of hash references with 
                         key=R low-level plotting function
                         val=args. for that low-level func.
       Set: none

  Args: Get: none
        Set: $gritems, an array reference of hash references with 3 elements:
              func => R low-level plotting function (example: points)
              data => input data array refs for R function (example: [2, 4])
              args => hash ref. of args. for R function (example:{col => "red"})

  Side_Effects: Get: None
                Set: Die if no gritem argument is supplied (empty hash ref.
                     can be supplied)
                     Die if it isnt a array reference.
                     Die if rbase arg. was set before.
                     Die if the argument used it is not in the argument
                     permited list. 
                     Die if the arguments used for the low-level plotting
                     function are not in the permited arguments, get using
                     YapRI::Base::r_function_args function + additional func.
                     for specific cases (example: col.main or cex.sub for title)

  Example: my %gritems = %{$rgraph->get_gritems()};
           $rgraph->set_gritems([ 
                                  { 
                                    func => 'points',
                                    data => [2, 5],
                                    args => { cex => 0.5, col => "dark red" },
                                  } 
                                  { 
                                    func => 'legend',
                                    data => [25, 50, ["exp1", "exp2", "exp3"]],
                                    args => { bg => "gray90" },
                                  } 
                                ]);
          
          
=cut

sub get_gritems {
    my $self = shift;
    return $self->{gritems};
}

sub set_gritems {
    my $self = shift;
    my $gritems_aref = shift ||
	croak("ERROR: No gritems arg. were supplied to set_gritems()");

    if ($gritems_aref =~ m/./) {  ## It is not empty
	unless (ref($gritems_aref) eq 'ARRAY') {
	    croak("ERROR: $gritems_aref for set_gritems() isnt a HASH REF.");
	}
    }
    
    my @grit = @{$gritems_aref};

    ## Check if rbase is defined when gritems is not empty

    if (scalar(@grit) > 0) {

	my $rbase = $self->get_rbase();
	unless ($rbase =~ m/\w+/) {
	    croak("ERROR: Rbase was not set before set_sgritems. Method fails");
	}

	## Define the permited items, and the additional args. 

	my %permitems = ( 
	    points  => ['pch', 'col', 'bg', 'cex', 'lwd', 'lty'],
	    lines   => ['lty', 'lwd', 'col', 'pch', 'lend', 'ljoin', 'lmitre'],
	    abline  => ['lty', 'lwd', 'col', 'lend', 'ljoin', 'lmitre'],,
	    polygon => ['xpd', 'lend', 'ljoin', 'lmitre'], 
	    legend  => [],
	    title   => ['adj', 'xpd', 'mpg', 'font.main', 'col.main', 
			'font.sub', 'col.sub', 'font.xlab', 'col.xlab', 
			'font.ylab', 'col.ylab', 'cex.main', 'cex.sub', 
			'cex.xlab', 'cex.ylab' ], 
	    axis    => ['cex.axis', 'col.axis', 'font.axis', 'mpg', 'xaxp', 
			'yaxp', 'tck', 'tcl', 'las', 'fg', 'xaxt', 'yaxt'],
	    );

	## Check args. as items and item args.

	foreach my $fref (@grit) {

	    if (ref($fref) ne 'HASH') {
		croak("ERROR: $fref array member for set_gritems isnt HREF");
	    }
	    my %grfunc = %{$fref};
	    
	    unless (defined $grfunc{func}) {
		croak("ERROR: key='func' isnt defined for hashref set_gritems");
	    }
	    else {

		my $it = $grfunc{func};
		unless (exists $permitems{$it}) {
		    my $l = join(',', keys %permitems);
		    croak("ERROR: $it isnt perm.item list ($l) to set_gritems");
		}
		else {

		    my $err = "for $it at set_gritems isnt ";
		    ## check arrayref for 'data'
		    if (defined $grfunc{data}) {
			unless (ref($grfunc{data}) eq 'ARRAY') {
			    croak("ERROR: 'data' " . $err . "ARRAYREF")
			}
		    }

		    my $args = $grfunc{args};

		    ## check hashref for 'args'
		    unless (ref($args) eq 'HASH') {
			croak("ERROR: 'args' " . $err . "HASHREF");
		    }
	    
		    ## get args for R function
		    my %fargs = $rbase->r_function_args($it);
	    
		    ## add the additional args.
		    my @adargs = @{$permitems{$it}};
		    foreach my $adarg (@adargs) {
			$fargs{$adarg} = 1;
		    }
	    
		    ## check args
		    my $pl = "Args. for $it: (" . join(',', keys %fargs) . ")"; 
		    foreach my $ag (keys %{$grfunc{args}}) {
			unless (exists $fargs{$ag}) {
			    croak("ERROR: $ag isnt perm.arg. for $it\n($pl)\n");
			}
		    }
		}
	    }
	}
    }

    $self->{gritems} = $gritems_aref;
}

=head2 get/set_datamatrix

  Usage: my $matrix = $rgraph->get_datamatrix();
         $rgraph->set_datamatrix($matrix);

  Desc: Get or set the data matrix into YapRI::Graph::Simple object

  Ret: Get: $matrix, a YapRI::Data::Matrix object
       Set: none

  Args: Get: none
        Set: $matrix, a YapRI::Data::Matrix object

  Side_Effects: Die if no argument is used.
                Die if the object is not a YapRI::Data::Matrix object

  Example: my $matrix = $rgraph->get_datamatrix();
           $rgraph->set_datamatrix($matrix);
              
=cut

sub get_datamatrix {
    my $self = shift;
    return $self->{datamatrix};
}

sub set_datamatrix {
    my $self = shift;
    my $mtx = shift;

    unless (defined $mtx) {
	croak("ERROR: No datamatrix argument was supplied to set_datamatrix()")
    }
    else {
	if ($mtx =~ m/./) {
	    unless (ref($mtx) eq 'YapRI::Data::Matrix') {
		croak("ERROR: $mtx supplied to set_datamatrix isnt Matrix obj");
	    }
	}
    }
    $self->{datamatrix} = $mtx;
}


###################
## GRAPH METHODS ##
###################


=head2 _no_empty

  Usage: $rgraph->_no_empty($err_message);

  Desc: Check if all the accessors requested for build_graph contains data

  Ret: None

  Args: $err_message to add to the die message

  Side_Effects: Die if some of the requested accessors are empty

  Example: $rgraph->_no_empty();
              
=cut

sub _no_empty {
    my $self = shift;
    my $err = shift || '';
    
    ## Request checkings
    
    my @reqs = ('rbase', 'datamatrix', 'grfile', 'device', 'sgraph');
    foreach my $req (@reqs) {
	my $function = 'get_' . $req;
	my $elem = $self->$function();
	unless ($elem =~ m/./) {
	    croak("ERROR: $req accessor is empty. $err");
	}
    }

    ## As extra it will check the data in the matrix

    my $data_aref = $self->get_datamatrix()->get_data();
    unless (scalar(@{$data_aref}) > 0) {
	croak("ERROR: datamatrix object doesnt contain data. ");
    }
}

=head2 _device_cmd

  Usage: my $cmd = $rgraph->_device_cmd();

  Desc: Build the device command

  Ret: $cmd, a string with the device command

  Args: None

  Side_Effects: None

  Example: my $cmd = $rgraph->_device_cmd();
              
=cut

sub _device_cmd {
    my $self = shift;
    
    my $device = $self->get_device();
    my $grfile = $self->get_grfile();

    my $dev_cmd = $device . '(filename="' . $grfile . '"';
    
    my %devargs = %{$self->get_devargs()};
    foreach my $deva (sort keys %devargs) {
	
	$dev_cmd .= ', ' . $deva;
	if (defined $devargs{$deva}) {
	    
	    if ($devargs{$deva} =~ m/^\d+$/) {
		$dev_cmd .= '=' . $devargs{$deva};
	    }
	    else {
		$dev_cmd .= '="' . $devargs{$deva} . '"';
	    }
	}
    }
    $dev_cmd .= ')';

    return $dev_cmd;
}


=head2 _device_cmd

  Usage: my $cmd = $rgraph->_device_cmd();

  Desc: Build the device command

  Ret: $cmd, a string with the device command

  Args: None

  Side_Effects: None

  Example: my $cmd = $rgraph->_device_cmd();
              
=cut

sub _par_cmd {
    my $self = shift;
    
    my %parargs = %{$self->get_grparams()};

    my $cmd = '';

    if (scalar(keys %parargs)) {  ## Only if it has some graphical parameters
	
	$cmd = 'par(';  ## Init the command
    
	my @args = ();
	foreach my $par (sort keys %parargs) {
	    my $subcmd = $par;
	    if (defined $parargs{$par}) {
		if (ref($parargs{$par}) eq 'ARRAY') {
		    my @subarr = ();
		    foreach my $ve (@{$parargs{$par}}) {
			if ($ve =~ m/^(\d+|FALSE|TRUE)$/) {
			    push @subarr, $ve;
			}
			else {
			     push @subarr, '"' . $ve . '"';
			}
		    }
		    $subcmd .= '=c(' . join(', ', @subarr) . ')';
		}
		elsif ($parargs{$par} =~ m/^(\d+|FALSE|TRUE)$/) {
		    $subcmd .= '=' . $parargs{$par};
		}
		else {
		    $subcmd .= '="' . $parargs{$par} .'"';
		}
	    }
	    push @args, $subcmd;
	}
	$cmd .= join(', ', @args);  ## add the different args 
    
	$cmd .= ')';   ## End the command
    }

    return $cmd;
}


=head2 build_graph

  Usage: my $filegraph = $rgraph->build_graph();

  Desc: Create some YapRI blocks and run them to create the graph, 
        in the following order:
          1) create 'matrix' (datamatrix)
          2) init 'device' (device)
          3) pass 'par' graphical parameters (grparams)
          4) matrix conversions to high-level plotting commands
          5) execute high-level plotting command (sgraph)
          6) matrix concersions to low-level plotting commands
          7) execute low-level plotting commands (gritems)

  Ret: $filegraph, the name of the graph file 

  Args: None

  Side_Effects: Die if some of the accessors are empty

  Example: my $filegraph = $rgraph->build_graph();
              
=cut

sub build_graph {
    my $self = shift;


    ## Check requested accessors

    $self->_no_empty('Aborting build_graph().');

    ## 1) The block will have the name of the matrix

    my $rbase = $self->get_rbase();
    my $mtx = $self->get_datamatrix();

    my $block1 = $mtx->get_name();
    $mtx->send_rbase($rbase);

    ## 2) Build the command to init the device and add to the block

    my $dev_cmd = $self->_device_cmd();
    $rbase->add_command($dev_cmd, $block1);

    ## 3) Build the command with the graphical parameters

    my $par_cmd = $self->_par_cmd();

}










####
1; #
####
