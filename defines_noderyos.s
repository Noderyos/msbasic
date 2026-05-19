; configuration
CONFIG_2C := 1

CONFIG_SCRTCH_ORDER := 2

; Send 7E1 over 8N1 (W65C51 doesn't support parity)
CONFIG_7E1 := 1

; zero page
ZP_START1 = $00
ZP_START2 = $0F
ZP_START3 = $65
ZP_START4 = $70

; extra/override ZP variables
USR := GORESTART

; constants
SPACE_FOR_GOSUB := $3E
STACK_TOP := $FA
WIDTH := 40
WIDTH2 := 30
RAMSTART2 := $0400
MONCOUT := CHROUT
MONRDKEY := CHRIN
