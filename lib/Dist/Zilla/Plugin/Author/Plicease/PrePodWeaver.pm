package Dist::Zilla::Plugin::Author::Plicease::PrePodWeaver;

use Moose;
use v5.10;

# ABSTRACT: Dist::Zilla::Plugin::Author::Plicease::PrePodWeaver
# VERSION

=head1 SYNOPIS

 [Author::Plicease::PrePodWeaver]

=cut

with 'Dist::Zilla::Role::FileMunger';

sub munge_files
{
  my($self) = @_;
  
  foreach my $file (@{ $self->zilla->files })
  {
    my $script = 0;
    if($file->name =~ m{^bin/})
    {
      $script = 1;
    }
    elsif($file->name =~ m{^lib/.*\.pm$})
    {
      $script = 0;
    }
    else
    {
      next;
    }
    
    my $podname;
    my $version;
    my $abstract;
    my @lines = split /\n\r?/, $file->content;
    
    foreach my $linenumber (0.. $#lines)
    {
      my $line  = $lines[$linenumber];
      $podname  = $linenumber if $line =~ /^# PODNAME:/;
      $version  = $linenumber if $line =~ /^# VERSION\s*$/;
      $abstract = $linenumber if $line =~ /^# ABSTRACT:/;
    }
    
    if(! defined $abstract)
    {
      $self->log("can't find abstract in " . $file->name);
      next;
    }
    
    if($script && ! defined $podname)
    {
      my $name = $file->name;
      $name =~ s/^.*\///;
      $self->log("adding missing podname from " . $file->name . " [$name]");
      splice @lines, $abstract, 0, ("# PODNAME: $name");
      $abstract++;
    }
    
    if(! defined $version)
    {
      $self->log("adding missing version from " . $file->name);
      splice @lines, $abstract+1, 0, ("# VERSION");
    }
    
    $file->content(join "\n", @lines);
  }
}

__PACKAGE__->meta->make_immutable;

1;
