#!/bin/bash
 
 
zip -r "./zipped_src" "." \
    --exclude "./.git/*" \
    --exclude "./figs/*" \
    --exclude "./songs/*"
 
echo "Created: zipped_src"
 
