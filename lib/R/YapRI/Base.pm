
package R::YapRI::Base;

use strict;
use warnings;
use autodie;

use Carp qw( carp croak cluck );
use Math::BigFloat;
use File::Spec;
use File::Temp qw( tempfile tempdir );
use File::Path qw( make_path remove_tree);
use File::stat;

use R::YapRI::Interpreter::Perl qw( r_var );
use R::YapRI::Block;

###############
### PERLDOC ###
###############

=head1 NAME

R::YapRI::Base.pm
A wrapper to interact with R/

=cut

our $VERSION = '0.01';
$VERSION = eval $VERSION;

=head1 SYNOPSIS

  use R::YapRI::Base;

  ## WORKING WITH THE DEFAULT MODE:

  my $rih = R::YapRI::Base->new();
  $rih->add_command('bmp(filename="myfile.bmp", width=600, height=800)');
  $rih->add_command('dev.list()');
  $rih->add_command('plot(c(1, 5, 10), type = "l")');
  $rih->add_command('dev.off()');
 
  $rih->run_command();
  
  my $result_file = $rih->get_resultfiles('default');

  
  ## To work with blocks, check R::YapRI::Block



=head1 DESCRIPTION

 Another yet perl wrapper to interact with R


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

  Usage: my $rbase = R::YapRI::Base->new($arguments_href);

  Desc: Create a new R interfase object.

  Ret: a R::YapRI::Base object

  Args: A hash reference with the following parameters:
        cmddir       => A string, a dir to store the command files
        r_options    => A string with the R options passed to run_command
        use_defaults => 0|1 to disable/enable use_default.
        debug        => 0|1 to disable/enable debug for run commands.
        keepfiles    => 0|1 to disable/enable keepfiles after DESTROY rbase
        
  Side_Effects: Die if the argument used is not a hash or its values arent 
                right.
                By default it will use set_default_cmddir(), 
                and set_default_r_options();

  Example: ## Default method:
              my $rih = R::YapRI::Base->new();
          
           ## Create an empty object
              my $rih = R::YapRI::Base->new({ use_defaults => 0 });

           ## Defining own dir
              
              my $rih = R::YapRI::Base->new({ cmddir   => '/home/user/R' });

=cut

