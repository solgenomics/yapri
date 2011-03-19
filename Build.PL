use strict;
use Module::Build;

my $build = Module::Build->new(
    module_name        => 'R::YapRI',
    dist_name          => 'R-YapRI',
    dist_author        => 'Aureliano Bombarely',
    dist_abstract      => 'Yet another perl R interface',
    license            => 'perl',

    # current version of our core libraries distribution
    dist_version => '0.07',

    recursive_test_files => 1,

    # and now the list of perl module dependencies

    requires => {
        'perl'               => '5.8.0',
    },
    
    meta_merge => {
	resources => {
	    repository => 'https://github.com/solgenomics/yapri',
	},
    },

    build_requires => {
        'Test::More'         => 0,
        'Test::Exception'    => 0,
	'Test::Warn'         => 0,
	'Image::Size'        => 0,
	'String::Random'     => 0,
	'autodie'            => 0,
	'File::Path'         => 2.0,
    },
);

$build->create_build_script;



###
1;#
###
