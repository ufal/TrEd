#!/bin/sh
devel=`dirname $0`
pod2xml "$1" | sed "s/<?xml version='1.0' encoding='iso-8859-1'?>/<?xml version='1.0' encoding='UTF-8'?>/" | xsltproc "$devel"/pod2db.xsl - | "$devel"/pod2db.xsh -q -P- 
