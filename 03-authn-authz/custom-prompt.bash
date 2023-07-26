#!/bin/bash
# add/remove to your ~/.bashrc
    # add a custom prompt everytime you login
    # PROMPT_COMMAND='/home/student/custom-prompt.bash'
# set/unset PROMPT_COMMAND
# source .bashrc

# custom PS1
myCC=`oc config current-context`
myUSER=`echo $myCC | awk -F"/" '{print $3}'`
myCLUSTER=`echo $myCC | awk -F"/" '{print $2}'`
myNS=`echo $myCC | awk -F"/" '{print $1}'`


if [[ "$myCLUSTER" =~ "api-ocp4-example-com" ]]; then
  myCLUSTERNAME="example.com"
else
  myCLUSTERNAME="undefined"  
fi

echo -e "\e[33m$myUSER\e[0m@\e[34m$myCLUSTERNAME\e[0m \e[32m$myNS\e[0m"