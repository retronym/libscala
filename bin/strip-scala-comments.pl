#!/usr/bin/env perl
#
# print given scala sources without comments
# does not handle nested comments yet
# 

use File::Slurp;

foreach my $arg (@ARGV) {
  my $text = read_file($arg);
  $text =~ s/\/\*(.*?)\*\///sg;
  $text =~ s/\/\/(.*?)$//smg;
  $text =~ s/\n\s*\n( *)/\n\n\1/smg;
  print $text, "\n";
}
