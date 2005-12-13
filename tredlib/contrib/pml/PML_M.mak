# -*- cperl -*-

#ifndef PML_M
#define PML_M

#include "PML.mak"

package PML_M;

#encoding iso-8859-2

import PML;
sub first (&@);

=pod

=head1 PML_M

PML_M.mak - Miscellaneous macros for the morphological layer of the Prague
Dependency Treebank (PDT) 2.0.

=over 4

=cut


=item GetSentenceString($tree?)

Return the original sentence string.

=cut

sub GetSentenceString {
  my $node = $_[0]||$this;
  $node=$node->root->following;
  my @sent=();
  while ($node) {
    push @sent,$node;
    $node=$node->following();
  }
  return join('',map{
    $_->attr('#content/form').($_->attr('#content/w/no_space_after')?'':' ')
  } sort { $a->{ord} <=> $b->{ord} } @sent);
}#GetSentenceString

=item CreateStylesheets()

Creates default stylesheet for PML analytical files unless already
defined. Most of the colors it uses can be redefined in the tred
config file C<.tredrc> by adding a line of the form

  CustomColorsomething = ...

The stylesheet is named C<PML_A> and it has the following display
features:

=over 4

1. sentence is displayed in C<CustomColorsentence>. If the form was
changed (e.g. because of a typo), the original form is displayed in
C<CustomColorspell> with overstrike.

2. analytical function is displayed in C<CustomColorafun>. If the
node's C<is_member> is set to 1, the type of the structure is
indicated by C<Co> (coordination) or C<Ap> (apposition) in
C<CustomColorcoappa>. For C<is_parenthesis_root>, C<Pa> is displayed
in the same color.

=back

=cut

sub CreateStylesheets {
  unless(StylesheetExists('PML_M')){
    SetStylesheetPatterns(<<'EOF','PML_M',1);
text:<? $${#content/w/token}eq$${#content/form} ?
  '#{'.CustomColor('sentence').'}${#content/w/token}' :
  '#{-over:1}#{'.CustomColor('spell').'}['.
     join(" ",map { $_->{token} } ListV($this->attr('#content/w'))).
  ']#{-over:0}#{'.CustomColor('sentence').'}${#content/form}' ?>

node:#{customform}<? $${#name} eq "s" ? '${id}' : '${#content/form}' ?>

node:#{custommlemma}${#content/lemma}

node:#{customtag}${#content/tag}

style: #{Line-coords:n,n,n,n}

EOF
  }
}

sub node_release_hook{
  return 'stop';
}#node_release_hook

sub enable_attr_hook{
  return'stop';
}#enable_attr_hook


sub allow_switch_context_hook {
  return 'stop' if SchemaName() !~ /^m(?:edit)?data$/;
}
sub switch_context_hook {
  CreateStylesheets();
  my $cur_stylesheet = GetCurrentStylesheet();
  SetCurrentStylesheet('PML_M')
    if $cur_stylesheet eq STYLESHEET_FROM_FILE() or
       $cur_stylesheet =~ /^PML_T(?:_|\b)/;
}

1;

=back

=cut

#endif PML_M
