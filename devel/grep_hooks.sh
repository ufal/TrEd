grep -v '^[ 	]*#' tred btred |grep doEvalHook | grep -oE '\w+_hook' |sort -u
