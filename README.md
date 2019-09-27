## Plugins
| Target Environment   |      Plugin         |
|----------------------|:-------------------:|
| Linux                |  ibmqlib_linux.so   | 
| Windows              |  ibmqlib_windows.so | 
| Darwin               |  ibmqlib_darwin.so  |

## Building the plugins

#### Building the Darwin plugin
`make build_darwin`

#### Building the Linux plugin
`bash buildLinuxLib.sh`
Then the library should be under `./bin` path. In order to update the
 upstream with an updated linux library `cp ./bin/ibmqlib_linux.so .` and push.