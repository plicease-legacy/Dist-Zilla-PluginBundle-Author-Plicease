use strict;
use warnings;
use Capture::Tiny qw( capture_stdout );
use Path::Class qw( file );

my($out ) = capture_stdout {
  system($^X, '-Ilib', 'example/unbundle.pl', '--default');
  die "failed" unless $? == 0;
};

file('example', 'default_dist.ini')->spew($out);
