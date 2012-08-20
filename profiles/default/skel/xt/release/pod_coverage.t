use strict;
use warnings;
use Test::More;
BEGIN { 
  plan skip_all => 'test requires Test::Pod::Coverage' 
    unless eval q{ use Test::Pod::Coverage; 1 };
  plan skip_all => 'test requires YAML'
    unless eval q{ use YAML; 1; };
};
use Test::Pod::Coverage;
use YAML qw( LoadFile );
use FindBin;
use File::Spec;

my $config_filename = File::Spec->catfile(
  $FindBin::Bin, 'release.yml'
);

my $config;
$config = LoadFile($config_filename)
  if -r $config_filename;

chdir(File::Spec->catdir($FindBin::Bin, File::Spec->updir, File::Spec->updir));

my %private_classes;
my %private_methods;

foreach my $private (@{ $config->{pod_coverage}->{private} })
{
  my($class, $method) = split /#/, $private;
  if(defined $class && defined $method
  && $class && $method)
  {
    $private_classes{$class}->{$method} = 1;
  }
  elsif(defined $method && $method && $class eq '')
  {
    $private_methods{$method} = 1;
  }
  elsif(defined $class && $class)
  {
    $private_classes{$class} = 1;
  }
}

my %also_private;

while(my($class_name, $class_methods) = each %private_classes)
{
  if(ref($class_methods) eq 'HASH')
  {
    my %private = map {; $_ => 1 } ((keys %$class_methods),(keys %private_methods));
    $also_private{$class_name} = 
      eval 'qr{^' . join('|', keys %private) . '$}';
  }
  else
  {
    $also_private{$class_name} = qr{.*};
  }
}

my $global_also_private = eval 'qr{^' . join('|', keys %private_methods) . '$}';

#diag YAML::Dump({
#  private_classes => \%private_classes,
#  private_methods => \%private_methods,
#  also_private    => \%also_private,
#});

foreach my $class (all_modules())
{
  my $also_private = $also_private{$class} || $global_also_private;
  #diag $also_private;
  pod_coverage_ok $class, { also_private => [$also_private] };
}

done_testing;
