include $(TOPDIR)/rules.mk

PKG_NAME:=libbsd
PKG_VERSION:=0.3.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://libbsd.freedesktop.org/releases
#PKG_MD5SUM:=d0870f2de55d59c1c8419f36e8fac150
#PKG_CAT:=zcat

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_INSTALL_DIR:=$(PKG_BUILD_DIR)/ipkg-install

PUBLIC_SHARE_INC_DIR=$(TOPDIR)/toolchain-qca-qsdk/include
LINUX_INC_DIR=$(LINUX_DIR)/include
LINUX_ARCH_INC_DIR=$(LINUX_DIR)/arch/arm/include

PKG_LICENSE:=BSD-4-Clause
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

PKG_INSTALL:=1

define Package/libbsd
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=@USE_GLIBC
  TITLE:=common BSD library
endef

define Package/libbsd/description
 This library provides useful functions commonly found on BSD systems, and lacking on others like GNU systems, thus making it easier to port projects with strong BSD origins, without needing to embed the same code over and over again on each project.
endef

define Build/Prepare
	rmdir $(PKG_BUILD_DIR)
	ln -s ${PWD}/$(PKG_NAME)/src $(PKG_BUILD_DIR)
#	cd $(PKG_BUILD_DIR) && ./autogen.sh && chmod 777 configure
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) $(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -I$(PUBLIC_SHARE_INC_DIR) -I$(LINUX_INC_DIR) -I$(LINUX_ARCH_INC_DIR)"
endef

define Build/Clean
	rm -rf $(PKG_BUILD_DIR)/ipkg
	rm -rf $(PKG_BUILD_DIR)
#	$(MAKE) distclean
#	cd src;	./antigen.sh; cd -
endef

define Build/InstallDev
	$(INSTALL_DIR) \
		$(STAGING_DIR)/usr/lib \
		$(STAGING_DIR)/usr/include

	$(CP) \
		$(PKG_BUILD_DIR)/libbsd.so* \
		$(STAGING_DIR)/usr/lib/

	$(CP) \
		$(PKG_BUILD_DIR)/include/* \
		$(STAGING_DIR)/usr/include/

	( cd $(STAGING_DIR)/usr/lib ; $(LN) libbsd.so.$(PKG_VERSION) libbsd.so )
endef

define Package/libbsd/install
	$(INSTALL_DIR) \
		$(1)/usr/lib

	$(CP) \
		$(PKG_BUILD_DIR)/libbsd.so* \
		$(1)/usr/lib/

	( cd $(1)/usr/lib ; $(LN) libbsd.so.$(PKG_VERSION) libbsd.so )
endef

$(eval $(call BuildPackage,libbsd))

