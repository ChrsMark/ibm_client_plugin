
CGO_LDFLAGS_ALLOW := "-Wl,-rpath.*"

build_darwin:
	MQ_INSTALLATION_PATH=$(shell pwd)/ibmqlib_darwin CGO_CFLAGS="-I$(shell pwd)/ibmqlib_darwin/inc" CGO_LDFLAGS="-L$(shell pwd)/ibmqlib_darwin/lib64 -Wl,-rpath,$(shell pwd)/ibmqlib_darwin/lib64" go build -buildmode=plugin -o ibmqlib_darwin.so .

build_linux:
	MQ_INSTALLATION_PATH=$(shell pwd)/ibmqlib_linux CGO_CFLAGS="-I$(shell pwd)/ibmqlib_linux/inc" CGO_LDFLAGS="-L$(shell pwd)/ibmqlib_linux/lib64 -Wl,-rpath,$(shell pwd)/ibmqlib_linux/lib64" go build -buildmode=plugin -o ibmqlib_linux.so .
