#!/bin/bash
#---------------------------------------------------------------------------
# File Name : genmqpkg.sh
# Descriptive File Name : Generate a redistributable package
#---------------------------------------------------------------------------
#  <copyright
#  notice="lm-source-program"
#  pids="5724-H72"
#  years="2015,2018"
#  crc="0" >
#  Licensed Materials - Property of IBM
#
#  5724-H72,
#
#  (C) Copyright IBM Corp. 2015, 2018 All Rights Reserved.
#
#  US Government Users Restricted Rights - Use, duplication or
#  disclosure restricted by GSA ADP Schedule Contract with
#  IBM Corp.
#  </copyright>
#---------------------------------------------------------------------------
# @(#) MQMBID sn=p911-L181120.1 su=_YQvs9ezZEeidp6nbu5WJxQ pn=install/unix/genmqpkg.sh
#---------------------------------------------------------------------------
# File Description :
# This script is used to create a smaller redistributable runtime package
# for client applications by creating a second copy of the runtime and
# removing objects that are not required, based on a number of Yes/No
# answers about the required runtime environment.
#
# Usage:
#  genmqpkg.sh [-b] [target_dir]
#  -b:         Run the program in a batch mode, making selections based
#              on environment variables. Names of the environment variables
#              are shown after running this program interactively.
#  target_dir: Where to put the new package. This directory must not
#              exist. If not provided, the name is read from stdin.


# Set the incXXX variable to 1 iff the environment variable
# "genmqpkg_incXXX" is also set to "1". Otherwise set it to 0.
function getenv {
  incfield="inc$1"

  # Build the name of the environment variable dynamically
  # and use eval to get its value.
  envvarL="genmqpkg_"$incfield
  # Be able to handle lower and upper case variations of the env var
  envvarU=`echo $envvarL | tr [a-z] [A-Z]`
  eval val=${!envvarL}
  # If lowercase version not found, look for the uppercase version
  if [[ "$val" == "" ]]
  then
    eval val=${!envvarU}
  fi

  # Set the value in the global variable
  if [[ "$val" == "1" ]]
  then
    eval $incfield=1
  else
    eval $incfield=0
  fi
}

pushd `dirname $0` > /dev/null
scriptdir=`pwd -P`
popd > /dev/null

echo
echo "Generate MQ Runtime Package"
echo "---------------------------"
echo "This program will help determine a minimal set of runtime files that are"
echo "required to be distributed with a client application. The program will"
echo "ask a series of questions and then prompt for a filesystem location to"
echo "copy the subset of files to."
echo
echo "Note that IBM can only provide support assistance for an unmodified set"
echo "of redistributable runtime files."
echo

if [[ "$1" = "-h" || "$1" = "-?" ]]
then
  echo "Usage: genmqpkg.sh [-b] [target_dir]"
  echo "-b: Run non-interactively, using environment variables to configure"
  echo "target_dir: New directory to contain the regenerated package"
  exit 1
fi

if [[ "$1" = "-b" ]]
then
  useBatch=true
else
  useBatch=false
fi

