#!/usr/bin/env xsh2

quiet;
open documentation/manual/tred.xml;
for my $id in { open my$f,"devel/grep_hooks.sh|"; my @f=<$f>; chomp @f; @f } { 
  unless id($id) echo $id
}
