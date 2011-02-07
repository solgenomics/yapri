
package YapRI::Data::Matrix;

use strict;
use warnings;
use autodie;

use Carp qw| croak cluck |;
use YapRI::Base;


###############
### PERLDOC ###
###############

=head1 NAME

YapRI::Data::Matrix.pm
A module to build and pass a Matrix to a YapRI command file

=cut

our $VERSION = '0.01';
$VERSION = eval $VERSION;

=head1 SYNOPSIS

  use YapRI::Base;
  use YapRI::Data::Matrix;

  ## Constructors:

  my $rmatrix = YapRI::Data::Matrix->new('matrix1');
  
  ## Accessors:

  my $matrixname = $rmatrix->get_name();
  $rmatrix->set_name('matrix');

  my $coln = $rmatrix->get_coln();
  $rmatrix->set_coln(3);

  my $rown = $rmatrix->get_rown();
  $rmatrix->set_rown(4);

  my @data = $rmatrix->get_data();
  $rmatrix->set_data(\@data);

  my @colnames = $rmatrix->get_colnames();
  $rmatrix->set_colnames(\@colnames);

  my @rownames = $rmatrix->get_colanmes();
  $rmatrix->set_colnames(\@rownames);

  ## Adding/deleting/changing data:

  $rmatrix->add_coldata($col_y, [$y1, $y2, $y3, $y4]);
  $rmatrix->add_rowdata($row_x, [$x1, $x2, $x3]);
  
  $rmatrix->push_col([$yy1, $yy2, $yy3, $yy4]);
  $rmatrix->push_row([$xx1, $xx2, $xx3]);

  my @oldcol = $rmatrix->pop_col();
  my @oldrow = $rmatrix->pop_row();

  $rmatrix->change_col($col_x, $col_z);
  $rmatrix->change_col($col_x, $col_z);


  ## Parsers:

  $rmatrix->parse_resultfile({ file     => $filename, 
                               coln     => $x, 
                               rown     => $y, 
                               colnames => 1, 
                               rownames => 1,
                            });
     
  my $rbase = YapRI::Base->new();
  $rmatrix->pass_rbase($rbase);

   ## Slicers:

   my @col2 = $rmatrix->get_col($col_y);
   my @row3 = $rmatrix->get_row($row_x);
   my $elem2_3 = $rmatrix->get_element($row_x, $col_y);


=head1 DESCRIPTION

 This module pass perl variables to a YapRI::Data::Matrix object that convert
 them in a R command line that it is passed to YapRI::Base object as a block.

   +-----------+    +----------------------+    +------------+    +---+--------+
   | PerlData1 | => | YaRI::Data::Matrix 1 | => |            | => |   | Input  |
   +-----------+    +----------------------+    | YaRI::Base |    | R |--------+
   | PerlData2 | <= | YaRI::Data::Matrix 2 |<=  |            | <= |   | Output |
   +-----------+    +----------------------+    +------------+    +---+--------+


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

  Usage: my $rmatrix = YapRI::Data::Matrix->new();

  Desc: Create a new YapRI::Data::Matrix object

  Ret: a YapRI::Data::Matrix object

  Args: A hash reference with the following parameters:
          name     => a scalar with the matrix name, 
          coln     => a scalar with the column number (int),
          rown     => a scalar with the row number (int),
          colnames => an array ref. with the column names,
          rownames => an array ref. with the row names,
          data     => an array ref. with the matrix data ordered by row.        
        
  Side_Effects: Die if the argument used is not a hash or its values arent 
                right.

  Example: my $rmatrix = YapRI::Data::Matrix->new(
                                     { 
                                       name     => 'matrix1',
                                       coln     => 3,
                                       rown     => 4,
                                       colnames => ['a', 'b', 'c'],
                                       rownames => ['W', 'X', 'Y', 'Z'],
                                       data     => [ 1, 1, 1, 2, 2, 2, 
                                                     3, 3, 3, 4, 4, 4,],
                                     }
                                   );

          
=cut

sub new {
    my $class = shift;
    my $args_href = shift;

    my $self = bless( {}, $class ); 

    my %permargs = (
	name     => '\w+',
	coln     => '^\d+$',
	rown     => '^\d+$',
        colnames => [],
        rownames => [],
        data     => [],
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
		if (ref($permargs{$arg})) {
		    unless (ref($permargs{$arg}) eq ref($args{$arg})) {
			croak("ARGUMENT ERROR: $args{$arg} isnt permited val.");
		    }
		}
		else {
		    if ($args{$arg} !~ m/$permargs{$arg}/) {
			croak("ARGUMENT ERROR: $args{$arg} isnt permited val.");
		    }
		}
	    }
	}
    }

    ## Pass the arguments to the accessors functions

    my $name = $args{name} || '';
    $self->set_name($name);

    my $coln = $args{coln} || '';
    $self->set_coln($coln);

    my $rown = $args{rown} || '';
    $self->set_rown($rown);

    my $colnames = $args{colnames} || [];
    $self->set_colnames($colnames);

    my $rownames = $args{rownames} || [];
    $self->set_rownames($rownames);

    my $data = $args{data} || [];
    $self->set_data($data);

    
    return $self;
}


