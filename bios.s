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
    LDA #$1F      ; 8-N-1, 19200 baud.
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
    STA     ACIA_DATA
    LDA     #$FF
@txdelay:       
    DEC
    BNE     @txdelay
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
    JSR WRITE_BUF
@not_recv:
    PLA
    RTI


.include "wozmon.s"

.segment "RESETVEC"
    .word   $0F00    ; NMI
    .word   RESET    ; RESET
    .word   IRQ_INT  ; IRQ
