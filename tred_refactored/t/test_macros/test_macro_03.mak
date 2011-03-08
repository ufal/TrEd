# test macro file no 3
# Test include with various paths

# The filename must be relative to the directory of the file to which it is included.
#include "include/include1.inc"

# The filename must be relative to the TrEd's library directory.
#include <../t/test_macros/include/include2.inc>

# Expands wildcard relatively to the directory of the file containing the directive and includes all matching file.
#include "<include/include0*.inc>"

# The filename may be both absolute or relative. In the latter case the directories are searched in the following order:
# 1. Current directory is searched.
# 2. The directory of the file where the #include directive occured is searched.
# 3. TrEd's library directory is searched.
#include ../t/test_macros/include/include3.inc

# This file should be included
#ifinclude "include/include4.inc"

# This file does not exist, should continue without complaints
#ifinclude "include/include5.inc"
