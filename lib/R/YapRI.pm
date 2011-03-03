
package R::YapRI;


###############
### PERLDOC ###
###############

=head1 NAME

R::YapRI.pm
Just the doc. for R::YapRI modules.

=cut

our $VERSION = '0.02';
$VERSION = eval $VERSION;

=head1 SYNOPSIS

  use R::YapRI::Base;

  ## WORKING WITH THE DEFAULT MODE:

  my $rbase = R::YapRI::Base->new();
  $rbase->add_command('bmp(filename="myfile.bmp", width=600, height=800)');
  $rbase->add_command('dev.list()');
  $rbase->add_command('plot(c(1, 5, 10), type = "l")');
  $rbase->add_command('dev.off()');
 
  $rbase->run_command();
  
  my $result_file = $rbase->get_result_file();
  
  ## To work with blocks, check R::YapRI::Block


=head1 DESCRIPTION

Yet another perl wrapper to interact with R. 
R::YapRI are a collection of modules to interact with R using Perl.

The mechanism is simple, it write R commands into a command file and 
executate it using the R as command line: 
   R [options] < infile > outfile

 use R::YapRI::Base;
 my $rbase = R::YapRI::Base->new();
 $rbase->add_command('x <- c(1:10)');
 $rbase->add_command('y <- c(2,3,5,7,11,13,17,19,23,29)');
 $rbase->add_command('x * y');
 my $resultfile = $rbase->get_result_file();

But there are some tricks, it can define blocks and combine them, so it can
extend the interaction between packages of information. For example, it can
create a block to check the length of a vector using default as base

 my $newblock = $rbase->create_block('lengthblock', 'default');
 $newblock->add_command('length(x * y)');
 $newblock->run_block();
 my @results = $newblock->read_results();
 
 if ($results[0] == 10) {
    my $newblock2 = $rbase->create_block('meanblock', 'default');
    $newblock2->add_command('z <- mean(x * y)');
    $newblock2->run_block();
    my @results2 = $newblock2->read_results();
 }

It can use interpreters (R::YapRI::Interpreter::Perl), so sometimes
it can use perl hashref. instead strings to add_commands.

 $rbase->add_command('mean(c(2,3,5,7,11,13,17,19,23,29))');
 $rbase->add_command({ mean => [2,3,5,7,11,13,17,19,23,29]});

It uses two switches to trace the R commands that you are running:
- disable_keepfiles/enable_keepfiles, to do not delete the command files and
the result files after the executation of the code.
- disable_debug/enable_debug, to print as STDERR the R commands from the 
command file before executate them.

=head1 AUTHOR

Aureliano Bombarely <ab782@cornell.edu>

=head1 COPYRIGHT AND LICENCE

Copyright 2009 Boyce Thompson Institute for Plant Research

This program is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

=cut

