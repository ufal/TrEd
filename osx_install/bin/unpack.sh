#!/bin/bash

hdiutil convert ./release-template-packed.dmg -format UDRW -o ./release-template.dmg -ov
