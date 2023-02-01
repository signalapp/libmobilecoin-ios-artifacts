#!/bin/bash

CMAKE_DIR="$(perl -MCwd -e 'print Cwd::abs_path shift' $(which cmake) | rev | cut -d'/' -f3- | rev)"

echo -e "\n### Patching iOS-Initialize.cmake file in $CMAKE_DIR ###"

IOS_INITIALIZE_CMAKE_FILE="$CMAKE_DIR/share/cmake/Modules/Platform/iOS-Initialize.cmake"

sed -i '' '/FATAL_ERROR/ s/^#*/#/' $IOS_INITIALIZE_CMAKE_FILE

echo -e "### $IOS_INITIALIZE_CMAKE_FILE Patched ###"

echo -e '```'
cat $IOS_INITIALIZE_CMAKE_FILE
echo -e '```'

echo -e '### Un-patch file w/ `make unpatch-cmake` ###'
