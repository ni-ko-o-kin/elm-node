#!/usr/bin/env bash

while inotifywait -e close_write -r elm-main.js run.js
do
    clear
    sleep 0.1s 
    echo
    node run.js
    echo
done