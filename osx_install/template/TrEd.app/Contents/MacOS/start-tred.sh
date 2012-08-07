#!/bin/sh

LOGFILE=/Applications/TrEd-last_run.log
/Applications/TrEd.app/Contents/MacOS/tred/bin/start_tred 2>&1 > $LOGFILE
