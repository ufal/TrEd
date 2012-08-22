#!/bin/bash

hdiutil convert "$1" -format UDZO -o ./release-template-packed.dmg -ov
