use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'      => 'Sledge::Plugin::Download',
    'VERSION_FROM' => 'lib/Sledge/Plugin/Download.pm', # finds $VERSION
    'PREREQ_PM' => {
	Test::More => 0.32,
    },
);
