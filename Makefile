src = aluex-sawing-jig.scad

all: cutting-jig.stl end-jig.stl

%-jig.stl: $(src)
	openscad -Dmode='"$*"' -o $@ $<
