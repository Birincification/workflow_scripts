#!/bin/bash -x
## -x : expands variables and prints commands as they are called

## goal is to directly call mapping and just pass all params
## needs to parse only input/outputdirs
##
## needs indexDir -> to mount into container
## samples dir -> to mount into container
## 

echo "podman run -v blabla --rm imageName "${@:2}

