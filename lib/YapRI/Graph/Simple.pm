
package YapRI::Graph::Simple;

use strict;
use warnings;
use autodie;

use Carp qw| croak cluck |;
use String::Random qw/ random_regex random_string/;

use YapRI::Base;


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

  ## WORKING WITH THE DEFAULT MODE:

  my $rgraph = YapRI::Graph->new();
  $rgraph->device(bmp, { width => 600, height => 800, units => "px" });
  $rgraph->par();
 
  ## EDITING SOME OPTIONS

  $rgraph->resize({ width => 600, height => 800, units => "px"});
  $rgraph->format('jpeg');
  $rgraph->graph('barplot');
  $rgraph->print($filegraph2);


=head1 DESCRIPTION

 This module use YapRI as interpreter to send commands to R to create 
 graphs using YapRI::Base module


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
        display => a scalar, a R plot function
        grargs  => a hash ref. with R plot function args.
        
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
	rbase   => 'YapRI::Base',
	grfile  => '\w+',
	device  => '\w+',
	devargs => {},
	sgraph  => '\w+',
	sgrargs => {},
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
	    else {	
		if ($args{$arg} !~ m/$permargs{$arg}/) {
		    croak("ARGUMENT ERROR: $args{$arg} isnt permited val.");
		}
	    }
	}
    }

    ## After check it will add default values

    unless (defined $args{rbase}) {
	$args{rbase} = YapRI::Base->new();
    }

    my %defargs = (
	grfile  => 'grfile_' . random_regex('\w\w\w\w\w\w'),
	device  => 'bmp',
	devargs => { width => 600, height => 600, units => "px" },
	sgraph  => 'barplot',
	grargs  => {},
	);
    
    foreach my $def (keys %defargs) {
	unless (exists $args{$def}) {
	    $args{$def} = $defargs{$def};
	}
    }
    
    ## Finally it will set all the args

    foreach my $keyarg (keys %args) {
	my $function = 'set_' . $keyargs . '(' . $args{$keyargs} .')';
	$self->$funtion;
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
    my $rbase = shift ||
	croak("ERROR: No rbase object was supplied to set_rbase()");

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
    my $grfile = shift ||
	croak("ERROR: No grfile object was supplied to set_grfile()");

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
    my $dev = shift ||
	croak("ERROR: No device object was supplied to set_device()");

    my %permdev = ( bmp => 1, jpeg => 1, tiff => 1, png => 1 );
    unless (exists $permdev{$dev}) {
	my $list = join(',', keys %permdev);
	croak("ERROR: $dev isnt permited device list ($list) for set_device()");
    }
    
    $self->{device} = $dev;
}

=head2 get/set_devargs

  Usage: my $devargs_href = $rgraph->get_devargs();
         $rgraph->set_devargs($devargs_href);

  Desc: Get or set the device arguments accessor.
        Use help(bmp) at the R terminal for more info.

  Ret: Get: $devargs_href, a hash reference (see below)
       Set: none

  Args: Get: none
        Set: $device_href, a hash reference.

  Side_Effects: Get: None
                Set: Die if no device argument is supplied.
                     Die if it isnt a hash reference
                     Die if device or rbase were not set before.
                     Die if it use a no-permited argument pair. It will get
                     the permited values using YapRI::Base::r_function_args 
                     function. 

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
	croak("ERROR: No device arguments was supplied to set_devargs()");

    if ($devargs_href =~ m/./) {  ## It is not empty
	unless (ref($devargs_href) eq 'HASH') {
	    croak("ERROR: $devargs_href for set_devargs() isnt a HASH REF.");
	}
    }

    my %devs = %{$devargs_href};

    ## Check if rbase and device are defined

    my $rbase = $self->get_rbase();
    unless ($rbase =~ m/\w+/) {
	croak("ERROR: Rbase was not set before use set_devargs. Method fails");
    }

    my $device = $self->get_device();
    unless ($device =~ m/\w+/) {
	croak("ERROR: Device was not set before use set_devargs. Method fails");
    }

    ## Get args for the R function defined for device, deleting filename

    my %permargs = $rbase->r_function_args($device);;
    delete($permargs{filename});               ## defined for grfile args
    

    foreach my $karg (keys %devs) {
	unless (exists $permargs{$karg}) {
	    my $l = "device=$device, args=" . join(',', keys %permargs);
	    croak("ERROR: key=$karg used at set_devargs() isnt permited\n($l)");
	}
    }
    
    $self->{devargs} = $devargs_href;
}

