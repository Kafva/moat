#!/usr/bin/env bash
readonly MOAT_DIR=/tmp/moat
mkdir -p $MOAT_DIR
cp    ~/.newsboat/cache.db $MOAT_DIR
cp -H ~/.newsboat/urls $MOAT_DIR
cp -H ~/.newsboat/config $MOAT_DIR
