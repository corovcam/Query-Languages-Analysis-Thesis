#!/bin/bash

# Run outside of the container
# Get the sum of the total size of all tables in MBs

set -euo pipefail

tablestats=$1

grep -Fw "Space used (total)" "$tablestats" | grep -Eo '[+-]?([0-9]*[.])?[0-9]+ (.*)' | awk '
{
print $0
split($0,a," ")
unit=tolower(a[2])
switch(unit){
  case "kib":
    sum+=($0+0)/(1024)
    break
  case "mib":
    sum+=$0+0
    break
  case "gib":
    sum+=($0+0)*(1024)
    break
  case "bytes":
    sum+=($0+0)/(1024*1024)
    break
  case "?":
    print "Line is not matching anything here...."
}
}
END {
  print "TOTAL MB:"
  print sum
}'
