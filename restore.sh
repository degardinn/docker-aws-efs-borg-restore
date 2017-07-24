#!/bin/bash -e

export BORG_PASSPHRASE=$1
SOURCE=$2
BACKUP=$3
DIRECTORY=$3
RECORD=$4
REPO=${5:-'borg'}

if [ -z $SOURCE ]; then
    echo "** Source: nothing specified (mounted volume?)"
else
    echo "** Source: EFS '$EFS'"
    mount -t nfs4 -o nfsvers=4.1,ro,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 $SOURCE:/ /mnt/source
fi

if [ -z $3 ]; then
    echo "** Backup: nothing specified (mounted volume?)"
else
    echo "** Backup: EFS '$EFS'"
    mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 $BACKUP:/ /mnt/backup
fi

REPOSITORIES="/mnt/backup/$REPO"

while [ -z $DIRECTORY ]; do
    DIRECTORIES=$(find $REPOSITORIES/* -maxdepth 0 -type d -print)
    NAMES=()
    for DIR in $DIRECTORIES; do
        NAMES=( ${NAMES[@]} ${DIR##/*/} )
    done
    echo "** Which directory? " ${NAMES[@]}
    read DIRECTORY

    FOUND=0
    for NAME in ${NAMES[@]}; do
        if [ "$NAME" == "$DIRECTORY" ]; then
            FOUND=1
        fi
    done
    if [ $FOUND = 0 ]; then
        unset DIRECTORY
    fi
done

if [ -d "$REPOSITORIES/$DIRECTORY" ]; then
    echo "** Which record? "
    borg list $REPOSITORIES/$DIRECTORY
    read RECORD

    borg info $REPOSITORIES/$DIRECTORY::$RECORD
    echo "** Extracting..."
    mkdir -p /mnt/source/.tempRestore
    cd /mnt/source/.tempRestore
    borg extract $REPOSITORIES/$DIRECTORY::$RECORD
    
    echo "** Moving..."
    if [ -d "/mnt/source/$DIRECTORY.restore" ]; then
        rm -Rf "/mnt/source/$DIRECTORY.restore"
    fi
    
    # The full path is preserved when extracting...
    mv "mnt/source/$DIRECTORY" "/mnt/source/$DIRECTORY.restore"
    cd /mnt/source
    rmdir -p .tempRestore/mnt/source

    if [ -d "/mnt/source/$DIRECTORY.beforeRestore" ]; then
        rm -Rf "/mnt/source/$DIRECTORY.beforeRestore"
    fi

    if [ -d "/mnt/source/$DIRECTORY" ]; then
        echo "** Old directory moved to $DIRECTORY.restore"
        mv "/mnt/source/$DIRECTORY" "/mnt/source/$DIRECTORY.beforeRestore"
    fi
    
    mv "/mnt/source/$DIRECTORY.restore" "/mnt/source/$DIRECTORY"
    echo "** $DIRECTORY ($RECORD) restored"
fi