###############
## ACCESSORS ##
###############

=head1 (*) ACCESSORS:

=head2 ------------


=head2 get_name

  Usage: my $name = $matrix->get_name();

  Desc: Get the Matrix name for a YapRI::Data::Matrix object

  Ret: $name, a scalar

  Args: None    
        
  Side_Effects: None

  Example: my $name = $matrix->get_name();
          
=cut

sub get_name {
    my $self = shift;
    return $self->{name};
}

=head2 set_name

  Usage: $matrix->set_name($name);

  Desc: Set the Matrix name for a YapRI::Data::Matrix object

  Ret: None

  Args: $name, an scalar    
        
  Side_Effects: Die if undef value is used 

  Example: $matrix->set_name($name);
          
=cut

sub set_name {
    my $self = shift;
    my $name = shift;

    unless (defined $name) {
	croak("ERROR: No defined name argument was supplied to set_name()");
    }

    $self->{name} = $name;
}


=head2 get_coln

  Usage: my $coln = $matrix->get_coln();

  Desc: Get the matrix column number for a YapRI::Data::Matrix object

  Ret: $coln, a scalar

  Args: None    
        
  Side_Effects: None

  Example: my $coln = $matrix->get_coln();
          
=cut

sub get_coln {
    my $self = shift;
    return $self->{coln};
}

=head2 set_coln

  Usage: $matrix->set_coln($coln);

  Desc: Set the matrix column number for a YapRI::Data::Matrix object

  Ret: None

  Args: $coln, an scalar    
        
  Side_Effects: Die if undef value is used.
                Die if colnum number is not a digit

  Example: $matrix->set_coln($coln);
          
=cut

sub set_coln {
    my $self = shift;
    my $coln = shift;

    unless (defined $coln) {
	croak("ERROR: No defined coln argument was supplied to set_coln()");
    }

    ## Let use '' as empty value but if it match with any character it 
    ## should be a digit

    if ($coln =~ m/^.+/) {
	unless ($coln =~ m/^\d+$/) {
	    croak("ERROR: $coln supplied to set_coln() isnt a digit.");
	}
    }

    $self->{coln} = $coln;
}


=head2 get_rown

  Usage: my $rown = $matrix->get_rown();

  Desc: Get the matrix row number for a YapRI::Data::Matrix object

  Ret: $rown, a scalar

  Args: None    
        
  Side_Effects: None

  Example: my $rown = $matrix->get_rown();
          
=cut

sub get_rown {
    my $self = shift;
    return $self->{rown};
}

=head2 set_rown

  Usage: $matrix->set_rown($rown);

  Desc: Set the matrix row number for a YapRI::Data::Matrix object

  Ret: None

  Args: $rown, an scalar    
        
  Side_Effects: Die if undef value is used.
                Die if rown number is not a digit

  Example: $matrix->set_rown($rown);
          
=cut

sub set_rown {
    my $self = shift;
    my $rown = shift;

    unless (defined $rown) {
	croak("ERROR: No defined rown argument was supplied to set_rown()");
    }

    ## Let use '' as empty value but if it match with any character it 
    ## should be a digit

    if ($rown =~ m/^.+/) {
	unless ($rown =~ m/^\d+$/) {
	    croak("ERROR: $rown supplied to set_rown() isnt a digit.");
	}
    }

    $self->{rown} = $rown;
}


=head2 get_colnames

  Usage: my $colnames_aref = $matrix->get_colnames();

  Desc: Get the Matrix column names array for a YapRI::Data::Matrix object

  Ret: $colnames_aref, an array reference with the column names

  Args: None    
        
  Side_Effects: None

  Example: my @colnames = @{$matrix->get_colnames()};
          
=cut

sub get_colnames {
    my $self = shift;
    return $self->{colnames};
}

=head2 set_colnames

  Usage: $matrix->set_colnames(\@colnames);

  Desc: Set the matrix column names array for a YapRI::Data::Matrix object

  Ret: None

  Args: $col_names_aref, an array reference with the column names
        
  Side_Effects: Die if undef value is used
                Die if argument is not an array reference.
                Die if number of element in the array isnt equal to coln value.
                (except if colnumber is empty)

  Example: $matrix->set_colnames(['col1', 'col2']);
          
