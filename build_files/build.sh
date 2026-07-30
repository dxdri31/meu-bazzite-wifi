#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket

### Driver Wi-Fi AIC8800D80

echo "=== Instalando driver AIC8800D80 ==="

dnf5 -y install kernel-devel kernel-headers gcc make git

KVER=$(rpm -q --qf '%{version}-%{release}.%{arch}\n' kernel-core | head -n1)
echo "Kernel da imagem: ${KVER}"

git clone --depth 1 https://github.com/shenmintao/aic8800d80.git /tmp/aic8800

cd /tmp/aic8800/drivers/aic8800
make -C "/usr/lib/modules/${KVER}/build" M="$(pwd)" modules

install -Dm644 aic8800_fdrv.ko "/usr/lib/modules/${KVER}/extra/aic8800_fdrv.ko"
depmod -a "${KVER}"

mkdir -p /usr/lib/firmware
cp -r /tmp/aic8800/fw/aic8800* /usr/lib/firmware/

install -Dm644 /tmp/aic8800/aic.rules /usr/lib/udev/rules.d/aic.rules

rm -rf /tmp/aic8800

echo "=== Driver AIC8800D80 instalado com sucesso ==="
