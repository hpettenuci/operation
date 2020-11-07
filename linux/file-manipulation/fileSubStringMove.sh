#!/bin/bash

TARGET=~/origem/
DESTINY=~/destino/
STRING="Substring to Search"

inotifywait -m -e create -e moved_to --format "%f" "${TARGET}$(date +%Y/%m/)" \
| while read FILENAME
    do
        if grep -q $STRING "${TARGET}$(date +%Y/%m/)${FILENAME}"; then
            mv "${TARGET}$(date +%Y/%m/)${FILENAME}" "${DESTINY}$(date +%Y/%m/)${FILENAME}"
        fi
    done
