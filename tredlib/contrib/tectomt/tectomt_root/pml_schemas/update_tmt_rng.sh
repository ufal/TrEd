#!/bin/bash

# (re)generating of tmt_schema.rng ,which can
# be used for checking the validity of tmt instances

# if [ ! -d $TMT_ROOT or ! -d $TMT_SHARED ]; then
#    echo "Error: The tectomt environment must be initialized first!"
#    echo "(\$TMT_ROOT and $TMT_SHARED must refer to directories)"
#    exit
# fi

# pozor: zatim vyzaduje ufali cesty natvrdo


/f/common/exec/pml_simplify < $TMT_ROOT/pml_schemas/tmt_schema.xml\
 > $TMT_ROOT/pml_schemas/tmt_schema_simplified.xml

xsltproc /f/common/share/pml/pml2rng.xsl $TMT_ROOT/pml_schemas/tmt_schema_simplified.xml\
 > $TMT_ROOT/pml_schemas/tmt_schema.rng
