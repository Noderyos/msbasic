.setcpu "65C02"
.debuginfo
.segment "BIOS"

PORTB = $6000
PORTA = $6001
DDRB  = $6002
DDRA  = $6003
T1L   = $6004
T1H   = $6005
SR    = $600A
ACR   = $600B
IFR   = $600D


ACIA_DATA   = $5000
ACIA_STATUS = $5001
ACIA_CMD    = $5002
ACIA_CTRL   = $5003

ACIA_BUF = $0300

; Modifies:
SER_INIT:
    PHA
    LDA #$0
    STA READ_PTR
    STA WRITE_PTR
    LDA #$18      ; 8-N-1, 1200 baud.
    STA ACIA_CTRL
    LDA #$09      ; No parity, no echo, rx interrupts.
    STA ACIA_CMD
    PLA
    RTS

; Modifies: A
CHRIN:
    JSR     BUF_LEFT
    BEQ     @no_keypressed
    JSR     READ_BUF
    JSR     CHROUT          ; echo

    SEC
    RTS
@no_keypressed:
    CLC
    RTS

; Modifies: 
CHROUT:
    PHA
    PHY
.ifdef CONFIG_7E1
    AND #$7F
    TAY
    LDA LUT_7E1, Y
.endif
    STA     ACIA_DATA
    LDY     #$0D            ; txdelay_ = $80*5
@txdelay:                   ; $0D*(txdelay_+5)
    LDA     #$80            ; (approx. BNE is 1 cycle less when not branching)
@txdelay_:                  ; ~= 1192bps (without CHROUT prologue + epilogue)
    DEC
    BNE     @txdelay_
    DEY
    BNE     @txdelay
    PLY
    PLA
    RTS

; Modifies:
WRITE_BUF:
    PHX
    LDX WRITE_PTR
    STA ACIA_BUF, X
    INC WRITE_PTR
    PLX 
    RTS

; Modifies: A
READ_BUF:
    PHX
    LDX READ_PTR
    LDA ACIA_BUF, X
    INC READ_PTR
    PLX
    RTS

; Modifies A
BUF_LEFT:
    LDA WRITE_PTR
    SEC
    SBC READ_PTR
    RTS

; Modifies:
IRQ_INT:
    PHA
    LDA ACIA_STATUS
    AND #$08
    BEQ @not_recv
    LDA ACIA_DATA
.ifdef CONFIG_7E1
    AND #$7F
.endif
    JSR WRITE_BUF
@not_recv:
    PLA
    RTI

.ifdef CONFIG_7E1
LUT_7E1:
.byte $00,$81,$82,$03,$84,$05,$06,$87,$88,$09,$0A,$8B,$0C,$8D,$8E,$0F
.byte $90,$11,$12,$93,$14,$95,$96,$17,$18,$99,$9A,$1B,$9C,$1D,$1E,$9F
.byte $A0,$21,$22,$A3,$24,$A5,$A6,$27,$28,$A9,$AA,$2B,$AC,$2D,$2E,$AF
.byte $30,$B1,$B2,$33,$B4,$35,$36,$B7,$B8,$39,$3A,$BB,$3C,$BD,$BE,$3F
.byte $C0,$41,$42,$C3,$44,$C5,$C6,$47,$48,$C9,$CA,$4B,$CC,$4D,$4E,$CF
.byte $50,$D1,$D2,$53,$D4,$55,$56,$D7,$D8,$59,$5A,$DB,$5C,$DD,$DE,$5F
.byte $60,$E1,$E2,$63,$E4,$65,$66,$E7,$E8,$69,$6A,$EB,$6C,$ED,$EE,$6F
.byte $F0,$71,$72,$F3,$74,$F5,$F6,$77,$78,$F9,$FA,$7B,$FC,$7D,$7E,$FF
.endif

.include "wozmon.s"

.segment "RESETVEC"
    .word   $0F00    ; NMI
    .word   RESET    ; RESET
    .word   IRQ_INT  ; IRQ
