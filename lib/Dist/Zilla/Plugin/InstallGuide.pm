use 5.008;
use strict;
use warnings;

package Dist::Zilla::Plugin::InstallGuide;
BEGIN {
  $Dist::Zilla::Plugin::InstallGuide::VERSION = '1.101460';
}

# ABSTRACT: Build an INSTALL file
use Moose;
use Moose::Autobox;
with 'Dist::Zilla::Role::InstallTool';
with 'Dist::Zilla::Role::TextTemplate';

my $template = q|
This is the Perl distribution {{ $dist->name }}.

## Installation

{{ $dist->name }} installation is straightforward.

### Installation with cpanm

If you have cpanm, you only need one line:

    % cpanm {{ $package }}

### Installating with the CPAN shell

Alternatively, if your CPAN shell is set up, you should just be able to do:

    % cpan {{ $package }}

### Manual installation
{{ $manual_installation }}
## Documentation

{{ $dist->name }} documentation is available as in POD.
So you can do:

    % perldoc {{ $package }}

to read the documentation with your favorite pager.
|;

my $makemaker_manual_installation = q|
As a last resort, you can manually install it. Download it, unpack it, then
build it as per the usual:

    % perl Makefile.PL
    % make && make test

Then install it:

    % make install
|;

my $module_build_manual_installation = q|
As a last resort, you can manually install it. Download it, unpack it, then
build it:

    % perl Build.PL
    % ./Build && ./Build test

Then install it:

    % ./Build install
|;

sub setup_installer {
    my $self = shift;
    my $manual_installation;
    for (@{ $self->zilla->files }) {
        if ($_->name eq 'Makefile.PL') {
            $manual_installation = $makemaker_manual_installation;
            last;
        } elsif ($_->name eq 'Build.PL') {
            $manual_installation = $module_build_manual_installation;
            last;
        }
    }
    unless (defined $manual_installation) {
        $self->log_fatal('neither Makefile.PL nor Build.PL is present, aborting');
    }
    require Dist::Zilla::File::InMemory;
    (my $main_package = $self->zilla->name) =~ s!-!::!g;
    my $content = $self->fill_in_string(
        $template,
        {   dist                => \($self->zilla),
            package             => $main_package,
            manual_installation => $manual_installation
        }
    );
    my $file = Dist::Zilla::File::InMemory->new(
        {   content => $content,
            name    => 'INSTALL',
        }
    );
    $self->add_file($file);
    return;
}
__PACKAGE__->meta->make_immutable;
no Moose;
1;


__END__
=pod

=head1 NAME

Dist::Zilla::Plugin::InstallGuide - Build an INSTALL file

=head1 VERSION

version 1.101460

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

=head1 FUNCTIONS

=head2 setup_installer

Builds and writes the C<INSTALL> file.

=for test_synopsis 1;
__END__

=head1 INSTALLATION

See perlmodinstall for information and options on installing Perl modules.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org/Public/Dist/Display.html?Name=Dist-Zilla-Plugin-InstallGuide>.

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit L<http://www.perl.com/CPAN/> to find a CPAN
site near you, or see
L<http://search.cpan.org/dist/Dist-Zilla-Plugin-InstallGuide/>.

The development version lives at
L<http://github.com/hanekomu/Dist-Zilla-Plugin-InstallGuide/>.
Instead of sending patches, please fork this project using the standard git
and github infrastructure.

=head1 AUTHOR

  Marcel Gruenauer <marcel@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Marcel Gruenauer.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

