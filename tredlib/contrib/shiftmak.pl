#!/usr/bin/perl
# -*- cperl -*-
#
################################################################################
use strict;

use vars qw($version $timestamp $about $lastupdate $opt_h
		$szMacroName $szMacroKey $szMenu
                @rgszPrefixes
                $fCtrl $fAlt $fShift
		$szPrefix $iPrefix $PREFSZALT $PREFSZSHIFT $PREFSZCTRL
		$szKeysym $szLine
                %hNames $fCheckNames $szFileName $iRCopen
                $szPN
           );

$version='$Revision$ ';
$timestamp="Time-stamp: <2001-07-27 14:45:25 pajas>";
$about=
  "Copyright (c) 2001 by Jan Hajic\n".
  "This software is distributed under GPL - The General Public Licence\n".
  "Full text of the GPL can be found at
http://www.gnu.org/copyleft/gpl.html"; $lastupdate=$1 if
($timestamp=~/\<([0-9-: ]+) /);
################################################################################
# # This is a conversion tool for changing macro names (assignments by
# the #bind command) from conventions and system used in the old GRAPH
# program to a new, more transparent system, as defined by P. Pajas 
# and J. Hajic on Jan 10, 2002. It is tightly related to input key
# processing by tred. Once changed, the macros will not run with
# previous version of tred ('$Revision$ '; <2001-07-27
# 14:45:25 pajas>) or earlier, and vice versa.  
# 
# The "old" system uses the Shift (and Ctrl and Alt) indicators to modify 
# the meaning of the key pressed. However, in connection with foreign 
# keyboards this had lead to disabling some keys if the Shift+key
# combination corresponds in fact to other symbols, such as !, & etc.
# 
# In the new system, the Shift is allowed in macro assignemnts for Fn keys
# only. If pressed with any other key while working in tred, it is 
# processed by the installed keyboard and only the keysym is taken 
# into consideration by tred. In all cases, it can be freely combined
# with Ctrl and Alt modifiers as it has been done so far.
#
# Therefore, to bind all keys in the ASCII range 32-126, the #bind 
# assignment must specify the symbol proper, regardless of how it is 
# pressed on the keyboard. E.g., instead of "Shift+1", the symbol should
# be "exclam", instead of "Shift+semicolon" it should be "colon", etc.
# For the same reason, letters should use the proper case ("d" instead
# of "D"), and "Shift+T" should read "T".
#
# The casing of the modifier identifiers (Shift, Ctrl, Alt) is unimportant;
# all other capitalization is left intact and therefore should correspond
# exactly to the X11 keysym names (i.e. even the "long" names for symbols
# such as exclam are expected to be in lowercase; the case is not checked
# nor changed!! -> therefore if the case is not all lower with Shift-ed
# keys, this program will not work for those!!)
#
#
################################################################################
#
# Usage:
# shifmak.pl < <InputMacroFile> > <OutputMacroFile>
#
# or
#
# shiftmak.pl -h (or anything :) for help
#
#
################################################################################

# constants:
$PREFSZSHIFT = "SHIFT"; # uc prefix name and keysym prefix Shift
$PREFSZALT= "ALT"; # uc prefix name and keysym prefix Alt
$PREFSZCTRL = "CTRL"; # uc prefix name and keysym prefix Ctrl

$szPN = $0;

$fCheckNames = 0;
if ($#ARGV >= 0) {
  if ("$ARGV[0]" eq "--CheckNames") {
    $szFileName = "<" . $ARGV[1];

####  print STDERR "$szPN: Opening Dictionary $szFileName", "\n";

    $iRCopen = open(NAMELIST,$szFileName);
    if (!defined $iRCopen) { # check if open ok
      print STDERR "$szPN: Cannot open file $szFileName.\n"; 
      exit 2;
    }
    # read the keysym names one line at a time:
    while (<NAMELIST>) {
      chomp; # get rid of final whitespace incl. newline
      if ("$_" eq "") { next; }
      $hNames{$_} = 1;
    }
    $fCheckNames = 1;
  }
  else {
    print STDERR "Usage: $szPN [--CheckNames <file>] < <InputMacroFile> > <OutputMacroFile>\n";
    exit 1;
  }
}

