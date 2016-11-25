#!/bin/bash

#find . -type f \( -iname "*.v" -o -iname "*.vinc" \) -exec vim {} +
find . -type f \( -iname "*.sv" -o -iname "*.svpkg" -o -iname "*.svinc" \) -exec vim {} +
