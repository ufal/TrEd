#!/usr/bin/env xsh2
# -*- cperl -*-
quiet;
my $out := create 'variablelist';

foreach ($INPUT//tbody[1]) {
  foreach row {
    my $c := insert chunk <<'EOF' into $out/variablelist;
  <varlistentry>
  <term></term>
  <listitem>
  </listitem>
  </varlistentry>
EOF
    xcopy entry[1]/node() into $c/term;
    xcopy entry[2]/node() into $c/listitem;
  }
}

ls $out;
