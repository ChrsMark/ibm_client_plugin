#********************************************************************#
#*                                                                  *#
#* <copyright                                                       *#
#* notice="lm-source-program"                                       *#
#* pids=""                                                          *#
#* years="2015"                                                     *#
#* crc="2252069658" >                                               *#
#* Licensed Materials - Property of IBM                             *#
#*                                                                  *#
#*                                                                  *#
#*                                                                  *#
#* (C) Copyright IBM Corp. 2015,  All Rights Reserved.              *#
#*                                                                  *#
#* US Government Users Restricted Rights - Use, duplication or      *#
#* disclosure restricted by GSA ADP Schedule Contract with          *#
#* IBM Corp.                                                        *#
#* </copyright>                                                     *#
#*                                                                  *#
#********************************************************************#


# This simple script helps to assign full administrative access to
# a group for a queue manager's resources.
#
# You can edit the script to select variations including setting
# read-only access to all objects, and choosing whether an adminstrator
# can read messages on queues.
#
# This script may be particularly useful if you are using LDAP groups
# for authorisation, as the operating system's "mqm" group is no longer
# automatically considered to be fully-authorised.

# Check number of parms supplied
if [ $# -ne 2 ]
then
  echo "Syntax: amqauthg.sh <queue manager> <group name>"
  echo "  Grant the named group full admin rights to the queue manager"
  exit 1
fi

# Read the parameters
qmgr=$1
group="$2"

# These permissions are set on objects to allow full control
rwpermsqmgr="+alladm"
rwpermsobjs="+alladm +crt"

# These permissions are set on objects to allow read-only access to values
ropermsqmgr="+dsp"
ropermsobjs="+dsp"

# Select one of these options to allow an administrator also to browse
# messages on queues
browse="+browse"
browse=""

# Select either the read-write or read-only variations depending on the
# level of access to grant
qmgrperms=$rwpermsqmgr
objperms=$rwpermsobjs

# Now execute the commands to grant the group the chosen level of access.

# First for the queue manager:
setmqaut -m $qmgr   -t qmgr -g "$group" $qmgrperms
# Then for all objects in each object type:
setmqaut -m $qmgr   -n "**" -t q        -g "$group" $objperms $browse
setmqaut -m $qmgr   -n "**" -t topic    -g "$group" $objperms
setmqaut -m $qmgr   -n "**" -t channel  -g "$group" $objperms
setmqaut -m $qmgr   -n "**" -t process  -g "$group" $objperms
setmqaut -m $qmgr   -n "**" -t namelist -g "$group" $objperms
setmqaut -m $qmgr   -n "**" -t authinfo -g "$group" $objperms
setmqaut -m $qmgr   -n "**" -t clntconn -g "$group" $objperms
setmqaut -m $qmgr   -n "**" -t listener -g "$group" $objperms
setmqaut -m $qmgr   -n "**" -t service  -g "$group" $objperms
setmqaut -m $qmgr   -n "**" -t comminfo -g "$group" $objperms

# The following commands provide administrative access for MQ Explorer.
setmqaut -m $qmgr   -n SYSTEM.MQEXPLORER.REPLY.MODEL -t q -g "$group" +dsp +inq +get
setmqaut -m $qmgr   -n SYSTEM.ADMIN.COMMAND.QUEUE    -t q -g "$group" +dsp +inq +put
