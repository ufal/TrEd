# -*- cperl -*- 
######## PDT specific stuff ########

package TredMacro;

#ifdef TRED
sub file_opened_hook {
    my $mode=GetSpecialPattern('mode');
    return unless $grp->{FSFile};
    if (defined($mode)) {
      return SwitchContext($mode);
    } elsif ($grp->{FSFile}->metaData('schema')) {
      return SwitchContext('PMLTectogrammatic');
    } elsif (exists($grp->{FSFile}->FS->defs->{x_TNT})
	     and $grp->{FSFile}->FS->hide eq 'X_hide') {
      return SwitchContext('Transfer');
    } elsif (exists($grp->{FSFile}->FS->defs->{x_origt}) and
	     exists($grp->{FSFile}->FS->defs->{x_origa})) {
      return SwitchContext('AcademicTreebank');
    } elsif ($grp->{FSFile}->FS->hide eq 'TR') {
      return SwitchContext('Tectogrammatic') 
	unless (CurrentContext eq 'TR_Correction' or
		CurrentContext eq 'TFA');
    } else {
      return SwitchContext('Analytic') unless CurrentContext eq 'Analytic_Correction';
    }
}
#endif