sub new {
    my $class = shift;
    my $args_href = shift;

    my $self = bless( {}, $class ); 

    my %permargs = (
	cmddir       => '\w+',
	r_options    => '-{1,2}\w+',
	use_defaults => '(0|1)',
	debug        => '(0|1)',
	keepfiles    => '(0|1)',
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

    my $defs = 1;
    if (defined $args{use_defaults}) {
	$defs = $args{use_defaults};
    }

    ## Set the dir to put all the commands

    my $cmddir = $args{cmddir} || '';  ## Empty var by default
    $self->set_cmddir($cmddir);
    if ($defs == 1) {
	$self->set_default_cmddir();
    }

    my $r_optspass = $args{r_options} || '';  ## Empty scalar by default 
    if ($defs == 1) {
	$self->set_default_r_options();
    }
    else {
	$self->set_r_options($r_optspass);
    }

    ## Initializate block accessor

    $self->set_blocks({});                      
    
    ## Create the default block (R::YapRI::Block->new will add the block)
    
    if ($defs == 1) {
	my $defblock = R::YapRI::Block->new($self, 'default');
    }

    ## enable/disable debug and keepfiles

    if (defined $args{debug} && $args{debug} == 1) {
	$self->enable_debug();
    }
    else {
	$self->disable_debug();
    }

    if (defined $args{keepfiles} && $args{keepfiles} == 1) {
	$self->enable_keepfiles();
    }
    else {
	$self->disable_keepfiles();
    }

    return $self;
}




########################
## INTERNAL ACCESSORS ##
########################


=head1 (*) DEBUGGING SWITCH METHODS:

=head2 ---------------------------

=head2 enable/disable_keepfiles

  Usage: $rbase->enable_keepfiles();
         $rbase->disable_keepfiles();

  Desc: Enable or disable keep the command files and the result files
        during the destruction of the rbase object.

  Ret: None

  Args: None

  Side_Effects: None

  Example: $rbase->enable_keepfiles();
           $rbase->disable_keepfiles();

=cut


sub enable_keepfiles {
    my $self = shift;
    $self->{keepfiles} = 1;
}

sub disable_keepfiles {
    my $self = shift;
    $self->{keepfiles} = 0;
}

=head2 enable/disable_debug

  Usage: $rbase->enable_debug();
         $rbase->disable_debug();

  Desc: Enable or disable debug option that print as STDERR the R command
        when run_commands or run_block methods are used.

  Ret: None

  Args: None

  Side_Effects: None

  Example: $rbase->enable_debug();
           $rbase->disable_debug();

=cut


sub enable_debug {
    my $self = shift;
    $self->{debug} = 1;
}

sub disable_debug {
    my $self = shift;
    $self->{debug} = 0;
}



#################
### ACCESSORS ###
#################

=head1 (*) ACCESSORS:

=head2 ------------

=head2 get_cmddir

  Usage: my $cmddir = $rbase->get_cmddir(); 

  Desc: Get the command dir used by the r interfase object

  Ret: $cmddir, a scalar

  Args: None

  Side_Effects: None

  Example: my $cmddir = $rbase->get_cmddir();   

=cut

sub get_cmddir {
    my $self = shift;
    return $self->{cmddir};
}

=head2 set_cmddir

  Usage: $rbase->set_cmddir($cmddir); 

  Desc: Set the command dir used by the r interfase object

  Ret: None

  Args: $cmddir, a scalar

  Side_Effects: Die if no argument is used.
                Die if the cmddir doesnt exists

  Example: $rbase->set_cmddir($cmddir); 

=cut

sub set_cmddir {
    my $self = shift;
    my $cmddir = shift;
 
    unless (defined $cmddir) {
	croak("ERROR: cmddir argument used for set_cmddir function is undef.");
    }
    else {
	if ($cmddir =~ m/\w+/) {  ## If there are something check if exists
	    unless (defined(-f $cmddir)) {
		croak("ERROR: dir arg. used for set_cmddir() doesnt exists");
	    }
	}
    }
    
    $self->{cmddir} = $cmddir;
}

=head2 set_default_cmddir

  Usage: $rbase->set_default_cmddir(); 

  Desc: Set the command dir used by the r interfase object with a default value
        such as RiPerldir_XXXXXXXX

  Ret: None

  Args: None

  Side_Effects: Create the perl_ri_XXXXXXXX folder in the tmp dir

  Example: $rbase->set_default_cmddir(); 

=cut

sub set_default_cmddir {
    my $self = shift;

    my $cmddir = tempdir('RiPerldir_XXXXXXXX', TMPDIR => 1);

    $self->{cmddir} = $cmddir;
}


=head2 delete_cmddir

  Usage: my $cmddir = $rbase->delete_cmddir(); 

  Desc: Delete the command dir used by the r interfase object

  Ret: $cmddir, deleted cmddir

  Args: None

  Side_Effects: Die if no argument is used.

  Example: $rbase->delete_cmddir(); 

=cut

sub delete_cmddir {
    my $self = shift;

    my $cmddir = $self->get_cmddir();
    if (defined $cmddir && length($cmddir) > 0) {
	remove_tree($cmddir);
    }
    
    delete($self->{cmddir});

    ## Set an empty variable
    $self->set_cmddir('');

    return $cmddir;
}


=head2 get_blocks

  Usage: my $block_href = $rbase->get_blocks(); 

  Desc: Get the blocks objects used by the r interfase object

  Ret: $block_href, a hash reference with key=blockname, value=rblock object.

  Args: $blockname [optional]

  Side_Effects: None

  Example: my %blocks = %{$rbase->get_blocks()};
           my $block1 = $rbase->get_blocks('block1');

=cut

sub get_blocks {
    my $self = shift;
    my $blockname = shift;

    if (defined $blockname) {
	return $self->{blocks}->{$blockname};
    }
    else { 
	return $self->{blocks};
    }
}

=head2 set_blocks

  Usage: $rbase->set_blocks($block_href); 

  Desc: Set the blocks objects used by the r interfase object

  Ret: None

  Args: $block_href, a hash reference with key=blockname, value=rblock object.

  Side_Effects: Die if no argument is used.
                Die if argument is not hash ref.
                Die if the values are not R::YapRI::Block objects.

  Example: $rbase->set_blocks({ $block->get_blockname() => $block }); 

=cut

sub set_blocks {
    my $self = shift;
    my $blockhref = shift ||
	croak("ERROR: No block hashref. argument was used for set_blocks()");
	
    if (ref($blockhref) ne 'HASH') {
	croak("ERROR: $blockhref used for set_blocks is not a hashref.");
    }
    
    foreach my $blname (keys %{$blockhref}) {
	my $block = $blockhref->{$blname};
	if (ref($block) ne 'R::YapRI::Block') {
	    croak("ERROR: $block supplied to set_blocks isnt R::YapRI::Block");
	}
    }
    $self->{blocks} = $blockhref;
}

=head2 add_block

  Usage: $rbase->add_block($block); 

  Desc: Add a new block object to the rbase object

  Ret: None

  Args: $block, a R::YapRI::Block object.

  Side_Effects: Die if no argument is used.
                Die if block is not a R::YapRI::Block object.
                Die if block has not set blockname.

  Example: $rbase->add_block('BLOCK1', $block1); 

=cut

sub add_block {
    my $self = shift;
    my $block = shift ||
	croak("ERROR: No block argument was supplied to add_block()");
    
    if (ref($block) ne 'R::YapRI::Block') {
	croak("ERROR: $block used for add_block is not a R::YapRI::Block.");
    }
    
    my $blockname = $block->get_blockname();
    unless (defined $blockname) {
	croak("ERROR: block $block used for add_block has not set blockname.");
    }
    else {
	if (length($blockname) == 0) {
	    croak("ERROR: empty blockname for $block was used for add_block");
	}
    }
    
    $self->{blocks}->{$blockname} = $block;
}

=head2 delete_block

  Usage: $rbase->delete_block($blockname);  

  Desc: Delete a block from the rbase object.

  Ret: None

  Args: $blockname, a blockname.

  Side_Effects: Die if no argument is used.
                If switch keepfiles is dissable it will delete the files
                associated with that block too.

  Example: $rbase->delete_block('BLOCK1'); 

=cut

sub delete_block {
    my $self = shift;
    my $blockname = shift ||
	croak("ERROR: No blockname argument was supplied to delete_block()");

    delete($self->{blocks}->{$blockname});
}


=head2 get_r_options

  Usage: my $r_options = $rih->get_r_options(); 

  Desc: Get the r_opts_pass variable (options used with the R command)
        when run_command function is used

  Ret: $r_opts_pass, a string

  Args: None

  Side_Effects: None

  Example: my $r_opts_pass = $rbase->get_r_options(); 
           if ($r_opts_pass !~ m/vanilla/) {
              $r_opts_pass .= ' --vanilla';
           }

=cut

sub get_r_options {
    my $self = shift;
    return $self->{r_options};
}

=head2 set_r_options

  Usage: $rbase->set_r_options($r_opts_pass); 

  Desc: Set the r_opts_pass variable (options used with the R command)
        when run_command function is used. Use R -help for more info.
        The most common options used:
        --save                Do save workspace at the end of the session
        --no-save             Don't save it
        --no-environ          Don't read the site and user environment files
        --no-site-file        Don't read the site-wide Rprofile
        --no-init-file        Don't read the user R profile
        --restore             Do restore previously saved objects at startup
        --no-restore-data     Don't restore previously saved objects
        --no-restore-history  Don't restore the R history file
        --no-restore          Don't restore anything
        --vanilla             Combine --no-save, --no-restore, --no-site-file,
                              --no-init-file and --no-environ
        -q, --quiet           Don't print startup message
        --silent              Same as --quiet
        --slave               Make R run as quietly as possible
        --interactive         Force an interactive session
        --verbose             Print more information about progress

        The only opt that can not be set using set_r_opts_pass is --file, 
        it is defined by the commands stored as cmdfiles.

  Ret: None

  Args: $r_opts_pass, a string

  Side_Effects: Remove '--file=' from the r_opts_pass string

  Example: $rbase->set_r_options('--verbose');

=cut

sub set_r_options {
    my $self = shift;
    my $r_opts_pass = shift;
 
    if ($r_opts_pass =~ m/(--file=.+)\s*/) {  ## If it exists, remove it
	carp("WARNING: --file opt. will be ignore for set_r_opts_pass()");
	$r_opts_pass =~ s/--file=.+\s*/ /g;
    }
    
    $self->{r_options} = $r_opts_pass;
}

=head2 set_default_r_options

  Usage: $rih->set_default_r_options(); 

  Desc: Set the default R options for R::YapRI::Base (R --slave --vanilla)

  Ret: None

  Args: None

  Side_Effects: None

  Example: $rih->set_default_r_options(); 

=cut

sub set_default_r_options {
    my $self = shift;

    my $def_r_opts_pass = '--slave --vanilla';

    $self->{r_options} = $def_r_opts_pass;
}



#################
## FILE METHODS #
#################

=head1 (*) FILE METHODS:

=head2 ---------------

=head2 create_rfile

  Usage: my $rfile = $rbase->create_rfile($basename);

  Desc: Create a new file inside cmddir folder.

  Ret: $rfile, a filename for the new file.

  Args: $basename, a basename for the new file. It will add 8 random
        characters to this basename.

  Side_Effects: Die if cmddir is not set.
                Use 'RiPerl_cmd_' as basename.

  Example: my $rfile = $rbase->create_rfile();

=cut

sub create_rfile {
    my $self = shift;
    my $basename = shift || "RiPerlcmd_";

    my $cmddir = $self->get_cmddir();
    if (length($cmddir) == 0) {
	croak("ERROR: new cmdfile cant be created if cmddir isnt set");
    }
    my ($fh, $filename) = tempfile($basename . "_XXXXXXXX", DIR => $cmddir);
    close($fh);

    return $filename;
}


#################
## CMD OPTIONS ##
#################

=head1 (*) COMMAND METHODS:

=head2 ------------------

=head2 add_command

  Usage: $rbase->add_command($r_command, $blockname); 

  Desc: Add a R command line to a cmdfile associated with an blockname.
        If no filename is used, it will added to the 'default' blockname.

  Ret: None

  Args: $r_command, a string with a R command
        $blockname, a alias with a cmdfile to add the command [optional]

  Side_Effects: Die if the blockname used doesnt exist or doesnt have cmdfile
                Add the command to the default if no filename is specified,
                if doesnt exist default cmdfile, it will create it.

  Example: $rbase->add_command('x <- c(10, 9, 8, 5)')
           $rbase->add_command('x <- c(10, 9, 8, 5)', 'block1')

=cut

sub add_command {
    my $self = shift;
    my $command = shift ||
	croak("ERROR: No command line was added to add_command function");
    
    my $blockname = shift || 'default';

    my $block = $self->get_blocks($blockname);
    
    my $err = "Aborting add_command()";
    unless (defined $block) {
	croak("ERROR: Block=$blockname doesnt exists for rbase. $err.");
    }
    else {
	my $cmdfile = $block->get_command_file();
	if (defined $cmdfile && length($cmdfile) > 0 && -f $cmdfile) {
	    
	    open my $cmdfh, '>>', $cmdfile;  ## open and append
	    print $cmdfh "$command\n";       ## write it with breakline
	    close($cmdfh);                   ## close it
	}
	else {
	    croak("ERROR: cmdfile for blockname isnt set/doesnt exist. $err.");
	}
    }
}

=head2 get_commands

  Usage: my @commands = $rbase->get_commands($blockname); 

  Desc: Read the cmdfile associated with an $blockname.
        'default' blockname will be used by default.

  Ret: None

  Args: $blockname, a blockname [optional]

  Side_Effects: Die if $blockname doesnt exist or doesnt have cmdfile
                Get commands for default file, by default

  Example: my @commands = $rbase->get_commands('block1');
           my @def_commands = $rbase->get_commands(); 

=cut

sub get_commands {
    my $self = shift;
    my $blockname = shift || 'default';

    my @commands = ();

    my $block = $self->get_blocks($blockname);
    
    my $err = "Aborting get_commands()";
    unless (defined $block) {
	croak("ERROR: Block=$blockname doesnt exists for rbase. $err.");
    }
    else {
	my $cmdfile = $block->get_command_file();
	if (defined $cmdfile && length($cmdfile) > 0 && -f $cmdfile) {
	    
	    open my $cmdfh, '+<', $cmdfile;  ## open for read
	    while(<$cmdfh>) {                ## read it
		chomp($_);
		push @commands, $_;
	    }
	    close($cmdfh);                   ## close it
	}
	else {
	    croak("ERROR: cmdfile for blockname isnt set/doesnt exist. $err.");
	}
    }

    return @commands;
}

=head2 run_commands

  Usage: $rih->run_commands($blockname); 

  Desc: Run as command line the R command file

  Ret: None

  Args: $blockname, a blockname to run the commands. 
        'default' if no blockname is used.
        $debug, 'debug' to print the command as STDERR.

  Side_Effects: Die if no R executable path is not found. 
                Die if blockname used doesnt exist.
                Die if block doesnt have set cmdfile.

  Example: $rih->run_commands('BLOCK1'); 

=cut

sub run_commands {
    my $self = shift;
    my $blockname = shift || 'default';

    ## Get R from whenever it is...

    my $R = _system_r();
    unless (defined $R) {
	croak("SYSTEM ERROR: R::YapRI::Base cannot find R executable.");
    }

    my $base_cmd = $R . ' ';

    ## Add the running opts

    my $r_opts_pass = $self->get_r_options();
    $base_cmd .= $r_opts_pass;

    ## Check blockname

    my $block = $self->get_blocks($blockname);
    
    my $err = "Aborting run_commands()";
    unless (defined $block) {
	croak("ERROR: Block=$blockname doesnt exists for rbase. $err.");
    }
    else {
	my $cmdfile = $block->get_command_file();
	if (defined $cmdfile && length($cmdfile) > 0 && -f $cmdfile) {
	    
	    ## Now it will be able to add the cmdfile as input file
	    
	    $base_cmd .= " --file=$cmdfile";
	}
	else {
	    croak("ERROR: cmdfile for blockname isnt set/doesnt exist. $err.");
	}
    }
   

    ## Check cmddir

    my $cmddir = $self->get_cmddir();
    unless ($cmddir =~ m/\w+/) {
	croak("ERROR: cmddir isnt set. Result files cannot be created. $err");
    }

    ## Create the result file to store the results.

    my $resultfile = $self->create_rfile("RiPerlresult_");
    $base_cmd .= " > $resultfile";

    if ($self->{debug} == 1) {
	print STDERR "RUNNING COMMAND:\n$base_cmd\n";
    }

    my $run = system($base_cmd);
           
    if ($run == 0) {   ## It means success	
	$block->set_result_file($resultfile);
    }
    else {
	croak("\nSYSTEM FAILS running R:\nsystem error: $run\n\n");
    }
}

=head2 _system_r

  Usage: my $R = _system_r(); 

  Desc: Get R executable path from $RBASE environment variable. If it doesnt
        exist, it will search in $PATH.

  Ret: $R, R executable path.

  Args: None
 
  Side_Effects: None

  Example: my $R = _system_r();

=cut

sub _system_r {
    
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
    return $r;
}



###################
## BLOCK METHODS ##
###################

=head1 (*) BLOCK METHODS:

=head2 ------------------

 They are a collection of methods to use R::YapRI::Block

=head2 combine_blocks

  Usage: my $block = $rbase->combine_blocks(\@blocks, $new_block); 

  Desc: Create a new block based in an array of defined blocks

  Ret: None

  Args: \@blocks, an array reference with the blocks (cmdfiles aliases) in the
        same order that they will be concatenated.

  Side_Effects: Die if the alias used doesnt exist or doesnt have cmdfile

  Example: my $block = $rbase->combine_blocks(['block1', 'block3'], 'block43');

=cut

sub combine_blocks {
    my $self = shift;
    my $block_aref = shift ||
	croak("ERROR: No block aref. was supplied to combine_blocks function");
    my $blockname = shift ||
	croak("ERROR: No new blockname was supplied to combine_blocks()");
    
    unless (ref($block_aref) eq 'ARRAY') {
	croak("ERROR: $block_aref used for combine_blocks() isnt an ARRAYREF.");
    }

    ## 1) Get the filenames for all the alias list, read them and 
    ##    put them into an array.

    my @r_cmds = ();
    
    foreach my $blockname_c (@{$block_aref}) {
	
	my $block = $self->get_blocks($blockname_c);
	
	if (defined $block) {
	 
	    my @commands = $self->get_commands($blockname_c);
	    push @r_cmds, @commands;

	}
	else {
	    ## Die if the block used doesnt exist
	    croak("ERROR: $blockname_c at combine_blocks() doesnt exist");
	}
    }

    ## 2) Create a temp file for the new block

    my $newblock = R::YapRI::Block->new($self, $blockname);

    ## 3) Print there the commands

    foreach my $cmdline (@r_cmds) {
	$newblock->add_command($cmdline);
    }
    return $newblock;
}

=head2 create_block

  Usage: my $block = $rbase->create_block($new_block, $base_block); 

  Desc: Create a new block object. A single block can be used as base.

  Ret: $block, a new R::YapRI::Block object

  Args: $new_block, new name/alias for this block
        $base_block, base block name

  Side_Effects: Die if the base alias used doesnt exist or doesnt have cmdfile

  Example: my $newblock = $rbase->create_block('block43', 'block1');

=cut

sub create_block {
    my $self = shift;
    my $blockname = shift ||
	croak("ERROR: No new blockname was supplied to create_block()");
    my $base = shift;

    my $newblock;

    if (defined $base) {
	$newblock = $self->combine_blocks([$base], $blockname);
    }
    else {
	$newblock = R::YapRI::Block->new($self, $blockname);
    }
    return $newblock;
}




#################################
## R. OBJECT/FUNCTIONS METHODS ##
#################################

=head2 r_object_class

  Usage: my $class = $rbase->r_object_class($block, $r_object); 

  Desc: Check if exists a r_object in the specified R block. Return 
        undef if the object doesnt exist or the class of the object 

  Ret: $class, a scalar with the class of the r_object

  Args: $block, a scalar, R::YapRI::Base block
        $r_object, name of the R object 

  Side_Effects: Die if the base alias used doesnt exist or doesnt have cmdfile

  Example: my $class = $rbase->r_object_class('BLOCK1', 'mtx');

=cut

sub r_object_class {
    my $self = shift;
    my $blockname = shift ||
	croak("ERROR: No blockname was supplied to r_object_class()");
    my $r_obj = shift ||
	croak("ERROR: No r_object was supplied to r_object_class()");

    ## Check if exist the block (alias) used

    unless (defined $self->get_blocks($blockname)) {
	croak("ERROR: $blockname doesnt exist for $self object");
    }

    ## Define the class var.

    my $class;

    ## If exist it will create a new block to check the r_object

    my $cblock = 'CHECK_rOBJ_' . $r_obj;
    $self->create_block($cblock, $blockname);
    
    ## Add the commands and run it
    ## It will run the conditional if(exists("myobject")) before to skip
    ## the error... if doesnt exist, it just will not run class

    $self->add_command('print("init_object_checking_' . $r_obj . '")', $cblock);
    $self->add_command('if(exists("'.$r_obj.'"))class('.$r_obj.')', $cblock);
    $self->add_command('print("end_object_checking_' . $r_obj . '")', $cblock);
    
    $self->run_commands($cblock);

    ## Open the result file and parse it

    my $resultfile = $self->get_blocks($cblock)->get_result_file();
    open my $rfh, '<', $resultfile;

    my $init = 0;
    while (<$rfh>) {
	chomp($_);
	
	## First, disable init as soon as it read it
	if ($_ =~ /end_object_checking_$r_obj/) {
	    $init = 0;
	}
	
        ## Second, catch the data only if init is enable
	if ($init == 1) {
	    if ($_ =~ m/\[1\]\s+"(.+)"/) {
		$class = $1;
	    }
	}

	## Third, enable the init at the end of the line parse
	if ($_ =~ /init_object_checking_$r_obj/) {
	    $init = 1;
	}
	
	
    }
    close($rfh);

    ## Delete the block

    $self->delete_block($cblock);

    return $class;
}

=head2 r_function_args

  Usage: my %rargs = $rbase->r_function_args($r_function); 

  Desc: Get the arguments for a concrete R function.

  Ret: %rargs, a hash with key=r_function_argument, 
                           value=function_default_value

  Args: none

  Side_Effects: Die if no R function argument is used
                Return empty hash if the function doesnt exist
                If the argument doesnt have any value, add <without.value>

  Example: my %plot_args = $rbase->r_function_args('plot')

=cut

sub r_function_args {
    my $self = shift;
    my $func = shift ||
	croak("ERROR: No R function argument was used for r_funtion_args()");

    my %fargs = ();

    ## Define blocks

    my $block1 = 'GETARGSR_' . $func . '_1';
    $self->create_block($block1);
    my $block2 = 'GETARGSR_' . $func . '_2';
    $self->create_block($block2);
    my @blocks = ($block1, $block2);

    ## Get environment for function

    my $env;

    my $env_cmd = 'if(exists("'.$func.'"))environment('.$func.')';
    $self->add_command($env_cmd, $block1);
    $self->run_commands($block1);
    my $rfile1 = $self->get_blocks($block1)->get_result_file();
    
    open my $rfh1, '<', $rfile1;
    while(<$rfh1>) {
	if ($_ =~ m/<environment:\snamespace:(.+)>/) {
	    $env = $1;
	}
    }
    close($rfh1);

    ## Now if it has a env (defined $env), it will the second command

    if (defined $env) {

	## Build the command as a conditional to get args for non default
	## objects

	my $arg_cmd = 'if( exists("' . $func . '.default")) ';
	$arg_cmd .= 'args(' . $func . '.default)';
	$arg_cmd .= 'else args(' . $func .')';

	$self->add_command($arg_cmd, $block2);
	$self->run_commands($block2);
	my $rfile2 = $self->get_blocks($block2)->get_result_file();

	open my $rfh2, '<', $rfile2;
	
	## Catch the defaults
	my $fline = '';
	while(<$rfh2>) {
	    chomp($_);
	    $_ =~ s/\s+/ /g;
	    $fline .= $_;
	}
	close($rfh2);
	
	## Parse the line
	$fline =~ s/^function\s*\(\s*//;            ## Remove the head
	$fline =~ s/,\s*?\.{1,3}//;                 ## Remove three dots
	$fline =~ s/\s*\)\s*NULL$//;                ## Remove the tail
	$fline =~ s/\s*=\s*/=/g;                    ## Remove the spaces 
                                                    ## rounding '='

	## keep the array data together, and replace for a tag
	$fline =~ s/c\(.+?\)/<data.vector>/g;
	$fline =~ s/".*?"/<data.scalar.character>/g;
	
	my @fpargs = split(/,/, $fline);
	foreach my $fparg (@fpargs) {
	    $fparg =~ s/^\s+//;
	    if ($fparg =~ m/^(.+)=(.+)$/) {
		my $k = $1;
		$fargs{$k} = $2;
		if ($fargs{$k} =~ m/^\d+$/) {
		    $fargs{$k} = '<data.scalar.numeric>';
		}
		
	    }
	    else {
		$fargs{$fparg} = '<without.value>';
	    }
	}
    }

    ## Finally it will delete the blocks
    
    foreach my $block (@blocks) {
	$self->delete_block($block);
    }

    return %fargs;
}




################
## DESTRUCTOR ##
################

=head2 DESTROY

  Usage: $rbase->DESTROY(); 
 
  Desc: Destructor for rbase object. It also undef all the block objects
        references contained in the rbase object.
        If keepfiles switch is enabled it will not delete the files and the
        cmddir.

  Ret: None

  Args: None

  Side_Effects: None

  Example: $rbase->DESTROY();

=cut

sub DESTROY {
    my $self = shift;

    ## First delete the blocks references that contains rbase refs.

    $self->{blocks} = {};;

    ## Second delete the cmddir

    unless (exists $self->{keepfiles} && $self->{keepfiles} == 1) {
	my $cmddir = $self->delete_cmddir();
    } 
}



####
1; #
####
