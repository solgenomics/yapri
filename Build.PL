use strict;
use Module::Build;

my $build = Module::Build->new(
    module_name        => 'R::YapRI',
    dist_name          => 'R::YapRI',
    dist_author        => 'Aureliano Bombarely',
    dist_abstract      => 'Yet another perl R interface',
    license            => 'perl',
    create_makefile_pl => 'passthrough',

    # current version of our core libraries distribution
    dist_version => '0.01',

    recursive_test_files => 1,

    # and now the list of perl module dependencies

    requires => {
        'perl'               => '5.10.0',
    },

    build_requires => {
        'Test::More'         => 0,
        'Test::Exception'    => 0,
	'Test::Warn'         => 0,
	'Image::Size'        => 0,
    },
);

$build->create_build_script;



###
1;#
###
