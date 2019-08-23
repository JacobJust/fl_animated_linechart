#!/bin/sh
flutter test --coverage
lcov --remove ./coverage/lcov.info  'lib/generated/*' -o ./coverage/lcov_filtered.info
genhtml coverage/lcov_filtered.info -o coverage
if [ "$(uname)" == "Darwin" ]; then
    open coverage/index.html
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    xdg-open coverage/index.html
fi