while (<STDIN>) {

  # check if input line is a #bind command:
  $szLine = $_;
  chomp $szLine;

  if ($szLine =~ /\#[ \t]*bind[ \t]+(\w*)[ \t]+(?:to[ \t]+)?(?:key(?:sym)?[ \t]+)?([^ \t\r\n]+)(?:[ \t]+menu[ \t]+(.+))?/) {

    # keep parsed parts of the #bind command:
    $szMacroName = $1;
    $szMacroKey = $2;
    $szMenu = $3;
    # get modifier prefixes of the assigned keysym if any:
    @rgszPrefixes = split /[+]/, $szMacroKey;
####    print "$szMacroKey", "##", $#rgszPrefixes, "::", "$rgszPrefixes[0]", "::", "$rgszPrefixes[1]", "::", "$rgszPrefixes[2]", "\n";
    # initalize prefix flags:
    $fShift = 0;
    $fAlt = 0;
    $fCtrl = 0;
    # get prefix flags for prefixes present in the keysym string:
    for ($iPrefix = 0; $iPrefix < $#rgszPrefixes; $iPrefix++) {
      $_ = uc $rgszPrefixes[$iPrefix];
      SetPrefixFlag: {
        /$PREFSZSHIFT/ && do { $fShift = 1; last SetPrefixFlag; };
        /$PREFSZCTRL/ && do { $fCtrl = 1; last SetPrefixFlag; };
        /$PREFSZALT/ && do { $fAlt = 1; last SetPrefixFlag; };
        print STDERR "$szPN: Error: $szMacroName, $szMacroKey: improper key prefix\n";
        exit 2;
      }
    }
####    print "flags: $fShift, $fCtrl, $fAlt.\n";
    # get the keysym proper:
    $szKeysym = $rgszPrefixes[$#rgszPrefixes];
    # now, work on it finally; update $fFlags adn $szKeysym in place,
    #   then join them back.
    # first, solve Shift-ed cases:
    if ($fShift == 1) {
      if ($szKeysym =~ /^[a-zA-Z]$/) { # single letter key with shift; 
        $szKeysym = uc $szKeysym; # output as uppercase key alone
        $fShift = 0;
      }
      # block of digit 0..9 changes to the corresponding keys follows:
      elsif ("$szKeysym" eq "1") { $szKeysym = "exclam"; $fShift = 0; }
      elsif ("$szKeysym" eq "2") { $szKeysym = "at"; $fShift = 0; }
      elsif ("$szKeysym" eq "3") { $szKeysym = "numbersign"; $fShift = 0; }
      elsif ("$szKeysym" eq "4") { $szKeysym = "dollar"; $fShift = 0; }
      elsif ("$szKeysym" eq "5") { $szKeysym = "percent"; $fShift = 0; }
      elsif ("$szKeysym" eq "6") { $szKeysym = "asciicircum"; $fShift = 0; }
      elsif ("$szKeysym" eq "7") { $szKeysym = "ampersand"; $fShift = 0; }
      elsif ("$szKeysym" eq "8") { $szKeysym = "asterisk"; $fShift = 0; }
      elsif ("$szKeysym" eq "9") { $szKeysym = "parenleft"; $fShift = 0; }
      elsif ("$szKeysym" eq "0") { $szKeysym = "parenright"; $fShift = 0; }
      # now other symbols that had been handled by "low" symbol + shift:
      elsif ("$szKeysym" eq "grave") { $szKeysym = "asciitilde"; $fShift = 0; }
      elsif ("$szKeysym" eq "quoteleft") { $szKeysym = "asciitilde"; $fShift = 0; }
      elsif ("$szKeysym" eq "minus") { $szKeysym = "underscore"; $fShift = 0; }
      elsif ("$szKeysym" eq "equal") { $szKeysym = "plus"; $fShift = 0; }
      elsif ("$szKeysym" eq "bracketleft") { $szKeysym = "braceleft"; $fShift = 0; }
      elsif ("$szKeysym" eq "bracketright") { $szKeysym = "braceright"; $fShift = 0; }
      elsif ("$szKeysym" eq "backslash") { $szKeysym = "bar"; $fShift = 0; }
      elsif ("$szKeysym" eq "semicolon") { $szKeysym = "colon"; $fShift = 0; }
      elsif ("$szKeysym" eq "apostrophe") { $szKeysym = "quotedbl"; $fShift = 0; }
      elsif ("$szKeysym" eq "quoteright") { $szKeysym = "quotedbl"; $fShift = 0; }
      elsif ("$szKeysym" eq "comma") { $szKeysym = "less"; $fShift = 0; }
      elsif ("$szKeysym" eq "period") { $szKeysym = "greater"; $fShift = 0; }
      elsif ("$szKeysym" eq "slash") { $szKeysym = "question"; $fShift = 0; }
      # just in case: "upper" keys originally shifted, too:
      elsif ("$szKeysym" eq "exclam") { $szKeysym = "exclam"; $fShift = 0; }
      elsif ("$szKeysym" eq "at") { $szKeysym = "at"; $fShift = 0; }
      elsif ("$szKeysym" eq "numbersign") { $szKeysym = "numbersign"; $fShift = 0; }
      elsif ("$szKeysym" eq "dollar") { $szKeysym = "dollar"; $fShift = 0; }
      elsif ("$szKeysym" eq "percent") { $szKeysym = "percent"; $fShift = 0; }
      elsif ("$szKeysym" eq "asciicircum") { $szKeysym = "asciicircum"; $fShift = 0; }
      elsif ("$szKeysym" eq "ampersand") { $szKeysym = "ampersand"; $fShift = 0; }
      elsif ("$szKeysym" eq "asterisk") { $szKeysym = "asterisk"; $fShift = 0; }
      elsif ("$szKeysym" eq "parenleft") { $szKeysym = "parenleft"; $fShift = 0; }
      elsif ("$szKeysym" eq "parenright") { $szKeysym = "parenright"; $fShift = 0; }
      elsif ("$szKeysym" eq "asciitilde") { $szKeysym = "asciitilde"; $fShift = 0; }
      elsif ("$szKeysym" eq "underscore") { $szKeysym = "underscore"; $fShift = 0; }
      elsif ("$szKeysym" eq "plus") { $szKeysym = "plus"; $fShift = 0; }
      elsif ("$szKeysym" eq "braceleft") { $szKeysym = "braceleft"; $fShift = 0; }
      elsif ("$szKeysym" eq "braceright") { $szKeysym = "braceright"; $fShift = 0; }
      elsif ("$szKeysym" eq "bar") { $szKeysym = "bar"; $fShift = 0; }
      elsif ("$szKeysym" eq "colon") { $szKeysym = "colon"; $fShift = 0; }
      elsif ("$szKeysym" eq "quotedbl") { $szKeysym = "quotedbl"; $fShift = 0; }
      elsif ("$szKeysym" eq "less") { $szKeysym = "less"; $fShift = 0; }
      elsif ("$szKeysym" eq "greater") { $szKeysym = "greater"; $fShift = 0; }
      elsif ("$szKeysym" eq "question") { $szKeysym = "question"; $fShift = 0; }
      # else keep everything as is (in the Shift-ed case)!

    } # end of Shift-ed cases
    else { # fShift not set:
      # only check case of letters, and change it to lowercase if needed:
      if ($szKeysym =~ /^[A-Z]$/) { # single uc letter key without shift
        $szKeysym = lc $szKeysym; # output as uppercase key alone
      }
    } # of else fShift ... (fShift not set)
    # check new keysym:
    if ($hNames{$szKeysym} != 1) { # not found !?
      print STDERR "$szPN: Warning: key $szKeysym not found in keysymdef.h.\n";
    }
    # now print out the modified #bind command:
    print "#bind ", "$szMacroName", " to ";
    if ($fCtrl == 1) { print "Ctrl+"; }
    if ($fAlt == 1) { print "Alt+"; }
    if ($fShift == 1) { print "Shift+"; }
    print "$szKeysym";
    if ("$szMenu" ne "") { print " menu $szMenu"; }
    print "\n";
  } # of if line is a #bind command
  else {
    print "$szLine", "\n";
  }
} # of outer file reading loop (<STDIN>)

0;


