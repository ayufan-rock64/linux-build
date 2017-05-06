# https://github.com/longsleep/u-boot-pine64/blob/55c9c8c8ac005b1c00ac948386c60c4a741ebaa9/board/sunxi/common/power_check.c

SIZE := 1366x768

all: low_pwr.bmp bempty.bmp battery_charge.bmp

clean:
	rm -f icon-*.bmp
	rm -f low_pwr.bmp
	rm -f bempty.bmp
	rm -f battery_charge.bmp

low_pwr.bmp: icon-battery-low.bmp
	convert $< -gravity center -background black -extent $(SIZE) $@

bempty.bmp: icon-battery-empty.bmp
	convert $< -gravity center -background black -extent $(SIZE) $@

battery_charge.bmp: icon-charge.bmp
	convert $< -gravity center -background black -extent $(SIZE) $@

icon-%.bmp:
	convert $*.svg -size 128x128 -background black -flatten $@
