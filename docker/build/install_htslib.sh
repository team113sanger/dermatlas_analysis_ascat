#! /bin/bash

##### START OF COMMON BOILERPLATE #####

set -xe

if [[ -z "${TMPDIR}" ]]; then
  TMPDIR=/tmp
fi

set -u

if [ "$#" -lt "1" ] ; then
  echo "Please provide an installation path such as /opt/YOUR_PROJECT"
  exit 1
fi

# get path to this script
SCRIPT_PATH=`dirname $0`;
SCRIPT_PATH=`(cd $SCRIPT_PATH && pwd)`

# get the location to install to
INST_PATH=$1
mkdir -p $1
INST_PATH=`(cd $1 && pwd)`
echo $INST_PATH

# get current directory
INIT_DIR=`pwd`

CPU=`grep -c ^processor /proc/cpuinfo`
if [ $? -eq 0 ]; then
  if [ "$CPU" -gt "6" ]; then
    CPU=6
  fi
else
  CPU=1
fi
echo "Max compilation CPUs set to $CPU"

SETUP_DIR=$INIT_DIR/install_tmp
mkdir -p $SETUP_DIR/distro # don't delete the actual distro directory until the very end
mkdir -p $INST_PATH/bin
cd $SETUP_DIR

# make sure tools installed can see the install loc of libraries
set +u
export LD_LIBRARY_PATH=`echo $INST_PATH/lib:$LD_LIBRARY_PATH | perl -pe 's/:\$//;'`
export PATH=`echo $INST_PATH/bin:$PATH | perl -pe 's/:\$//;'`
export MANPATH=`echo $INST_PATH/man:$INST_PATH/share/man:$MANPATH | perl -pe 's/:\$//;'`
set -u

##### END OF COMMON BOILERPLATE #####


SOURCE_HTSLIB="https://github.com/samtools/htslib/releases/download/${VER_HTSLIB}/htslib-${VER_HTSLIB}.tar.bz2"

cd $SETUP_DIR
curl -sSL --retry 10 $SOURCE_HTSLIB > distro.tar.bz2

mkdir -p htslib
tar --strip-components 1 -C htslib -jxf distro.tar.bz2
cd htslib
./configure --enable-plugins --enable-libcurl --with-libdeflate --prefix=$INST_PATH \
CPPFLAGS="-I$INST_PATH/include" \
LDFLAGS="-L${INST_PATH}/lib -Wl,-R${INST_PATH}/lib"
make -j$CPU
make install
cd ../
rm -rf distro.* htslib