# Target directory is final arg
tgtdir=""
if [[ $# -ge 1 ]]
then
  tgtdir=${!#}
fi

if $useBatch
then
  # Read the responses from the environment
 getenv 32
 getenv nls
 getenv cpp
 getenv cbl
 getenv tls
 getenv ams
 getenv cics
 getenv adm
 getenv ras
 getenv samp
 getenv sdk

else
# Get all the values interactively
  while true; do
      read -p "Does the runtime require 32-bit application support [Y/N]? " yn
      case $yn in
          [Yy]* ) inc32=1; break;;
          [Nn]* ) inc32=0; break;;
          * ) echo "Please answer Y or N.";;
      esac
  done

  while true; do
      read -p "Does the runtime require support for languages other than English [Y/N]? " yn
      case $yn in
          [Yy]* ) incnls=1; break;;
          [Nn]* ) incnls=0; break;;
          * ) echo "Please answer Y or N.";;
      esac
  done

  while true; do
      read -p "Does the runtime require C++ libraries [Y/N]? " yn
      case $yn in
          [Yy]* ) inccpp=1; break;;
          [Nn]* ) inccpp=0; break;;
          * ) echo "Please answer Y or N.";;
      esac
  done

  while true; do
      read -p "Does the runtime require COBOL libraries [Y/N]? " yn
      case $yn in
          [Yy]* ) inccbl=1; break;;
          [Nn]* ) inccbl=0; break;;
          * ) echo "Please answer Y or N.";;
      esac
  done

  while true; do
      read -p "Does the runtime require SSL/TLS support [Y/N]? " yn
      case $yn in
          [Yy]* ) inctls=1; break;;
          [Nn]* ) inctls=0; break;;
          * ) echo "Please answer Y or N.";;
      esac
  done

  while true; do
      read -p "Does the runtime require AMS support [Y/N]? " yn
      case $yn in
          [Yy]* ) incams=1; break;;
          [Nn]* ) incams=0; break;;
          * ) echo "Please answer Y or N.";;
      esac
  done

  while true; do
      read -p "Does the runtime require CICS support [Y/N]? " yn
      case $yn in
          [Yy]* ) inccics=1; break;;
          [Nn]* ) inccics=0; break;;
          * ) echo "Please answer Y or N.";;
      esac
  done

  while true; do
      read -p "Does the runtime require any administration tools [Y/N]? " yn
      case $yn in
          [Yy]* ) incadm=1; break;;
          [Nn]* ) incadm=0; break;;
          * ) echo "Please answer Y or N.";;
      esac
  done

  while true; do
      read -p "Does the runtime require any RAS tools [Y/N]? " yn
      case $yn in
          [Yy]* ) incras=1; break;;
          [Nn]* ) incras=0; break;;
          * ) echo "Please answer Y or N.";;
      esac
  done

  while true; do
      read -p "Does the runtime require any sample applications [Y/N]? " yn
      case $yn in
          [Yy]* ) incsamp=1; break;;
          [Nn]* ) incsamp=0; break;;
          * ) echo "Please answer Y or N.";;
      esac
  done

  while true; do
      read -p "Does the runtime require the SDK to compile applications [Y/N]? " yn
      case $yn in
          [Yy]* ) incsdk=1; break;;
          [Nn]* ) incsdk=0; break;;
          * ) echo "Please answer Y or N.";;
      esac
  done
fi

# We can only delete GSKit if no need for SSL/TLS and no need for AMS
if [ $inctls -eq 1 ] || [ $incams -eq 1 ]
then
  incgsk=1
else
  incgsk=0
fi

# See if anything can be deleted. If nothing, then there's no point
# continuing.
if [ $inc32 -eq 1  ] && [ $incnls -eq 1 ] && [ $inccpp -eq 1 ] && \
   [ $inccbl -eq 1 ] && [ $incgsk -eq 1 ] && [ $inccics -eq 1 ] && \
   [ $incadm -eq 1 ] && [ $incras -eq 1 ] && [ $incsamp -eq 1 ] && \
   [ $incsdk -eq 1 ]
then
  echo
  echo "Sorry, no files can be removed from the redistributable image."
  exit 1
fi

# If interactive, you can keep trying to give the name of the target
# directory. If non-interactive, program exits if target already exists.
if [[ -z "$tgtdir" ]]
  then
  echo
  while true; do
    echo "Please provide a target directory for the runtime package to be created"
    read tgtdir
    if [ -e "$tgtdir" ]
    then
      echo "Target directory '$tgtdir' already exists, please specify a new target directory."
      if $useBatch
      then
        exit
      fi
    else
      break
    fi
  done
else
  if [ -e "$tgtdir" ]
  then
    echo "Target directory '$tgtdir' already exists, please specify a new target directory."
    exit 1
  fi
fi

echo
while true; do
    echo "The redistributable image will be created in"
    echo
    echo $tgtdir
    echo
    # Interactive mode gives a final chance to bail out.
    if  ! $useBatch
    then
    read -p "Are you sure you want to continue [Y/N]? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) echo "Creation of redistributable image cancelled by user."; exit 1; break;;
        * ) echo "Please answer Y or N.";;
    esac
    else
      break
    fi
done


# Tell users how they can repeat the interactive choices in future.
if  ! $useBatch
then
  echo
  echo "To repeat this set of choices, you can set these environment"
  echo "variables and rerun this program with the -b option. The target"
  echo "directory is given as the last option on the command line."
  echo
  echo "export genmqpkg_inc32=$inc32"
  echo "export genmqpkg_incnls=$incnls   "
  echo "export genmqpkg_inccpp=$inccpp   "
  echo "export genmqpkg_inccbl=$inccbl   "
  echo "export genmqpkg_inctls=$inctls   "
  echo "export genmqpkg_incams=$incams   "
  echo "export genmqpkg_inccics=$inccics "
  echo "export genmqpkg_incadm=$incadm   "
  echo "export genmqpkg_incras=$incras   "
  echo "export genmqpkg_incsamp=$incsamp "
  echo "export genmqpkg_incsdk=$incsdk   "
  echo
