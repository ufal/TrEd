# -*- cperl -*-

#include <tred.mac>

#binding-context TredMacro;

package TredMacro;

sub file_opened_hook {

    SwitchContext('Analytic');
}

#include "arabic_common.mak"

#include "Analytic.mak"

# ##################################################################################################
#
# ##################################################################################################

#unbind-key j
#remove-menu Assign afun AtvV
#unbind-key J
#remove-menu Assign afun AtvV_Ap
#unbind-key Ctrl+j
#remove-menu Assign afun AtvV_Co
#unbind-key Ctrl+J
#remove-menu Assign afun AtvV_Pa

#unbind-key j
#remove-menu Assign afun AtvV
#unbind-key J
#remove-menu Assign afun AtvV_Ap
#unbind-key Ctrl+j
#remove-menu Assign afun AtvV_Co
#unbind-key Ctrl+J
#remove-menu Assign afun AtvV_Pa

#unbind-key o
#remove-menu Assign afun AuxO
#unbind-key O
#remove-menu Assign afun AuxO_Ap
#unbind-key Ctrl+o
#remove-menu Assign afun AuxO_Co
#unbind-key Ctrl+O
#remove-menu Assign afun AuxO_Pa

#unbind-key r
#remove-menu Assign afun AuxR
#unbind-key R
#remove-menu Assign afun AuxR_Ap
#unbind-key Ctrl+r
#remove-menu Assign afun AuxR_Co
#unbind-key Ctrl+R
#remove-menu Assign afun AuxR_Pa

#unbind-key t
#remove-menu Assign afun AuxT
#unbind-key T
#remove-menu Assign afun AuxT_Ap
#unbind-key Ctrl+t
#remove-menu Assign afun AuxT_Co
#unbind-key Ctrl+T
#remove-menu Assign afun AuxT_Pa

#unbind-key v
#remove-menu Assign afun AuxV
#unbind-key V
#remove-menu Assign afun AuxV_Ap
#unbind-key Ctrl+v
#remove-menu Assign afun AuxV_Co
#unbind-key Ctrl+V
#remove-menu Assign afun AuxV_Pa

#unbind-key x
#remove-menu Assign afun AuxX
#unbind-key X
#remove-menu Assign afun AuxX_Ap
#unbind-key Ctrl+x
#remove-menu Assign afun AuxX_Co
#unbind-key Ctrl+X
#remove-menu Assign afun AuxX_Pa

#unbind-key z
#remove-menu Assign afun AuxZ
#unbind-key Z
#remove-menu Assign afun AuxZ_Ap
#unbind-key Ctrl+z
#remove-menu Assign afun AuxZ_Co
#unbind-key Ctrl+Z
#remove-menu Assign afun AuxZ_Pa

# ##################################################################################################
#
# ##################################################################################################

#unbind-key Ctrl+Shift+F1
#remove-menu Automatically assign afun to subtree
#unbind-key Ctrl+F9
#remove-menu Parse Slovene sentence
#unbind-key Ctrl+Shift+F9
#remove-menu Auto-assign analytical function to node
#unbind-key Ctrl+Shift+F10
#remove-menu Assign Slovene afun
#remove-menu Auto-assign analytical functions to tree

#remove-menu Edit annotator's comment
#remove-menu Display default attributes
