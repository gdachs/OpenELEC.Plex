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
PKG_VERSION="0.1"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="http://plexrpms.markwalker.dk"
PKG_URL="$PKG_SITE/private/$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain boost zlib bzip2 systemd pciutils lzo libass enca curl rtmpdump fontconfig fribidi tinyxml freetype taglib libxml2 libxslt ffmpeg mpv SDL2"
PKG_DEPENDS_HOST="toolchain"
PKG_PRIORITY="optional"
PKG_SECTION="mediacenter"
PKG_SHORTDESC="Plex Konvergo Mediacenter"
PKG_LONGDESC="Plex Konvergo is the king or PC clients for Plex :P"

PKG_IS_ADDON="no"
PKG_AUTORECONF="no"

# configure GPU drivers and dependencies:
  get_graphicdrivers

# for dbus support
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET dbus"

# needed for hosttools (Texturepacker)
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET lzo:host SDL:host SDL_image:host"

if [ "$DISPLAYSERVER" = "x11" ]; then
# for libX11 support
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET libX11 libXext libdrm"
# for libXrandr support
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET libXrandr"
  KODI_XORG="--enable-x11 --enable-xrandr"
else
  KODI_XORG="--disable-x11 --disable-xrandr"
fi

if [ ! "$OPENGL" = "no" ]; then
# for OpenGL (GLX) support
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET $OPENGL glu glew"
  KODI_OPENGL="--enable-gl"
else
  KODI_OPENGL="--disable-gl"
fi

if [ "$OPENGLES_SUPPORT" = yes ]; then
# for OpenGL-ES support
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET $OPENGLES"
  KODI_OPENGLES="--enable-gles"
else
  KODI_OPENGLES="--disable-gles"
fi

if [ "$SDL_SUPPORT" = yes ]; then
# for SDL support
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET SDL2"
  KODI_SDL="--enable-sdl"
else
  KODI_SDL="--disable-sdl"
fi

if [ "$ALSA_SUPPORT" = yes ]; then
# for ALSA support
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET alsa-lib"
  KODI_ALSA="--enable-alsa"
else
  KODI_ALSA="--disable-alsa"
fi

if [ "$PULSEAUDIO_SUPPORT" = yes ]; then
# for PulseAudio support
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET pulseaudio"
  KODI_PULSEAUDIO="--enable-pulse"
else
  KODI_PULSEAUDIO="--disable-pulse"
fi

if [ "$ESPEAK_SUPPORT" = yes ]; then
# for espeak support
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET espeak"
fi

if [ "$CEC_SUPPORT" = yes ]; then
# for CEC support
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET libcec"
  KODI_CEC="--enable-libcec"
else
  KODI_CEC="--disable-libcec"
fi

if [ "$KODI_SCR_RSXS" = yes ]; then
# for RSXS Screensaver support
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET libXt libXmu"
  KODI_RSXS="--enable-rsxs"
# fix build of RSXS Screensaver support if not using libiconv
  export jm_cv_func_gettimeofday_clobber=no
else
  KODI_RSXS="--disable-rsxs"
fi

if [ "$KODI_VIS_PROJECTM" = yes ]; then
# for ProjectM Visualisation support
  KODI_PROJECTM="--enable-projectm"
else
  KODI_PROJECTM="--disable-projectm"
fi

if [ "$KODI_VIS_GOOM" = yes ]; then
# for GOOM Visualisation support
  KODI_GOOM="--enable-goom"
else
  KODI_GOOM="--disable-goom"
fi

if [ "$KODI_VIS_WAVEFORM" = yes ]; then
# for Waveform Visualisation support
  KODI_WAVEFORM="--enable-waveform"
else
  KODI_WAVEFORM="--disable-waveform"
fi

if [ "$KODI_VIS_SPECTRUM" = yes ]; then
# for Spectrum Visualisation support
  KODI_SPECTRUM="--enable-spectrum"
else
  KODI_SPECTRUM="--disable-spectrum"
fi

if [ "$KODI_VIS_FISHBMC" = yes ]; then
# for FishBMC Visualisation support
  KODI_FISHBMC="--enable-fishbmc"
else
  KODI_FISHBMC="--disable-fishbmc"
fi

if [ "$JOYSTICK_SUPPORT" = yes ]; then
# for Joystick support
  KODI_JOYSTICK="--enable-joystick"
else
  KODI_JOYSTICK="--disable-joystick"
fi

if [ "$KODI_OPTICAL_SUPPORT" = yes ]; then
  KODI_OPTICAL="--enable-optical-drive"
else
  KODI_OPTICAL="--disable-optical-drive"
fi

if [ "$KODI_NONFREE_SUPPORT" = yes ]; then
# for non-free support
  KODI_NONFREE="--enable-non-free"
else
  KODI_NONFREE="--disable-non-free"
fi

if [ "$KODI_DVDCSS_SUPPORT" = yes ]; then
  KODI_DVDCSS="--enable-dvdcss"
