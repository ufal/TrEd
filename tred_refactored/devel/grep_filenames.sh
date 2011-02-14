for f in `find . -type f|grep -v '^\.*$'|grep -v CVS`; do
  base=`basename "$f"`
  grep=`grep -rEe "\b$base\b" . |grep -v '/CVS/'|grep -Ev "^$f$|^$f:"|grep -v '\$Id: ' |grep -v "contrib.mac"|grep -v "^./README:"`
  if [[ -n "$grep" ]]; then
      echo =================================================
      echo $f:
      echo "$grep"
  fi
done