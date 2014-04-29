use 5.008;
use strict;
use warnings;

package Dist::Zilla::Plugin::InstallGuide;

# ABSTRACT: Build an INSTALL file
our $VERSION = '1.200003'; # VERSION
use Moose;
use Moose::Autobox;
with 'Dist::Zilla::Role::FileGatherer';
with 'Dist::Zilla::Role::TextTemplate';


my $template = q|
This is the Perl distribution {{ $dist->name }}.

Installing {{ $dist->name }} is straightforward.

## Installation with cpanm

If you have cpanm, you only need one line:

    % cpanm {{ $package }}

If you are installing into a system-wide directory, you may need to pass the
"-S" flag to cpanm, which uses sudo to install the module:

    % cpanm -S {{ $package }}

## Installing with the CPAN shell

Alternatively, if your CPAN shell is set up, you should just be able to do:

    % cpan {{ $package }}

## Manual installation
{{ $manual_installation }}
## Documentation

{{ $dist->name }} documentation is available as POD.
You can run perldoc from a shell to read the documentation:

    % perldoc {{ $package }}
|;

my $makemaker_manual_installation = q|
As a last resort, you can manually install it. Download the tarball, untar it,
then build it:

    % perl Makefile.PL
    % make && make test

Then install it:

    % make install

If you are installing into a system-wide directory, you may need to run:

    % sudo make install
|;

my $module_build_manual_installation = q|
As a last resort, you can manually install it. Download the tarball, untar it,
then build it:

    % perl Build.PL
    % ./Build && ./Build test

Then install it:

    % ./Build install

If you are installing into a system-wide directory, you may need to run:

    % sudo ./Build install
|;


sub gather_files {
    my $self = shift;

    require Dist::Zilla::File::FromCode;

    my $zilla = $self->zilla;
    $self->add_file(Dist::Zilla::File::FromCode->new({
        name => 'INSTALL',
        code => sub {
            my $manual_installation = '';

            my %installer = map { $_->name => 1 }
                grep { $_->name eq 'Makefile.PL' or $_->name eq 'Build.PL' }
                @{ $zilla->files };

            if ($installer{'Build.PL'}) {
                $manual_installation .= $module_build_manual_installation;
            }
            elsif ($installer{'Makefile.PL'}) {
                $manual_installation .= $makemaker_manual_installation;
            }
            unless ($manual_installation) {
                $self->log_fatal('neither Makefile.PL nor Build.PL is present, aborting');
            }

            (my $main_package = $zilla->name) =~ s!-!::!g;

            my $content = $self->fill_in_string(
                $template,
                {   dist                => \$zilla,
                    package             => $main_package,
                    manual_installation => $manual_installation
                }
            );
            return $content;
        },
    }));

    return;
}
__PACKAGE__->meta->make_immutable;
no Moose;
1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Dist::Zilla::Plugin::InstallGuide - Build an INSTALL file

=head1 VERSION

version 1.200003

=head1 SYNOPSIS

In C<dist.ini>:

    [InstallGuide]

=head1 DESCRIPTION

This plugin adds a very simple F<INSTALL> file to the distribution, telling
the user how to install this distribution.

You should use this plugin in your L<Dist::Zilla> configuration after
C<[MakeMaker]> or C<[ModuleBuild]> so that it can determine what kind of
distribution you are building and which installation instructions are
appropriate.

=head1 METHODS

=head2 gather_files

Creates the C<INSTALL> file and prepare its contents, which will be finalized
near the end of the build process.

=for test_synopsis 1;
__END__

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit L<http://www.perl.com/CPAN/> to find a CPAN
site near you, or see L<https://metacpan.org/module/Dist::Zilla::Plugin::InstallGuide/>.

=head1 SOURCE

The development version is on github at L<http://github.com/doherty/Dist-Zilla-Plugin-InstallGuide>
and may be cloned from L<git://github.com/doherty/Dist-Zilla-Plugin-InstallGuide.git>

=head1 BUGS AND LIMITATIONS

You can make new bug reports, and view existing ones, through the
web interface at L<https://github.com/doherty/Dist-Zilla-Plugin-InstallGuide/issues>.

=head1 AUTHORS

=over 4

=item *

Marcel Grünauer <marcel@cpan.org>

=item *

Mike Doherty <doherty@cpan.org>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Marcel Grünauer <marcel@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
