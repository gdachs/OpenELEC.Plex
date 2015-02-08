################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2014 Stephan Raue (stephan@openelec.tv)
#
#  OpenELEC is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 2 of the License, or
#  (at your option) any later version.
#
#  OpenELEC is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with OpenELEC.  If not, see <http://www.gnu.org/licenses/>.
################################################################################

PKG_NAME="konvergo"

case $PROJECT in
     Generic)
     PKG_VERSION="0.1"
     ;;
     RPi|RPi2)
     PKG_VERSION="0.1-rpi2"
     ;;
esac

PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="http://nightlies.plex.tv"
PKG_URL="$PKG_SITE/plex-oe-sources/$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain boost zlib bzip2 systemd pciutils lzo libass enca curl rtmpdump fontconfig fribidi tinyxml freetype taglib libxml2 libxslt ffmpeg mpv SDL2"
PKG_DEPENDS_HOST="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="mediacenter"
PKG_SHORTDESC="Plex Konvergo Mediacenter"
PKG_LONGDESC="Plex Konvergo is the king or PC clients for Plex :P"

PKG_IS_ADDON="no"
PKG_AUTORECONF="no"

case $PROJECT in
  Generic)
  ;;

  RPi|RPi2)
    PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET omxplayer"
  ;;
esac

configure_target() {

	pushd ${ROOT}/${BUILD}/${PKG_NAME}-${PKG_VERSION}

	case $PROJECT in
        	Generic)
		cmake -DCMAKE_BUILD_TYPE=Debug -DQTROOT=${ROOT}/${BUILD}/image/system/usr -DUSE_QTQUICK=on -DENABLE_MPV=on
        	;;

        	RPi|RPi2)
		cmake -DCMAKE_BUILD_TYPE=Debug -DQTROOT=${ROOT}/${BUILD}/image/system/usr -DUSE_QTQUICK=on -DENABLE_MPV=off -DENABLE_OMX=on
        	;;
	esac

	popd
}

make_target() {
  	make
}

makeinstall_target() {
        case $PROJECT in
                Generic)
                        pushd ${ROOT}/${PKG_BUILD}
                        make install
                        popd
                ;;
                RPi|RPi2)
                        unset CC CXX AR OBJCOPY STRIP CFLAGS CXXFLAGS CPPFLAGS LDFLAGS LD RANLIB
                        export QT_FORCE_PKGCONFIG=yes
                        unset QMAKESPEC

                        pushd ${ROOT}/${PKG_BUILD}
                        make install
                        popd
                ;;
        esac
}

pre_install() {
        makeinstall_target
}

