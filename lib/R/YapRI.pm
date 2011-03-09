
package R::YapRI;


###############
### PERLDOC ###
###############

=head1 NAME

R::YapRI.pm

Just the doc. for R::YapRI modules.

=cut

our $VERSION = '0.04';
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

More information about the basic usage can be found: L<R::YapRI::Base>.

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

More information about the use of blocks can be found at L<R::YapRI::Block>.

It can use interpreters (L<R::YapRI::Interpreter::Perl>), so sometimes
it can use perl hashref. instead strings to add_commands.

 $rbase->add_command('mean(c(2,3,5,7,11,13,17,19,23,29))');
 $rbase->add_command({ mean => [2,3,5,7,11,13,17,19,23,29]});

It uses two switches to trace the R commands that you are running:

- disable_keepfiles/enable_keepfiles, to do not delete the command files and
the result files after the executation of the code.

- disable_debug/enable_debug, to print as STDERR the R commands from the 
command file before executate them.

There are some examples of modules that wrap L<R::YapRI::Base> for an extended 
functionality.

* Matrix manipulation L<R::YapRI::Data::Matrix>

  use R::YapRI::Base;
  use R::YapRI::Data::Matrix;

  my $rbase = R::YapRI::Base->new();
  $rbase->create_block('BLOCK1');

  my $rmatrix = R::YapRI::Data::Matrix->new( { name     => 'matrix1',
                                               coln     => 3,
                                               rown     => 3,
                                               colnames => ['a', 'b', 'c'],
                                               rownames => ['X', 'Y', 'Z'],
                                               data     => [1,2,3,4,5,6,7,8,9],
                                             } );
 
  $rmatrix->send_rbase($rbase, 'BLOCK1');
  $rbase->add_command('eigenvect1 <- eigen(matrix1)$vectors', 'BLOCK1');
  my $eigenvectors = read_rbase($rbase, 'BLOCK1', 'eigenvect1');


* Simple graph creation L<R::YapRI::Graph::Simple>

  use R::YapRI::Base;
  use R::YapRI::Data::Matrix;
  use R::YapRI::Graph::Simple;

  my $rbase = R::YapRI::Base->new();

  my $rmatrix = R::YapRI::Data::Matrix->new( { name     => 'gene_expr',
                                               coln     => 2,
                                               rown     => 1,
                                               colnames => ['WT', 'Mut'],
                                               rownames => ['TIR1'],
                                               data     => [674, 54],
                                             } );

  my $rgraph = R::YapRI::Graph::Simple->new({
    rbase  => $rbase,
    rdata  => { height => $rmatrix },
    grfile => "TirGeneExpression.bmp",
    device => { bmp => { width => 600, height => 600 } },
    sgraph => { barplot => { beside => 'TRUE',
                             main   => 'Tir Gene Expression',
                             xlab   => 'Samples',
                             ylab   => 'Expression',
                             col    => ["dark blue", "dark red"],
              } 
    },

  $rgraph->build_graph('GRAPHBLOCK1');
  my ($filegraph, $fileresults) = $rgraph->build_graph();


=head1 AUTHOR

Aureliano Bombarely <ab782@cornell.edu>

=head1 ACKNOWLEDGEMENTS

Lukas Mueller

Robert Buels

Naama Menda

Jonathan "Duke" Leto

=head1 PUBLIC REPOSITORY

Hosted at GitHub: L<https://github.com/solgenomics/yapri>

=head1 COPYRIGHT AND LICENCE

Copyright 2011 Boyce Thompson Institute for Plant Research

Copyright 2011 Sol Genomics Network (solgenomics.net)

This program is free software; you can redistribute it and/or 
modify it under the same terms as Perl itself.

=cut

