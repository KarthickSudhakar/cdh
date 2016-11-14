#!/bin/bash

source shared/lib/common.sh

CACHE_DIR=shared/cache

function sync_repo() {
  local path=$1
  local outdir=$CACHE_DIR/repos/centos/$CENTOS_VER/$path
  mkdir -p $outdir

  echo "Syncing from $BASE_URI to $outdir..."
  rsync -avzHP --no-motd --delete-excluded --delete \
    --exclude 'EFI/' \
    --exclude 'drpms/' \
    --exclude 'images/' \
    --exclude 'isolinux/' \
    --exclude 'CentOS_BuildTag' \
    --exclude 'EULA' \
    --exclude 'GPL' \
    --exclude 'RELEASE-NOTES-en-US.html' \
    --exclude 'RPM-GPG-KEY-CentOS-Debug-?' \
    --exclude 'RPM-GPG-KEY-CentOS-Security-?' \
    --exclude 'RPM-GPG-KEY-CentOS-Testing-?' \
    --exclude '*.i686.rpm' \
    $BASE_URI/$path/ $outdir
}

function sync_centos_repos() {
    readonly BASE_URI=rsync://ossm.utm.my/centos/$CENTOS_VER
    sync_repo      os/x86_64 &
    sync_repo updates/x86_64 &
    wait
}

function sync_cm_repos() {
    cd $CACHE_DIR/repos
    wget -m -np https://archive.cloudera.com/cm5/redhat/$CENTOS_MAJ_VER/x86_64/cm/5/
    wget -m     https://archive.cloudera.com/cm5/redhat/$CENTOS_MAJ_VER/x86_64/cm/RPM-GPG-KEY-cloudera
    cd -
}

function sync_cdh_parcels() {
    local readonly dir=$CACHE_DIR/repos/archive.cloudera.com/cdh5/parcels/$CDH_VER
    local readonly parcel=`curl -Ls http://archive.cloudera.com/cdh5/parcels/$CDH_VER/ | grep el$CENTOS_MAJ_VER | head -1 | cut -d'"' -f8`
    mkdir -p $dir
    cd $CACHE_DIR/repos
    wget -m http://archive.cloudera.com/cdh5/parcels/$CDH_VER/$parcel
    wget -m http://archive.cloudera.com/cdh5/parcels/$CDH_VER/${parcel}.sha1
    wget -m http://archive.cloudera.com/cdh5/parcels/$CDH_VER/manifest.json
    cd -
}

function sync_kafka_parcels() {
    local readonly path=archive.cloudera.com/kafka/parcels
    local readonly url=https://$path/latest
    local readonly dir=$CACHE_DIR/repos/$path/$CDH_VER
    local readonly parcel=`curl -Ls $url | grep "-el${CENTOS_MAJ_VER}.parcel" | head -1 | cut -d'"' -f8`
    mkdir -p $dir
    cd $CACHE_DIR/repos
    wget -m $url/$parcel
    wget -m $url/$parcel.sha1
    wget -m $url/manifest.json
    cd -
}

function sync_centos_epel() {
    # https://admin.fedoraproject.org/mirrormanager/mirrors/EPEL
    local readonly dir=$CACHE_DIR/repos/centos/epel/$CENTOS_MAJ_VER/x86_64
    mkdir -p $dir
    rsync -avzHP --no-motd --delete-excluded --delete \
        --exclude 'debug/' \
        --exclude 'repoview/' \
        --exclude '*.i686.rpm' \
        rsync://mirrors.mit.edu/fedora-epel/$CENTOS_MAJ_VER/x86_64/ $dir
}

sync_centos_epel
sync_centos_repos
sync_cm_repos
sync_cdh_parcels
sync_kafka_parcels
