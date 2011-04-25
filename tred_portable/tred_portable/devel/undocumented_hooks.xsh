#!/usr/bin/env xsh2

quiet;
validation 1;
open documentation/manual/tred.xml;
my $IDs := hash @id //*;
for my $id in { open my$f,"devel/grep_hooks.sh|"; my @f=<$f>; chomp @f; @f } { 
  unless { exists $IDs->{$id} } echo $id
}
