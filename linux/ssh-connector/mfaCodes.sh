#!/bin/bash

if [ $# -eq 0 ]; then
     echo "MFA name not found!"
elif [ $# -gt 1 ]; then
     echo "To many args!"
else
    MFA_NAME=$1
    MFA_ACTV=0

    case $MFA_NAME in
        MFA1)
	    MFA_CODE="<INSERT CODE HERE>"
	    MFA_ACTV=1
	    ;;
	MFA2)
	    MFA_CODE="<INSERT CODE HERE>"
	    MFA_ACTV=1
	    ;;
	*)
           echo "Invalid MFA Name ${MFA_CODE}"
	    ;;
   esac

   if [ $MFA_ACTV -eq 1 ]; then
       echo "${MFA_NAME} - $(oathtool --base32 --totp ${MFA_CODE})"
   fi

fi
