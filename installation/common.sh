CENTOS_VER=6.5
CDH_VER=5.7.0

CENTOS_MAJ_VER=`echo "$CENTOS_VER" | cut -d. -f1`
CDH_MAJ_VER=`echo "$CDH_VER" | cut -d. -f1`

function log() {
    local msg=$1
    local opts=$2
    local time=`date +%H:%M:%S`
    echo $opts "$time $msg"
}

function install_package() {
    yum install -y $*
}
