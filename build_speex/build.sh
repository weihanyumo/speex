#!/bin/sh

CWD=`pwd`
OGGPATH=$CWD/"lib_ogg"
OGGHEADERPATH=$OGGPATH/"include"
SOURCE="speex"
FAT="fat"
SCRATCH="scratch"
THIN=`pwd`/"thin"
mkdir -p "$THIN"

CONFIGURE_FLAGS="-enable-static"
ARCHS="arm64 armv7s x86_64 i386 armv7"

for ARCH in $ARCHS
do
    echo "building $ARCH..."
    cd $CWD
    mkdir -p "$SCRATCH/$ARCH"
    cd "$SCRATCH/$ARCH"

    if [ "$ARCH" = "i386" -o "$ARCH" = "x86_64" ]
    then
        PLATFORM="iPhoneSimulator"
        if [ "$ARCH" = "x86_64" ]
        then
            SIMULATOR="-mios-simulator-version-min=7.0"
            HOST=x86_64-apple-darwin
        else
            SIMULATOR="-mios-simulator-version-min=5.0"
            HOST=i386-apple-darwin
        fi
    else
        PLATFORM="iPhoneOS"
        SIMULATOR=
        HOST=arm-apple-darwin
    fi

    XCRUN_SDK=`echo $PLATFORM | tr '[:upper:]' '[:lower:]'`
    CC="xcrun -sdk $XCRUN_SDK clang -arch $ARCH"
    CFLAGS="-arch $ARCH $SIMULATOR"
    if ! xcodebuild -version | grep "Xcode [1-6]\."
    then
        CFLAGS="$CFLAGS -fembed-bitcode"
    fi
    CXXFLAGS="$CFLAGS"
    LDFLAGS="$CFLAGS"

    CC=$CC $CWD/$SOURCE/configure \
    $CONFIGURE_FLAGS \
    --host=$HOST \
    --prefix="$THIN/$ARCH" \
    --with-ogg="$OGGPATH" \
    --with-ogg-includes=$OGGHEADERPATH
    CC="$CC" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"
    make -j5 install
    cd $CWD
done

echo "building fat lib..."
mkdir -p $FAT/lib
set - $ARCHS
CWD=`pwd`
cd $THIN/$1/lib
for LIB in *.a
do
    cd $CWD
    lipo -create `find $THIN -name $LIB` -output $FAT/lib/$LIB
done
cd $CWD
cp -rf $THIN/$1/include $FAT