=head2 get/set_sgraph

  Usage: my $sgraph = $rgraph->get_sgraph();
         $rgraph->set_sgraph($sgraph);

  Desc: Get or set the simple graph accessor

  Ret: Get: $sgraph, a R simple graph function 
            (plot, hist, dotchart, barplot, pie, boxplot)
       Set: none

  Args: Get: none
        Set: $sgraph, a R simple graph function 
            (plot, hist, dotchart, barplot, pie, boxplot)
        
  Side_Effects: Get: None
                Set: Die if no sgraph is supplied or if it isnt the permited
                     list

  Example: my $sgraph = $rgraph->get_sgraph();
           $rgraph->set_sgraph('pie');
          
          
=cut

sub get_sgraph {
    my $self = shift;
    return $self->{sgraph};
}

sub set_sgraph {
    my $self = shift;
    my $sgraph = shift ||
	croak("ERROR: No simple graph arg. was supplied to set_sgraph()");

    my %permgraph = ( 
	plot     => 1, 
	hist     => 1, 
	dotchart => 1, 
	barplot  => 1, 
	pie      => 1, 
	boxplot  => 1
	);

    unless (exists $permgraph{$sgraph}) {
	my $l = join(',', keys %permgraph);
	croak("ERROR: $sgraph isnt permited sgraph list ($l) for set_sgraph()");
    }
    
    $self->{sgraph} = $sgraph;
}

=head2 get/set_sgrargs

  Usage: my $sgrargs_href = $rgraph->get_sgrargs();
         $rgraph->set_sgrargs($sgrargs_href);

  Desc: Get or set the simple graph arguments accessor.
        Use help() with a concrete sgraph at the R terminal for more info.

  Ret: Get: $sgrargs, a hash reference
       Set: none

  Args: Get: none
        Set: $sgrargs_href, a hash reference

  Side_Effects: Get: None
                Set: Die if no simple graph argument is supplied.
                     Die if it isnt a hash reference
                     Die if sgraph argument was not set before

  Example: 
          
          
=cut

sub get_sgrargs {
    my $self = shift;
    return $self->{sgrargs};
}

sub set_sgrargs {
    my $self = shift;
    my $sgrargs_href = shift ||
	croak("ERROR: No simple graph arguments was supplied to set_sgrargs()");

    if ($sgrargs_href =~ m/./) {  ## It is not empty
	unless (ref($sgrargs_href) eq 'HASH') {
	    croak("ERROR: $sgrargs_href for set_sgrargs() isnt a HASH REF.");
	}
    }

    my %sgra = %{$sgrargs_href};

    ## Check if rbase and device are defined

    my $rbase = $self->get_rbase();
    unless ($rbase =~ m/\w+/) {
	croak("ERROR: Rbase was not set before use set_sgrargs. Method fails");
    }

    my $sgraph = $self->get_spgraph();
    unless ($device =~ m/\w+/) {
	croak("ERROR: Sgraph was not set before use set_sgrargs. Method fails");
    }

    ## Get args for the R function defined for sgraph, deleting the arguments
    ## without values (usually input.data)

    my %permargs = $rbase->r_function_args($sgraph);
    foreach my $parg (keys %permargs) {
	if ($permargs{$parg} eq '<without.value>') {
	    delete($permargs{$parg});
	}
    }    

    foreach my $karg (keys %sgrs) {
	unless (exists $permargs{$karg}) {
	    my $l = "sgraph=$sgraph, args=" . join(',', keys %permargs);
	    croak("ERROR: key=$karg used at set_sgrargs() isnt permited\n($l)");
	}
    }
        
    $self->{sgrargs} = $sgrargs_href;
}


####
1; #
####
