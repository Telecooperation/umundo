#!/bin/bash

#
# build ZeroMQ for android
#

# exit on error
set -e

ME=`basename $0`
DIR="$( cd "$( dirname "$0" )" && pwd )" 
DEST_DIR="${DIR}/../prebuilt/android"

if [ ! -f src/zmq.cpp ]; then
	echo
	echo "Cannot find src/zmq.cpp"
	echo "Run script from within zeroMQ directory:"
	echo "zeromq-3.1.0$ ../../../${ME}"
	echo
	exit
fi

# download updated config.guess and config.sub
#cd config
#wget http://git.savannah.gnu.org/cgit/config.git/plain/config.guess -O config.guess
#wget http://git.savannah.gnu.org/cgit/config.git/plain/config.sub -O config.sub
#cd ..

if [ -f Makefile ]; then
	make clean
fi

# if [ -f ispatched ]; then
# 	rm ./ispatched
# else
# 	patch -p1 < ../zeromq-3.1.0.android.patch
# fi
# touch ispatched

CC_COMMON_FLAGS="-I. -DANDROID -DTARGET_OS_ANDROID -fno-strict-aliasing -fno-omit-frame-pointer -fno-exceptions -fdata-sections -ffunction-sections"
CPP_COMMON_FLAGS="${CC_COMMON_FLAGS} -fno-rtti"


# # build for x86

CC_X86_FLAGS="${CC_COMMON_FLAGS} \
-funwind-tables \
-finline-limit=300"
CPP_X86_FLAGS="${CPP_COMMON_FLAGS} \
-funwind-tables \
-finline-limit=300"

X86_SYSROOT="${ANDROID_NDK}/platforms/android-9/arch-x86"
X86_TOOLCHAIN_ROOT="${ANDROID_NDK}/toolchains/x86-4.7/prebuilt/darwin-x86_64"
X86_TOOL_PREFIX="i686-linux-android"
X86_COMMON_FLAGS="\
-isystem ${ANDROID_NDK}/platforms/android-9/arch-x86/usr/include \
-isystem ${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++/4.7/include \
-isystem ${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++/4.7/libs/x86/include \
"
X86_CPP_STDLIB="${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++/4.7/libs/x86"

./configure \
CPP="${X86_TOOLCHAIN_ROOT}/bin/${X86_TOOL_PREFIX}-cpp" \
CXXCPP="${X86_TOOLCHAIN_ROOT}/bin/${X86_TOOL_PREFIX}-cpp" \
CPPFLAGS="--sysroot=${X86_SYSROOT}" \
CXXCPPFLAGS="--sysroot=${X86_SYSROOT}" \
CC="${X86_TOOLCHAIN_ROOT}/bin/${X86_TOOL_PREFIX}-gcc" \
CXX="${X86_TOOLCHAIN_ROOT}/bin/${X86_TOOL_PREFIX}-g++" \
LD="${X86_TOOLCHAIN_ROOT}/bin/${X86_TOOL_PREFIX}-ld" \
CXXFLAGS="-Os -s ${CPP_X86_FLAGS} --sysroot=${X86_SYSROOT} ${X86_COMMON_FLAGS}" \
CFLAGS="-Os -s ${CC_X86_FLAGS} --sysroot=${X86_SYSROOT} ${X86_COMMON_FLAGS}" \
LDFLAGS="--sysroot=${X86_SYSROOT} -L${X86_CPP_STDLIB} -lgnustl_static" \
AR="${X86_TOOLCHAIN_ROOT}/bin/${X86_TOOL_PREFIX}-ar" \
AS="${X86_TOOLCHAIN_ROOT}/bin/${X86_TOOL_PREFIX}-as" \
LIBTOOL="${X86_TOOLCHAIN_ROOT}/bin/${X86_TOOL_PREFIX}-libtool" \
STRIP="${X86_TOOLCHAIN_ROOT}/bin/${X86_TOOL_PREFIX}-strip" \
RANLIB="${X86_TOOLCHAIN_ROOT}/bin/${X86_TOOL_PREFIX}-ranlib" \
--prefix="${DEST_DIR}/x86" \
--disable-dependency-tracking \
--host=arm-linux-androideabi \
--enable-static \
--disable-shared \
--without-documentation \

set +e
make -j2
make install
rm ${DEST_DIR}/x86/lib/libzmq.la
rm -rf ${DEST_DIR}/x86/lib/pkgconfig
rm -rf ${DEST_DIR}/x86/bin
set -e

make clean

# build for arm

CC_ARMEABI_FLAGS="${CC_ARMEABI_FLAGS} \
-D__ARM_ARCH_5E__ -D__ARM_ARCH_5TE__ -D__ARM_ARCH_5T__ -D__ARM_ARCH_5__ \
-fsigned-char \
-march=armv5te \
-mtune=xscale \
-msoft-float \
-mfpu=vfp \
-mfloat-abi=softfp \
-fPIC \
-finline-limit=64"


ARM_SYSROOT="${ANDROID_NDK}/platforms/android-8/arch-arm"
ARMEABI_TOOLCHAIN_ROOT="${ANDROID_NDK}/toolchains/arm-linux-androideabi-4.7/prebuilt/darwin-x86_64"
ARMEABI_TOOL_PREFIX="arm-linux-androideabi"
ARMEABI_COMMON_FLAGS="\
-isystem ${ANDROID_NDK}/platforms/android-8/arch-arm/usr/include \
-isystem ${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++/4.7/include \
-isystem ${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++/4.7/libs/armeabi/include \
"
ARMEABI_CPP_STDLIB="${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++/4.7/libs/armeabi"

./configure \
CPP="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-cpp" \
CXXCPP="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-cpp" \
CPPFLAGS="--sysroot=${ARM_SYSROOT}" \
CXXCPPFLAGS="--sysroot=${ARM_SYSROOT}" \
CC="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-gcc" \
CXX="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-g++" \
LD="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-ld" \
CXXFLAGS="-Os -s ${CC_ARMEABI_FLAGS} --sysroot=${ARM_SYSROOT} ${ARMEABI_COMMON_FLAGS}" \
CFLAGS="-Os -s ${CC_ARMEABI_FLAGS} --sysroot=${ARM_SYSROOT} ${ARMEABI_COMMON_FLAGS}" \
LDFLAGS="--sysroot=${ARM_SYSROOT} -L${ARMEABI_CPP_STDLIB} -lgnustl_static" \
AR="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-ar" \
AS="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-as" \
LIBTOOL="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-libtool" \
STRIP="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-strip" \
RANLIB="${ARMEABI_TOOLCHAIN_ROOT}/bin/${ARMEABI_TOOL_PREFIX}-ranlib" \
--prefix="${DEST_DIR}/armeabi" \
--disable-dependency-tracking \
--host=arm-linux-androideabi \
--enable-static \
--disable-shared \
--without-documentation \

set +e
make -j2
make install
rm ${DEST_DIR}/armeabi/lib/libzmq.la
rm -rf ${DEST_DIR}/armeabi/lib/pkgconfig
rm -rf ${DEST_DIR}/armeabi/bin
set -e

# build for mips

# CC_MIPS_FLAGS="${CC_COMMON_FLAGS} \
# -fsigned-char \
# -fpic \
# -finline-functions \
# -funwind-tables \
# -fmessage-length=0 \
# -fno-inline-functions-called-once \
# -fgcse-after-reload \
# -frerun-cse-after-loop \
# -frename-registers"

# TODO if needed

echo
echo "Installed static libraries in ${DEST_DIR}"
echo