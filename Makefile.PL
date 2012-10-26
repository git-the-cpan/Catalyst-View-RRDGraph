
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "RRD Graph View Class",
  "AUTHOR" => "Jose Luis Martinez Torres <jlmartin\@cpan.org>",
  "BUILD_REQUIRES" => {
    "Catalyst::Test" => 0,
    "Test::MockObject" => 0,
    "Test::More" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Catalyst-View-RRDGraph",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Catalyst::View::RRDGraph",
  "PREREQ_PM" => {
    "Catalyst::Plugin::Static::Simple" => 0,
    "Catalyst::Runtime" => "5.7",
    "MRO::Compat" => 0
  },
  "VERSION" => "0.06",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



