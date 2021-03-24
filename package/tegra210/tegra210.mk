################################################################################
#
# Linux Tegra210 Board Support Package
#
################################################################################

TEGRA210_VERSION_MAJOR = 32
TEGRA210_VERSION_MINOR = 5.0
TEGRA210_VERSION_DEB = 20210115145440
TEGRA210_VERSION = $(TEGRA210_VERSION_MAJOR).$(TEGRA210_VERSION_MINOR)
TEGRA210_SITE = https://developer.nvidia.com/embedded/L4T/r$(TEGRA210_VERSION_MAJOR)_Release_v$(TEGRA210_VERSION_MINOR)/T210
TEGRA210_SOURCE = Tegra210_Linux_R$(TEGRA210_VERSION)_aarch64.tbz2
# TODO: Double check this.
TEGRA210_LICENSE = NVIDIA Customer Software Agreement
TEGRA210_LICENSE_FILES = bootloader/LICENSE \
			 bootloader/LICENSE.chkbdinfo \
			 bootloader/LICENSE.mkbctpart \
			 bootloader/LICENSE.mkbootimg \
			 bootloader/LICENSE.mkgpt \
			 bootloader/LICENSE.mksparse \
			 bootloader/LICENSE.tos-mon-only.img.arm-trusted-firmware \
			 bootloader/LICENSE.u-boot \
			 bootloader/t210ref/LICENSE.cboot \
			 bootloader/t210ref/LICENSE.sc7entry-firmware

TEGRA210_REDISTRIBUTE = NO
TEGRA210_INSTALL_IMAGES = YES
TEGRA210_DEPENDENCIES = linux-nvidia linux uboot host-python

define TEGRA210_BUILD_CMDS
	cd $(@D) && \
	BOARDID=$(BR2_PACKAGE_TEGRA210_BOARDID) \
	BOARDSKU=$(BR2_PACKAGE_TEGRA210_BOARDSKU) \
	FAB=$(BR2_PACKAGE_TEGRA210_FAB) \
	FUSELEVEL=fuselevel_production \
	ROOTFS_DIR=$(TARGET_DIR) \
	DTBFILE=$(BINARIES_DIR)/tegra210-p3448-$(BR2_PACKAGE_TEGRA210_BOARDSKU)-p3449-0000-$(BR2_PACKAGE_TEGRA210_DTBFAB).dtb \
	KERNEL_IMAGE=$(BINARIES_DIR)/u-boot.bin \
	./flash.sh \
	--no-flash \
	--no-root-check \
	--no-systemimg \
	-r \
	--sign \
	$(BR2_PACKAGE_TEGRA210_BOARD) \
	mmcblk0p1

	cd $(@D)/nv_tegra/l4t_deb_packages && \
	ar x nvidia-l4t-xusb-firmware_$(TEGRA210_VERSION)-$(TEGRA210_VERSION_DEB)_arm64.deb data.tar.zst && \
	tar -I zstd -xf data.tar.zst ./lib/firmware/tegra21x_xusb_firmware --strip-components 3

endef

define TEGRA210_INSTALL_IMAGES_CMDS
	$(INSTALL) -m 0644 $(@D)/bootloader/boot.img $(BINARIES_DIR)
	$(INSTALL) -m 0644 $(@D)/bootloader/bmp.blob $(BINARIES_DIR)
	$(INSTALL) -m 0644 $(@D)/bootloader/rp4.blob $(BINARIES_DIR)
	$(INSTALL) -m 0644 $(@D)/bootloader/eks.img $(BINARIES_DIR)

	$(INSTALL) -m 0644 $(@D)/bootloader/signed/* $(BINARIES_DIR)
	ln -sf $(BINARIES_DIR)/kernel_tegra210-p3448-$(BR2_PACKAGE_TEGRA210_BOARDSKU)-p3449-0000-$(BR2_PACKAGE_TEGRA210_DTBFAB).dtb.encrypt \
		$(BINARIES_DIR)/kernel_tegra210.dtb.encrypt
endef

define TEGRA210_INSTALL_TARGET_CMDS
	$(INSTALL) -d $(TARGET_DIR)/boot/extlinux
	$(INSTALL) -m 0644 $(@D)/bootloader/extlinux.conf $(TARGET_DIR)/boot/extlinux
endef

define TEGRA210_INSTALL_INITRD
	$(INSTALL) -D -m 0644 $(@D)/bootloader/l4t_initrd.img $(TARGET_DIR)/boot/initrd
endef

define TEGRA210_NO_INITRD
	sed -i /INITRD/d $(TARGET_DIR)/boot/extlinux/extlinux.conf
	$(INSTALL) -d $(TARGET_DIR)/lib/firmware
	$(INSTALL) -m 0644 $(@D)/nv_tegra/l4t_deb_packages/tegra21x_xusb_firmware $(TARGET_DIR)/lib/firmware
endef

ifeq ($(BR2_PACKAGE_TEGRA210_INITRD),y)
TEGRA210_POST_INSTALL_TARGET_HOOKS += TEGRA210_INSTALL_INITRD
else
TEGRA210_POST_INSTALL_TARGET_HOOKS += TEGRA210_NO_INITRD
endif

$(eval $(generic-package))
