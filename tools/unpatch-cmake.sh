#!/bin/bash

CMAKE_DIR="$(readlink -f $(which cmake) | rev | cut -d'/' -f3- | rev)"

echo -e "\n### Un-Patching iOS-Initialize.cmake file in $CMAKE_DIR ###"

IOS_INITIALIZE_CMAKE_FILE="$CMAKE_DIR/share/cmake/Modules/Platform/iOS-Initialize.cmake"

sed -i '' 's/^#*//' $IOS_INITIALIZE_CMAKE_FILE

echo -e "### $IOS_INITIALIZE_CMAKE_FILE Un-Patched ###"

echo -e '```'
cat $IOS_INITIALIZE_CMAKE_FILE
echo -e '```'

echo -e '### Re-Patch file w/ `make patch-cmake` ###'
