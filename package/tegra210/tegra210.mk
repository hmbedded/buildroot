################################################################################
#
# Linux Tegra210 Board Support Package
#
################################################################################

TEGRA210_VERSION_MAJOR = 32
TEGRA210_VERSION_MINOR = 5.0
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
	ar x nvidia-l4t-xusb-firmware_32.5.0-20210115145440_arm64.deb data.tar.zst && \
	tar -I zstd -xf data.tar.zst ./lib/firmware/tegra21x_xusb_firmware --strip-components 3

endef

define TEGRA210_INSTALL_IMAGES_CMDS
	$(INSTALL) -m 0644 $(@D)/bootloader/boot.img $(BINARIES_DIR)/boot.img
	$(INSTALL) -m 0644 $(@D)/bootloader/bmp.blob $(BINARIES_DIR)/bmp.blob
	$(INSTALL) -m 0644 $(@D)/bootloader/rp4.blob $(BINARIES_DIR)/rp4.blob
	$(INSTALL) -m 0644 $(@D)/bootloader/eks.img $(BINARIES_DIR)/eks.img

	$(INSTALL) -m 0644 $(@D)/bootloader/signed/boot.img.encrypt $(BINARIES_DIR)/boot.img.encrypt
	$(INSTALL) -m 0644 $(@D)/bootloader/signed/cboot.bin.encrypt $(BINARIES_DIR)/cboot.bin.encrypt
	$(INSTALL) -m 0644 $(@D)/bootloader/signed/flash.xml $(BINARIES_DIR)/flash.xml
	$(INSTALL) -m 0644 $(@D)/bootloader/signed/flash.xml.bin $(BINARIES_DIR)/flash.xml.bin
	$(INSTALL) -m 0644 $(@D)/bootloader/signed/nvtboot.bin.encrypt $(BINARIES_DIR)/nvtboot.bin.encrypt
	$(INSTALL) -m 0644 $(@D)/bootloader/signed/nvtboot_cpu.bin.encrypt $(BINARIES_DIR)/nvtboot_cpu.bin.encrypt
	$(INSTALL) -m 0644 $(@D)/bootloader/signed/P3448_A00_lpddr4_204Mhz_P987.bct \
		$(BINARIES_DIR)/P3448_A00_lpddr4_204Mhz_P987.bct
	$(INSTALL) -m 0644 $(@D)/bootloader/signed/sc7entry-firmware.bin.encrypt $(BINARIES_DIR)/sc7entry-firmware.bin.encrypt
	$(INSTALL) -m 0644 $(@D)/bootloader/signed/kernel_tegra210-p3448-$(BR2_PACKAGE_TEGRA210_BOARDSKU)-p3449-0000-$(BR2_PACKAGE_TEGRA210_DTBFAB).dtb.encrypt \
		$(BINARIES_DIR)/kernel_tegra210-p3448-$(BR2_PACKAGE_TEGRA210_BOARDSKU)-p3449-0000-$(BR2_PACKAGE_TEGRA210_DTBFAB).dtb.encrypt
	ln -sf $(BINARIES_DIR)/kernel_tegra210-p3448-$(BR2_PACKAGE_TEGRA210_BOARDSKU)-p3449-0000-$(BR2_PACKAGE_TEGRA210_DTBFAB).dtb.encrypt \
		$(BINARIES_DIR)/kernel_tegra210.dtb.encrypt
	$(INSTALL) -m 0644 $(@D)/bootloader/signed/tos-mon-only.img.encrypt $(BINARIES_DIR)/tos-mon-only.img.encrypt
	$(INSTALL) -m 0644 $(@D)/bootloader/signed/warmboot.bin.encrypt $(BINARIES_DIR)/warmboot.bin.encrypt
endef

define TEGRA210_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0644 $(@D)/bootloader/extlinux.conf $(TARGET_DIR)/boot/extlinux/extlinux.conf
endef

define TEGRA210_INSTALL_INITRD
	$(INSTALL) -D -m 0644 $(@D)/bootloader/l4t_initrd.img $(TARGET_DIR)/boot/initrd
endef

define TEGRA210_NO_INITRD
	sed -i /INITRD/d $(TARGET_DIR)/boot/extlinux/extlinux.conf
	$(INSTALL) -D -m 0644 $(@D)/nv_tegra/l4t_deb_packages/tegra21x_xusb_firmware $(TARGET_DIR)/lib/firmware
endef

ifeq ($(BR2_PACKAGE_TEGRA210_INITRD),y)
TEGRA210_POST_INSTALL_TARGET_HOOKS += TEGRA210_INSTALL_INITRD
else
TEGRA210_POST_INSTALL_TARGET_HOOKS += TEGRA210_NO_INITRD
endif

$(eval $(generic-package))
