files = $(wildcard *.svg)
targets = $(patsubst %.svg,%.png,$(files))

all: $(targets)

%.png: %.svg
	inkscape -e $@ -h 22 -w 22 $<
