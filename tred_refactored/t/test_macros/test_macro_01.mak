# test macro file no 1
# test if ifdef, ifndef works

#ifdef TRED

sub tred_defined {
	print("TRED is defined\n");
}

#endif


#ifndef NTRED

sub ntred_not_defined {
	print("NTRED not defined\n");
}

#endif
