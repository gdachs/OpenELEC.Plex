################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
#
#  This Program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2, or (at your option)
#  any later version.
#
#  This Program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with OpenELEC.tv; see the file COPYING.  If not, write to
#  the Free Software Foundation, 51 Franklin Street, Suite 500, Boston, MA 02110, USA.
#  http://www.gnu.org/copyleft/gpl.html
################################################################################

PKG_NAME="libshairport"
PKG_VERSION="1.2.0.20310_lib"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="http://www.xbmc.org"
PKG_URL="http://mirrors.xbmc.org/build-deps/darwin-libs/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS=""
PKG_BUILD_DEPENDS="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="network"
PKG_SHORTDESC="libshairport: emulates AirPort Express"
PKG_LONGDESC="libshairPort emulates an AirPort Express for the purpose of streaming music from iTunes and compatible iPods."
PKG_IS_ADDON="no"

PKG_AUTORECONF="yes"


configure_target() {

	cd $ROOT/$PKG_BUILD
	./configure --host=$TARGET_NAME \
							--build=$HOST_NAME \
							--prefix=/usr \
							--sysconfdir=/etc \
							--disable-static \
							--enable-shared \



}



make_target() {
	make


}

post_makeinstall_target() {

	mkdir -p $INSTALL/usr/lib
		cp -P $ROOT/$PKG_BUILD/src/.libs/*.so* $INSTALL/usr/lib
}

