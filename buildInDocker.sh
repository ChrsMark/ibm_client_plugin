export PATH="${PATH}:/usr/lib/go-${GOVERSION}/bin:/go/bin"
export CGO_CFLAGS="-I/opt/mqm/inc/"
export CGO_LDFLAGS_ALLOW="-Wl,-rpath.*"
export GOCACHE=/tmp/.gocache

echo "Running as " `id`

# Build the libraries so they can be used by other programs
cd $GOPATH/src

echo "Using compiler:"
go version


# Build the library
cd $GOPATH
srcdir=src/$ORG/$REPO/

cd $srcdir
go build -buildmode=plugin -o $GOPATH/bin/ibmqlib_linux.so .
