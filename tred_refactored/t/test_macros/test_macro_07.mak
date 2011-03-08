# test macro file no 7
# Test unbind-key and remove-menu directives

#binding-context my_new_extension

#insert my_new_ext_macro as menu My New Extension
#bind my_new_ext_macro to key Ctrl+Alt+Esc

#unbind-key Ctrl+Alt+Esc 
#remove-menu My New Extension