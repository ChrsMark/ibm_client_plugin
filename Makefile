
build_darwin:
	MQ_INSTALLATION_PATH=$(shell pwd)/ibmqlib_darwin GO_CFLAGS="-I$(shell pwd)/ibmqlib_darwin/inc" CGO_LDFLAGS="-L$(shell pwd)/ibmqlib_darwin/lib64 -Wl,-rpath,$(shell pwd)/ibmqlib_darwin/lib64" go build -buildmode=plugin -o ibmqlib_darwin.so .
