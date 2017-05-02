LOGO := pine64-logo-120x175.png

all: bootlogo-pine64-1366x768.png

clean:
	rm bootlogo-pine64-*.png
	rm bootlogo-pine64-*.bmp

bootlogo-pine64-%.bmp:
	convert -size $* xc:black $@.background.bmp
	convert $@.background.bmp $(LOGO) -gravity center -composite -matte $@
	rm $@.background.bmp

bootlogo-pine64-%.png: bootlogo-pine64-%.bmp
	convert $< $@
