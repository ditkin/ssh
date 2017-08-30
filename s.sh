#!/bin/bash

# functionize it
# if host fails, try:
# adding p2- to the name
#adding c1- to the name

#each time it finds a potential match, it asks the user if thats what they want, a y/n prompt.
SSHN=''
trierResult=0
pubKey='id_rsa.pub'
RED='\033[0;31m'
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
LPURP='\033[1;35m'
LBLUE='\033[1;34m'
NC=`tput sgr0`
usage()
{
    echo "Usage: any number of partial hostnames in our network." 2>&1
    echo "       Script will push ssh keys to all, and ssh to the first one specified."
    exit $E_PARAMERR
}
ask()
{
    while read -r -n 1 answer; do
        if [[ $answer = [YyNn] ]]; then
            [[ $answer = [Yy] ]] && retval=0
            [[ $answer = [Nn] ]] && retval=1
            break
        fi
    done
    return $retval
}
# Method that cycles through a massive list of possibilities that the user may have meant to type for a hostname
prefix()
{
    PREFIXES=()
    for ad in "${PREFIXES[@]}";
    do
        echo -e "${LBLUE}Trying Hostname:${NC}${ORANGE}$ad$1${NC}"
        host $ad$1 > /dev/null 2>&1
        result=$?
        if [ $result -eq 0 ] ; then
            echo -e "${GREEN}Found successful match:${NC}${ORANGE}$ad$1${NC}"
            sleep 0.5
            echo -e "${LPURP}Do you want to SSH to: ${NC}${ORANGE}$ad$1${NC}${LPURP} [y/N]?${NC}"
            if ask; then
                SSHN=$ad$1
                trierResult=0
                return 0
            else
                clear
                echo -e "${YELLOW}That's ok.${NC}"
                sleep 0.5
                printf "\n"
                echo -e "${YELLOW}I have some more ideas...${NC}"
                sleep 1
            fi
        fi
        if [ $result -eq 1 ] ; then
            echo -e "${RED}MATCH FAILED!${NC}"
        fi
    done
    trierResult=1
    return 1
}

suffix()
{
    SUFFIXES=()
    for ad in "${SUFFIXES[@]}";
    do
        echo -e "${LBLUE}Trying Hostname:${NC}${ORANGE}$1$ad${NC}"
        host $1$ad > /dev/null 2>&1
        result=$?
        if [ $result -eq 0 ] ; then
            echo -e "${GREEN}Found successful match:${NC}${ORANGE}$1$ad${NC}"
            sleep 0.5
            echo -e "${LPURP}Do you want to SSH to: ${NC}${ORANGE}$1$ad${NC}${LPURP} [y/n]?${NC}"
            if ask; then
                SSHN=$1$ad
                trierResult=0
                return 0
            else
                clear
                echo -e "${YELLOW}That's ok.${NC}"
                sleep 0.5
                printf "\n"
                echo -e "${YELLOW}I have some more ideas...${NC}"
                sleep 1
            fi
        fi
        if [ $result -eq 1 ] ; then
            echo -e "${RED}MATCH FAILED!${NC}"
        fi
    done
    trierResult=1
    printf "\n"
    echo -e "${RED}NEVER MIND!${NC}"
    return 1
}
# we need a character switcher function, that switches every char with every other one in its place, except the numbers part doesnt go into the text part.
# add every permutation found into a big array to check against it each time. shiit thats n^2. oh well lol.
trier()
{
    echo "HERE IS MONEY ONE"
    echo $1
    if [[ $1 == *"p2"* ]] || [[ $1 == *"c1"* ]] ; then
        suffix $1
    else
        prefix $1
        if [ $? -eq 1 ]; then
            echo -e "${CYAN}Prefixes failed, trying suffixes now...${NC}"
            suffix $1
        fi
    fi
}

if [ -z $1 ] ; then
    usage
fi
dirls=$( ls ~/.ssh )
echo "${pubKey}"
if [[ $dirls != *$pubKey* ]]; then
    echo -e "${RED}Whoops!${NC}"
    printf "\n"
    sleep 1.5
    echo -e "${ORANGE}Let's give you some ssh keys first.${NC}"
    cd ~
    ssh-keygen
    sleep 2
fi
ssh-copy-id > /dev/null 2>&1
if [ $? -eq 127 ] ; then
    brew install ssh-copy-id > /dev/null 2>&1
fi
COUNTER=0
for typedHostname in `echo $@`;
do
    host $typedHostname > /dev/null 2>&1
    qm=$?
    fullHostname=$( host $typedHostname | awk '{print $1}' )
    fullHostname=($fullHostname)
    fullHostname=${fullHostname[0]}
    if [ $qm -eq 0 ] ; then
        sshName="$( printenv USER )"
        sshName="$sshName@"
        sshName=$sshName$fullHostname
        echo sshName
        echo $sshName
        #$( echo yes | ssh-copy-id $sshName )
        ssh-copy-id $sshName > /dev/null 2>&1
        if [ $COUNTER -eq 0 ] ; then
            SSHN=$fullHostname
        fi
    fi
    if [ $qm -eq 1 ] ; then
        echo You full-bodied-fingered the command. Time to fix it.
        sleep 1
        trier $1
    fi
done
host $SSHN > /dev/null 2>&1
qm=$?
if [[ $trierResult -eq 0 ]] && [[ $qm -eq 0 ]]; then
    echo 'SSHING NOW'
    ssh $SSHN
fi
