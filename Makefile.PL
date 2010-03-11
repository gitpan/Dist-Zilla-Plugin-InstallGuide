
use strict;
use warnings;

 BEGIN { require 5.008; } 

use ExtUtils::MakeMaker 6.11;



my %WriteMakefileArgs = (
                       'test' => {
                                   'TESTS' => 't/*.t'
                                 },
                       'NAME' => 'Dist::Zilla::Plugin::InstallGuide',
                       'DISTNAME' => 'Dist-Zilla-Plugin-InstallGuide',
                       'CONFIGURE_REQUIRES' => {
                                                 'ExtUtils::MakeMaker' => '6.11'
                                               },
                       'AUTHOR' => 'Marcel Gruenauer <marcel@cpan.org>',
                       'BUILD_REQUIRES' => {},
                       'ABSTRACT' => 'build an INSTALL file',
                       'EXE_FILES' => [],
                       'VERSION' => '1.100700',
                       'PREREQ_PM' => {
                                        'Dist::Zilla::Role::TextTemplate' => '0',
                                        'Dist::Zilla::Role::FileGatherer' => '0',
                                        'Test::More' => '0',
                                        'English' => '0',
                                        'File::Find' => '0',
                                        'File::Temp' => '0',
                                        'Dist::Zilla::File::InMemory' => '0',
                                        'Moose::Autobox' => '0',
                                        'Moose' => '0'
                                      },
                       'LICENSE' => 'perl'
                     );


delete $WriteMakefileArgs{LICENSE}
  unless eval { ExtUtils::MakeMaker->VERSION(6.31) };

WriteMakefile(%WriteMakefileArgs);



