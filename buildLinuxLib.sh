GOPATH="/go"

TAG="build-ibm-linux"
# Assume repo tags have been created in a sensible order
VER=`git tag -l | sort | tail -1 | sed "s/^v//g"`
if [ -z "$VER" ]
then
  VER="latest"
fi
echo "Building container $TAG:$VER"

# Build a container that has all the pieces needed to compile the Go programs for MQ
docker build --build-arg GOPATH_ARG=$GOPATH -t $TAG:$VER .
rc=$?

if [ $rc -eq 0 ]
then
  # Run the image to do the compilation and extract the files
  # from it into local directories mounted into the container.
  OUTBINDIR=$(pwd)/bin
  #OUTPKGDIR=$HOME/tmp/mq-golang-samples/pkg
  rm -rf $OUTBINDIR $OUTPKGDIR >/dev/null 2>&1
  mkdir -p $OUTBINDIR $OUTPKGDIR

  # The container will be run as the current user to ensure files
  # written back to the host image are owned by that person instead of root.
  uid=`id -u`
  gid=`id -g`

  # Mount an output directory
  # Delete the container once it's done its job
  docker run --rm \
          --user $uid:$gid \
          -v $OUTBINDIR:$GOPATH/bin \
          $TAG:$VER
  echo "Compiled library should now be in $OUTBINDIR"
fi