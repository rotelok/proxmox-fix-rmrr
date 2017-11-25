#!/bin/bash
# PVE Kernel Patcher
REPO_DIR=$(pwd)
SOURCES_DIR=/usr/src/

mkdir deb
apt-get install git nano screen patch \
                fakeroot build-essential devscripts libncurses5 \
                libncurses5-dev libssl-dev bc flex \
                bison libelf-dev libaudit-dev libgtk2.0-dev \
                libperl-dev libperl-dev asciidoc xmlto \
                gnupg gnupg2 gdebi -y

cd $SOURCES_DIR
git clone git://git.proxmox.com/git/pve-kernel.git
cd pve-kernel

# Find the Version

CURRENT_PVE=$(pveversion | cut -d "/" -f2 | cut -d "-" -f1)
CURRENT_KERNEL=$(uname -a | cut -d " " -f3 | cut -d '-' -f1)

PVE_VERSION=$(cat Makefile | grep "RELEASE="| cut -d "=" -f2)
KERNEL_VERSION=$(cat Makefile | grep KERNEL_SRC=| cut -d "=" -f2)

if [[ $PVE_VERSION == 5.0 ]];then
    # Checking out 5.0 kernel version
    git checkout pve-kernel-4.10
    # Patching the makefile
    cp $REPO_DIR/patches/Makefile.patch .
    patch -p1 < Makefile.patch
    # Copying the rmrr remove patch
    cp $REPO_DIR/patches/0007-rmrr-patch-proxmox.5.0.patch .

elif [[ $PVE_VERSION == 5.1 && $KERNEL_VERSION == "ubuntu-artful" ]];then
    echo "Supported Version: Copying the patch files"
    # If pve 5.1 we don't need to patch the makefile, just copy our .patch file
    cp $REPO_DIR/patches/0007-rmrr-patch-proxmox.5.1.patch patches/kernel/
else
    echo "Unsupported Version $PVE_VERSION"
    exit
fi


#Build the kernel
echo "Building the kernel, go grab a coffee it will take a long time"
make


# Post Build Stuff
mv *.deb $REPO_DIR/deb/


# Post compile clean up
cd $SOURCES_DIR
rm -rf pve-kernel


# Install stuff


# Post Install Stuff
VFIO_CONF_FILE="/etc/modprobe.d/kvm-vfio.conf"
if [[ -w ${VFIO_CONF_FILE} ]];then
    echo "# Enable unsafe interrupts
# Disable msrs to fix some problems with NVIDIA cards in windows
options vfio_iommu_type1 allow_unsafe_interrupts=1
options kvm ignore_msrs=Y

# Here you choose which devices you want to passthrough, ie:
# lspci -nn | grep -i NVIDIA
#   07:00.0 VGA compatible controller [0300]: NVIDIA Corporation GK107 [NVS 510] [10de:0ffd] (rev a1)
#   07:00.1 Audio device [0403]: NVIDIA Corporation GK107 HDMI Audio Controller [10de:0e1b] (rev a1)
# in this case you would use 10de:0ffd (video card ) and 10de:0e1b ( hdmi audio )
# should work with most cards

options vfio-pci ids=10de:0ffd,10de:0e1b

" > ${VFIO_CONF_FILE}
fi

# Loading the vfio modules during boot
MODULES_FILE="/etc/modules"
MODULES_LIST='pci_stub vfio vfio_iommu_type1 vfio_pci vfio_virqfd'
for I in ${MODULES_LIST}
do
    egrep "${I}$" ${MODULES_FILE} -q
        if [[ $? == 1 ]];then
        echo ${I} >> ${MODULES_FILE}

    fi
done