=cut

sub set_colnames {
    my $self = shift;
    my $colnam_aref = shift ||
	croak("ERROR: No colname_aref argument was supplied to set_colnames()");

    if (ref($colnam_aref) ne 'ARRAY') {
	croak("ERROR: $colnam_aref supplied to set_colnames() isnt ARRAYREF.");
    }
    my $namesn = scalar(@{$colnam_aref});
    
    ## Check that is has the same number of elelemnts than coln

    my $coln = $self->get_coln();
    if ($coln =~ m/^\d+$/ && $namesn > 0) {
	unless ($namesn == $coln) {
	    croak("ERROR: Different number of names and cols for set_colnames");
	}
    }

    $self->{colnames} = $colnam_aref;
}


=head2 get_rownames

  Usage: my $rownames_aref = $matrix->get_rownames();

  Desc: Get the Matrix row names array for a YapRI::Data::Matrix object

  Ret: $rownames_aref, an array reference with the row names

  Args: None    
        
  Side_Effects: None

  Example: my @rownames = @{$matrix->get_rownames()};
          
=cut

sub get_rownames {
    my $self = shift;
    return $self->{rownames};
}

=head2 set_rownames

  Usage: $matrix->set_rownames(\@rownames);

  Desc: Set the matrix row names array for a YapRI::Data::Matrix object

  Ret: None

  Args: $row_names_aref, an array reference with the row names
        
  Side_Effects: Die if undef value is used
                Die if argument is not an array reference.
                Die if number of element in the array isnt equal to rown value.
                (except if rownumber is empty)

  Example: $matrix->set_rownames(['row1', 'row2']);
          
=cut

sub set_rownames {
    my $self = shift;
    my $rownam_aref = shift ||
	croak("ERROR: No rowname_aref argument was supplied to set_rownames()");

    if (ref($rownam_aref) ne 'ARRAY') {
	croak("ERROR: $rownam_aref supplied to set_rownames() isnt ARRAYREF.");
    }
    my $namesn = scalar(@{$rownam_aref});
    
    ## Check that is has the same number of elelemnts than coln

    my $rown = $self->get_rown();
    if ($rown =~ m/^\d+$/ && $namesn > 0) {
	unless ($namesn == $rown) {
	    croak("ERROR: Different number of names and rows for set_rownames");
	}
    }

    $self->{rownames} = $rownam_aref;
}


=head2 get_data

  Usage: my $data_aref = $matrix->get_data();

  Desc: Get the matrix data array for a YapRI::Data::Matrix object.
        The data is stored as an array ordered by rows.

        Example: Matrix  |1 2 3|  => [1, 2, 3, 4, 5, 6]
                         |4 5 6|
 
  Ret: $data_aref, an array reference with the data as array

  Args: None    
        
  Side_Effects: None

  Example: my @data = @{$matrix->get_data()};
          
=cut

sub get_data {
    my $self = shift;
    return $self->{data};
}

=head2 set_data

  Usage: $matrix->set_data(\@data);

  Desc: Set the matrix data array for a YapRI::Data::Matrix object

  Ret: None

  Args: $data, an array reference with the data ordered by rows

         Example: Matrix  |1 2 3|  => [1, 2, 3, 4, 5, 6]
                          |4 5 6|
        
  Side_Effects: Die if undef value is used
                Die if argument is not an array reference.
                Die if number of element in the array isnt equal to  
                coln x rown (for example if coln=3 and rown=2, it should have
                6 elements)

  Example: $matrix->set_data([1, 2, 3, 4]);
          
=cut

sub set_data {
    my $self = shift;
    my $data_aref = shift ||
	croak("ERROR: No data_aref argument was supplied to set_data()");

    if (ref($data_aref) ne 'ARRAY') {
	croak("ERROR: $data_aref supplied to set_data() isnt ARRAYREF.");
    }
    my $data_n = scalar(@{$data_aref});
    
    ## Check that is has the same number of elements than coln x rown

    my $coln = $self->get_coln();
    my $rown = $self->get_rown();
    
    if ($coln =~ m/^\d+$/ && $rown =~ m/^\d+$/ && $data_n > 0) {
	my $elems = $coln * $rown;
	if ($data_n != $elems) {
	    croak("ERROR: data_n = $data_n != ($rown x $coln) to set_data().");
	}
    }

    $self->{data} = $data_aref;
}





####
1; #
####
