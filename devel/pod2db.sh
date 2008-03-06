#!/bin/sh
devel=`dirname $0`
pod2xml "$1" | xsltproc $devel/pod2db.xsl - | $devel/pod2db.xsh -q -P- 
