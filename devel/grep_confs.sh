#!/bin/sh
perl -ne 'print $1.$2."\n" if /\$confs->{([^\$]*)}|val_or_def\(\$confs,['\''"](.*?)['\''"]/' tredlib/TrEd/Config.pm|sort -u|grep -Ev '^(ballancetree|canvasheight|canvaswidth|cststofs|fstocsts)$' 
