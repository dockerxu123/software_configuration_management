#!/bin/bash
#增加changelog功能
# solve the space by IFS
IFS=$(echo -en "\n\b")
echo -en $IFS

if [ -f "CHANGELOG.md" ]; then
  rm -f CHANGELOG.md
  touch CHANGELOG.md
else
  touch CHANGELOG.md
fi

function printFeat() {
  for i in ${feat[@]}; do
    echo "- "$i >>CHANGELOG.md
  done
  echo >>CHANGELOG.md
}

function printFix() {
  for i in ${fix[@]}; do
    echo "- "$i >>CHANGELOG.md
  done
  echo >>CHANGELOG.md
}

function printOther() {
  for i in ${other[@]}; do
    echo "- "$i >>CHANGELOG.md
  done
  echo >>CHANGELOG.md
}

function checkLog() {
  if [[ $1 == "feat"* ]]; then
    feat[featIndex]=$1
    let featIndex++
  elif [[ $1 == "fix"* ]]; then
    fix[fixIndex]=$1
    let fixIndex++
  else
    other[otherIndex]=$1
    let otherIndex++
  fi
}

function printLog() {
  if [[ $featIndex -ne 0 ]]; then
    echo "## Features" >>CHANGELOG.md
    printFeat
  fi

  if [[ $fixIndex -ne 0 ]]; then
    echo "## Bug Fixes" >>CHANGELOG.md
    printFix
  fi

  if [[ $otherIndex -ne 0 ]]; then
    echo "## Other Changes" >>CHANGELOG.md
    printOther
  fi

  feat=()
  featIndex=0

  fix=()
  fixIndex=0

  other=()
  otherIndex=0
}

curDate=""
function checkDate() {
  if [[ $curDate == $1 ]]; then
    return
  fi
  curDate=$1

  printLog

  echo >>CHANGELOG.md
  echo "## "$curDate >>CHANGELOG.md
}
releaseName=""
# shellcheck disable=SC2120
function printRelease() {
  if [[ $releaseName == $1 ]]; then
    return
  fi
  releaseName=$1

  printLog

  echo >>CHANGELOG.md
  echo "# "$releaseName >>CHANGELOG.md
}

function printCommit() {
  commitIndex=0
  commitList=$(git log --date=format:'%Y-%m-%d' --pretty=format:'%cd%n%s' $1...$2)
  for i in ${commitList[@]}; do
    if [[ commitIndex%2 -eq 0 ]]; then
      #        checkDate $i
      echo $i
    else
      #echo "- "$i >> CHANGELOG.md
      checkLog $i
    fi

    let commitIndex++
  done

  printLog
}

releaseList=($(git tag --list))
length=${#releaseList[@]}
echo $length
size=`expr $length - 1`

for i in $(seq 0 $size); do
  printRelease ${releaseList[$i]}
  printCommit ${releaseList[$i]} ${releaseList[$i + 1]}
done

printLog

