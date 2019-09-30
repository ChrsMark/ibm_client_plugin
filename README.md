## Plugins
| Target Environment   |      Plugin         |
|----------------------|:-------------------:|
| Linux                |  ibmqlib_linux.so   | 
| Darwin               |  ibmqlib_darwin.so  |

## Building the plugins

#### Building the Linux plugin
1. Download IBM redistributable client:
```
curl -LO "https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/mqdev/redist/9.1.3.0-IBM-MQC-Redist-LinuxX64.tar.gz"
```
2. Unpack the client:
```
tar -zxf 9.1.3.0-IBM-MQC-Redist-LinuxX64.tar.gz -C IBM-lib/
```
3. Set environment:
```
export CGO_LDFLAGS_ALLOW="-Wl,-rpath.*"
export MQ_INSTALLATION_PATH=/my/mq/dir
export CGO_CFLAGS="-I$MQ_INSTALLATION_PATH/inc"
export CGO_LDFLAGS="-L$MQ_INSTALLATION_PATH/lib64 -Wl,-rpath,$MQ_INSTALLATION_PATH/lib64"
```
4. Build the client's shared library:
```
go build -buildmode=plugin -o ibmqlib_linux.so .
```

#### Building the Darwin plugin
`make build_darwin`

#### Building the Linux plugin
`bash buildLinuxLib.sh`
Then the library should be under `./bin` path. In order to update the
 upstream with an updated linux library `cp ./bin/ibmqlib_linux.so .` and push.