fi

mkdir -p "$tgtdir"
cp -R "$scriptdir/../bin" "$tgtdir/bin"
cp -R "$scriptdir/../gskit8" "$tgtdir/gskit8"
cp -R "$scriptdir/../java" "$tgtdir/java"
cp -R "$scriptdir/../lib" "$tgtdir/lib"
cp -R "$scriptdir/../lib64" "$tgtdir/lib64"
cp -R "$scriptdir/../licenses" "$tgtdir/licenses"
cp -R "$scriptdir/../msg" "$tgtdir/msg"
cp -R "$scriptdir/../samp" "$tgtdir/samp"
cp -R "$scriptdir/../inc" "$tgtdir/inc"

if [ $inc32 -eq 0 ]
then
  rm -f "$tgtdir/lib/amqczsc"
  rm -f "$tgtdir/lib/amqczscg"
  rm -f "$tgtdir/lib/amqlcelp"
  rm -f "$tgtdir/lib/amqlcelp_r"
  rm -f "$tgtdir/lib/libimqb23gl_r.so"
  rm -f "$tgtdir/lib/libimqb23gl_r.so.4.1"
  rm -f "$tgtdir/lib/libimqb23gl.so"
  rm -f "$tgtdir/lib/libimqb23gl.so.4.1"
  rm -f "$tgtdir/lib/libimqc23gl_r.so"
  rm -f "$tgtdir/lib/libimqc23gl_r.so.4.1"
  rm -f "$tgtdir/lib/libimqc23gl.so"
  rm -f "$tgtdir/lib/libimqc23gl.so.4.1"
  rm -f "$tgtdir/lib/libmqccics_r.a"
  rm -f "$tgtdir/lib/libmqcxa_r.so"
  rm -f "$tgtdir/lib/libmqcxa.so"
  rm -f "$tgtdir/lib/libmqdc_r.so"
  rm -f "$tgtdir/lib/libmqdc.so"
  rm -f "$tgtdir/lib/libmqecs_r.so"
  rm -f "$tgtdir/lib/libmqecs.so"
  rm -f "$tgtdir/lib/libmqe_r.so"
  rm -f "$tgtdir/lib/libmqe.so"
  rm -f "$tgtdir/lib/libmqicb_r.so"
  rm -f "$tgtdir/lib/libmqicb.so"
  rm -f "$tgtdir/lib/libmqic_r.so"
  rm -f "$tgtdir/lib/libmqic.so"
  rm -f "$tgtdir/lib/libmqiz_r.so"
  rm -f "$tgtdir/lib/libmqiz.so"
  rm -f "$tgtdir/lib/libmqjx_r.so"
  rm -f "$tgtdir/lib/libmqjxx_r.so"
  rm -f "$tgtdir/lib/libmqmcs_r.so"
  rm -f "$tgtdir/lib/libmqmcs.so"
  rm -f "$tgtdir/lib/libmqm_r.so"
  rm -f "$tgtdir/lib/libmqm.so"
  rm -f "$tgtdir/lib/libmqmzse.so"
  rm -f "$tgtdir/lib/libmqxzu_r.so"
  rm -f "$tgtdir/lib/libmqxzu.so"
  rm -f "$tgtdir/lib/libmqz_r.so"
  rm -f "$tgtdir/lib/libmqzsd_r.so"
  rm -f "$tgtdir/lib/libmqzsd.so"
  rm -f "$tgtdir/lib/libmqz.so"
fi

if [ $incnls -eq 0 ]
then
  rm -rf "$tgtdir/msg/cs_CZ"
  rm -rf "$tgtdir/msg/de_DE"
  rm -rf "$tgtdir/msg/es_ES"
  rm -rf "$tgtdir/msg/fr_FR"
  rm -rf "$tgtdir/msg/hu_HU"
  rm -rf "$tgtdir/msg/it_IT"
  rm -rf "$tgtdir/msg/ja_JP"
  rm -rf "$tgtdir/msg/ko_KR"
  rm -rf "$tgtdir/msg/pl_PL"
  rm -rf "$tgtdir/msg/pt_BR"
  rm -rf "$tgtdir/msg/ru_RU"
  rm -rf "$tgtdir/msg/zh_CN"
  rm -rf "$tgtdir/msg/zh_TW"
