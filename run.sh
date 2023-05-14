#!/bin/bash

set -e
set -x

cd $HOME

CLONED_DIR="${HOME}/phplist_config"

chmod +x "${CLONED_DIR}/install_phplist.sh"

./phplist_config/install_phplist.sh

