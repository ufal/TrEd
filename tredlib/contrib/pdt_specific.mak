# -*- cperl -*- 
######## PDT specific stuff ########

package TredMacro;

#ifdef TRED
sub file_opened_hook {
    my ($mode)= GetPatternsByPrefix('mode',STYLESHEET_FROM_FILE());
    return unless $grp->{FSFile};
    if (defined($mode)) {
      return SwitchContext($mode);
    } elsif (PML::schema_name() eq 'tdata') {
      return SwitchContext('PML_T_View');
    } elsif (PML::schema_name() eq 'adata') {
      return SwitchContext('PML_A_View');
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
