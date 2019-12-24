#!/usr/bin/env bash

while inotifywait -e close_write -r src
do
    clear
    echo
    elm make src/Main.elm --output=elm-main.js
    echo
done
