package Dist::Zilla::Plugin::BuildSelf;
BEGIN {
  $Dist::Zilla::Plugin::BuildSelf::VERSION = '0.001';
}

use Moose;
with qw/Dist::Zilla::Role::BuildPL Dist::Zilla::Role::TextTemplate Dist::Zilla::Role::PrereqSource/;

use Dist::Zilla::File::InMemory;

has template => (
	is  => 'ro',
	isa => 'Str',
	default => "use lib 'lib';\nuse {{ \$module }} {{ \$version }};\nBuild_PL(\@ARGV);\n",
);

has module => (
	is => 'ro',
	isa => 'Str',
	builder => '_module_builder',
	lazy => 1,
);

sub _module_builder {
	my $self = shift;
	(my $name = $self->zilla->name) =~ s/-/::/g;
	return $name;
}

has version => (
	is  => 'ro',
	isa => 'Str',
	default => '',
);

sub register_prereqs {
	my ($self) = @_;

	my $reqs = $self->zilla->prereqs->requirements_for('runtime', 'requires');
	$self->zilla->register_prereqs({ phase => 'configure' }, %{ $reqs->as_string_hash });

	return;
}

sub setup_installer {
	my ($self, $arg) = @_;

	my $content = $self->fill_in_string($self->template, { module => $self->module, version => $self->version });
	my $file = Dist::Zilla::File::InMemory->new({ name => 'Build.PL', content => $content });
	$self->add_file($file);

	return;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

# ABSTRACT: Build a Build.PL that uses the current module to build itself


__END__
=pod

=head1 NAME

Dist::Zilla::Plugin::BuildSelf - Build a Build.PL that uses the current module to build itself

=head1 VERSION

version 0.001

=head1 DESCRIPTION

Unless you're writing a Build.PL compatible module builder, you should not be looking at this. The only purpose of this module is to bootstrap any such module on Dist::Zilla.

=head1 ATTRIBUTES

=head2 module

The module used to build the current module. Defaults to the main module of the current distribution.

=head2 version

The minimal version of the module, if any. Defaults to none.

=head2 template

The template to use for the Build.PL script. This is a Text::Template string with two arguments as described above: C<$module> and C<$version>. Default is typical for the authors Build.PL ideas, YMMV.

=for Pod::Coverage register_prereqs
setup_installer
=end

=head1 AUTHOR

Leon Timmermans <leont@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Leon Timmermans.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

