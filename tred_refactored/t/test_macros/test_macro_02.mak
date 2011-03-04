# test macro file no 2
# define and undefine directives added
# test if ifdef, ifndef works as expected as in the previous example

#define NTRED
#undefine TRED
#define MTRED

#ifdef TRED

sub tred_defined {
	print("TRED is defined\n");
}

#elseif MTRED

sub mtred_elseif_defined {
	print("TRED is defined\n");
}


#endif


#ifndef NTRED

sub ntred_not_defined {
	print("NTRED not defined\n");
}

#endif