fi

if [ $inccpp -eq 0 ]
then
  rm -f "$tgtdir/lib/libimqb23gl_r.so"
  rm -f "$tgtdir/lib/libimqb23gl_r.so.4.1"
  rm -f "$tgtdir/lib/libimqb23gl.so"
  rm -f "$tgtdir/lib/libimqb23gl.so.4.1"
  rm -f "$tgtdir/lib/libimqc23gl_r.so"
  rm -f "$tgtdir/lib/libimqc23gl_r.so.4.1"
  rm -f "$tgtdir/lib/libimqc23gl.so"
  rm -f "$tgtdir/lib/libimqc23gl.so.4.1"
  rm -f "$tgtdir/lib64/libimqb23gl_r.so"
  rm -f "$tgtdir/lib64/libimqb23gl_r.so.4.1"
  rm -f "$tgtdir/lib64/libimqb23gl.so"
  rm -f "$tgtdir/lib64/libimqb23gl.so.4.1"
  rm -f "$tgtdir/lib64/libimqc23gl_r.so"
  rm -f "$tgtdir/lib64/libimqc23gl_r.so.4.1"
  rm -f "$tgtdir/lib64/libimqc23gl.so"
  rm -f "$tgtdir/lib64/libimqc23gl.so.4.1"
  rm -rf "$tgtdir/samp/bin/gl"
fi

if [ $inccbl -eq 0 ]
then
  rm -f "$tgtdir/lib/libmqicb_r.so"
  rm -f "$tgtdir/lib/libmqicb.so"
  rm -f "$tgtdir/lib64/libmqicb_r.so"
  rm -f "$tgtdir/lib64/libmqicb.so"
fi

if [ $incgsk -eq 0 ]
then
  rm -f "$tgtdir/bin/amqcgskv32"
  rm -f "$tgtdir/bin/amqcgskv64"
  rm -f "$tgtdir/bin/runmqakm"
  rm -rf "$tgtdir/gskit8"
fi

if [ $inccics -eq 0 ]
then
  rm -f "$tgtdir/bin/amqltmc0"
  rm -f "$tgtdir/bin/amqltmcc"
  rm -f "$tgtdir/lib/amqczsc"
  rm -f "$tgtdir/lib/amqczscg"
  rm -f "$tgtdir/lib/libmqccics_r.a"
fi

if [ $incadm -eq 0 ]
then
  rm -f "$tgtdir/bin/crtmqcvx"
  rm -f "$tgtdir/bin/crtmqenv"
  rm -f "$tgtdir/bin/dmpmqcfg"
  rm -f "$tgtdir/bin/dmpmqmsg"
  rm -f "$tgtdir/bin/mqrc"
  rm -f "$tgtdir/bin/runmqsc"
  rm -f "$tgtdir/bin/runmqtmc"
fi

if [ $incras -eq 0 ]
then
  rm -f "$tgtdir/bin/isa.xml"
  rm -f "$tgtdir/bin/mqconfig"
  rm -f "$tgtdir/bin/dspmqtrc"
  rm -f "$tgtdir/bin/endmqtrc"
  rm -f "$tgtdir/bin/strmqtrc"
  rm -f "$tgtdir/bin/runmqras"
  rm -f "$tgtdir/lib/amqtrc.fmt"
  rm -f "$tgtdir/java/lib/com.ibm.mq.tools.ras.jar"
fi

if [ $incsamp -eq 0 ]
then
  rm -f "$tgtdir/lib/amqlcelp"
  rm -f "$tgtdir/lib/amqlcelp_r"
  rm -rf "$tgtdir/samp"
fi

if [ $incsdk -eq 0 ]
then
  rm -rf "$tgtdir/inc"
fi


#delete the genmqpkg tool in the sub distribution
rm -f "$tgtdir/bin/genmqpkg.sh"

#tidy up any orphaned directories
if [ -z "$(ls -A -- "$tgtdir/java/lib")" ]; then
  rm -rf "$tgtdir/java/lib"
fi

if [ -z "$(ls -A -- "$tgtdir/java")" ]; then
  rm -rf "$tgtdir/java"
fi

echo
echo "Generation complete !"
echo "Redistributable client image copied to '$tgtdir'"
echo
exit 0
