#!/bin/bash

find . -type f \( -iname "*.v" -o -iname "*.vinc" \) -exec vim {} +
