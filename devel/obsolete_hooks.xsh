#!/usr/bin/env xsh2

quiet;
open documentation/manual/tred.xml;
perl { 
  open my$f,"devel/grep_hooks.sh|"; 
  $hooks = { map {chomp; $_ => 1} <$f> };
};

for (id('hooks')/table/tgroup/tbody/row/@id) {
  my $id = string(.);
  unless { $hooks->{$id} } echo $id
}