else
  KODI_DVDCSS="--disable-dvdcss"
fi

if [ "$FAAC_SUPPORT" = yes ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET faac"
fi

if [ "$KODI_BLURAY_SUPPORT" = yes ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET libbluray"
  KODI_BLURAY="--enable-libbluray"
else
  KODI_BLURAY="--disable-libbluray"
fi

if [ "$AVAHI_DAEMON" = yes ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET avahi nss-mdns"
  KODI_AVAHI="--enable-avahi"
else
  KODI_AVAHI="--disable-avahi"
fi

if [ "$KODI_MYSQL_SUPPORT" = yes ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET mysql"
  KODI_MYSQL="--enable-mysql"
else
  KODI_MYSQL="--disable-mysql"
fi

if [ "$KODI_AIRPLAY_SUPPORT" = yes ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET libplist"
  KODI_AIRPLAY="--enable-airplay"
else
  KODI_AIRPLAY="--disable-airplay"
fi

if [ "$KODI_AIRTUNES_SUPPORT" = yes ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET libshairplay"
  KODI_AIRTUNES="--enable-airtunes"
else
  KODI_AIRTUNES="--disable-airtunes"
fi

if [ "$KODI_NFS_SUPPORT" = yes ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET libnfs"
  KODI_NFS="--enable-nfs"
else
  KODI_NFS="--disable-nfs"
fi

if [ "$KODI_AFP_SUPPORT" = yes ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET afpfs-ng"
  KODI_AFP="--enable-afpclient"
else
  KODI_AFP="--disable-afpclient"
fi

if [ "$KODI_SAMBA_SUPPORT" = yes ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET samba"
  KODI_SAMBA="--enable-samba"
else
  KODI_SAMBA="--disable-samba"
fi

if [ "$KODI_WEBSERVER_SUPPORT" = yes ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET libmicrohttpd"
  KODI_WEBSERVER="--enable-webserver"
else
  KODI_WEBSERVER="--disable-webserver"
fi

if [ "$KODI_UPNP_SUPPORT" = yes ]; then
  KODI_UPNP="--enable-upnp"
else
  KODI_UPNP="--disable-upnp"
fi

if [ "$KODI_SSHLIB_SUPPORT" = yes ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET libssh"
  KODI_SSH="--enable-ssh"
else
  KODI_SSH="--disable-ssh"
fi

if [ ! "$KODIPLAYER_DRIVER" = default ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET $KODIPLAYER_DRIVER"

  if [ "$KODIPLAYER_DRIVER" = bcm2835-driver ]; then
    KODI_OPENMAX="--enable-openmax"
    KODI_PLAYER="--enable-player=omxplayer"
    KODI_CODEC="--with-platform=raspberry-pi"
    BCM2835_INCLUDES="-I$SYSROOT_PREFIX/usr/include/interface/vcos/pthreads/ \
                      -I$SYSROOT_PREFIX/usr/include/interface/vmcs_host/linux"
    KODI_CFLAGS="$KODI_CFLAGS $BCM2835_INCLUDES"
    KODI_CXXFLAGS="$KODI_CXXFLAGS $BCM2835_INCLUDES"
  elif [ "$KODIPLAYER_DRIVER" = libfslvpuwrap ]; then
    KODI_CODEC="--enable-codec=imxvpu"
  else
    KODI_OPENMAX="--disable-openmax"
  fi
fi

if [ "$VDPAU_SUPPORT" = yes ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET libvdpau"
  KODI_VDPAU="--enable-vdpau"
else
  KODI_VDPAU="--disable-vdpau"
fi

if [ "$VAAPI_SUPPORT" = yes ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET libva-intel-driver"
  KODI_VAAPI="--enable-vaapi"
else
  KODI_VAAPI="--disable-vaapi"
fi

export CXX_FOR_BUILD="$HOST_CXX"
export CC_FOR_BUILD="$HOST_CC"
export CXXFLAGS_FOR_BUILD="$HOST_CXXFLAGS"
export CFLAGS_FOR_BUILD="$HOST_CFLAGS"
export LDFLAGS_FOR_BUILD="$HOST_LDFLAGS"

PKG_CONFIGURE_OPTS_TARGET="gl_cv_func_gettimeofday_clobber=no \
                           ac_cv_lib_bluetooth_hci_devid=no \
                           --disable-debug \
                           --disable-optimizations \
                           $KODI_OPENGL \
                           $KODI_OPENGLES \
                           $KODI_SDL \
                           $KODI_OPENMAX \
                           $KODI_VDPAU \
                           $KODI_VAAPI \
                           --disable-vtbdecoder \
                           --disable-tegra \
                           --disable-profiling \
                           $KODI_JOYSTICK \
                           $KODI_CEC \
                           --enable-udev \
                           --disable-libusb \
                           $KODI_GOOM \
                           $KODI_RSXS \
                           $KODI_PROJECTM \
                           $KODI_WAVEFORM \
                           $KODI_SPECTRUM \
                           $KODI_FISHBMC \
                           $KODI_XORG \
                           --disable-ccache \
                           $KODI_ALSA \
                           $KODI_PULSEAUDIO \
                           --enable-rtmp \
                           $KODI_SAMBA \
                           $KODI_NFS \
                           $KODI_AFP \
                           --enable-libvorbisenc \
                           --disable-libcap \
                           $KODI_DVDCSS \
                           --disable-mid \
                           $KODI_AVAHI \
                           $KODI_UPNP \
                           $KODI_MYSQL \
                           $KODI_SSH \
                           $KODI_AIRPLAY \
                           $KODI_AIRTUNES \
                           $KODI_NONFREE \
                           --disable-asap-codec \
                           $KODI_WEBSERVER \
                           $KODI_OPTICAL \
                           $KODI_BLURAY \
                           --enable-texturepacker \
                           --with-ffmpeg=shared \
                           $KODI_CODEC \
                           $KODI_PLAYER"

pre_configure_host() {
# kodi fails to build in subdirs
  cd $ROOT/$PKG_BUILD
    rm -rf .$HOST_NAME
}

make_host() {
  make -C tools/depends/native/JsonSchemaBuilder
}

makeinstall_host() {
  cp -PR tools/depends/native/JsonSchemaBuilder/native/JsonSchemaBuilder $ROOT/$TOOLCHAIN/bin
}

pre_build_target() {
# adding fake Makefile for stripped skin
  mkdir -p $PKG_BUILD/addons/skin.confluence/media
  touch $PKG_BUILD/addons/skin.confluence/media/Makefile.in

# autoreconf
  BOOTSTRAP_STANDALONE=1 make -C $PKG_BUILD -f bootstrap.mk
}

pre_configure_target() {
# kodi fails to build in subdirs
  cd $ROOT/$PKG_BUILD
    rm -rf .$TARGET_NAME

# kodi fails to build with LTO optimization if build without GOLD support
  [ ! "$GOLD_SUPPORT" = "yes" ] && strip_lto

# Todo: kodi segfaults on exit when building with LTO support
  strip_lto

  export CFLAGS="$CFLAGS $KODI_CFLAGS"
  export CXXFLAGS="$CXXFLAGS $KODI_CXXFLAGS"
  export LIBS="$LIBS -lz"

  export JSON_BUILDER=$ROOT/$TOOLCHAIN/bin/JsonSchemaBuilder
}

make_target() {
  make -j4 

}

post_makeinstall_target() {
  rm -rf $INSTALL/usr/bin/plex
  rm -rf $INSTALL/usr/bin/konvergo

  mkdir -p $INSTALL/usr/bin
    cp $PKG_DIR/scripts/cputemp $INSTALL/usr/bin
      ln -sf cputemp $INSTALL/usr/bin/gputemp
    cp $PKG_DIR/scripts/setwakeup.sh $INSTALL/usr/bin
    cp tools/EventClients/Clients/Kodi\ Send/kodi-send.py $INSTALL/usr/bin/kodi-send

  if [ ! "$DISPLAYSERVER" = "x11" ]; then
    rm -rf $INSTALL/usr/lib/kodi/kodi-xrandr
  fi

  if [ ! "$KODI_SCR_RSXS" = yes ]; then
    rm -rf $INSTALL/usr/share/kodi/addons/screensaver.rsxs.*
  fi

  if [ ! "$KODI_VIS_PROJECTM" = yes ]; then
    rm -rf $INSTALL/usr/share/kodi/addons/visualization.projectm
  fi

  rm -rf $INSTALL/usr/share/applications
  rm -rf $INSTALL/usr/share/icons
  rm -rf $INSTALL/usr/share/kodi/addons/service.xbmc.versioncheck
  rm -rf $INSTALL/usr/share/xsessions

# install project specific configs
  mkdir -p $INSTALL/usr/share/plex/config
    if [ -f $PROJECT_DIR/$PROJECT/plex/guisettings.xml ]; then
      cp -R $PROJECT_DIR/$PROJECT/plex/guisettings.xml $INSTALL/usr/share/plex/config
    fi

  if [ "$KODI_EXTRA_FONTS" = yes ]; then
    mkdir -p $INSTALL/usr/share/plex/media/Fonts
      cp $PKG_DIR/fonts/*.ttf $INSTALL/usr/share/plex/media/Fonts
  fi
}

post_install() {
# link default.target to kodi.target
  ln -sf kodi.target $INSTALL/usr/lib/systemd/system/default.target

# enable default services
  enable_service kodi-autostart.service
  enable_service kodi-cleanlogs.service
  enable_service kodi-hacks.service
  enable_service kodi-sources.service
  enable_service kodi-halt.service
  enable_service kodi-poweroff.service
  enable_service kodi-reboot.service
  enable_service kodi-waitonnetwork.service
  enable_service kodi.service
  enable_service kodi-lirc-suspend.service

}
