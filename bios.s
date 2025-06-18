.setcpu "65C02"
.debuginfo
.segment "BIOS"

PORTB = $6000
PORTA = $6001
DDRB  = $6002
DDRA  = $6003

ACIA_DATA   = $5000
ACIA_STATUS = $5001
ACIA_CMD    = $5002
ACIA_CTRL   = $5003

SERIAL_BUFFER = $0300


; Modifies:
LOAD:
    RTS

; Modifies:
SAVE:
    RTS

; Modifies: A
CHRIN:
    PHX
    JSR     BUF_LEFT
    BEQ     @no_keypressed
    JSR     READ_BUF
    JSR     CHROUT          ; echo

    PLX
    SEC
    RTS
@no_keypressed:
    PLX
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

; Modifies: A
INIT_BUF:
    LDA #$0
    STA READ_PTR
    STA WRITE_PTR
    RTS

; Modifies: X
WRITE_BUF:
    LDX WRITE_PTR
    STA SERIAL_BUFFER, X
    INC WRITE_PTR
    RTS

; Modifies: A, X
READ_BUF:
    LDX READ_PTR
    LDA SERIAL_BUFFER, X
    INC READ_PTR
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
    PHX
    LDA ACIA_STATUS
    AND #$08
    BEQ @not_recv
    LDA ACIA_DATA
    JSR WRITE_BUF
@not_recv:
    PLX
    PLA
    RTI


.include "wozmon.s"

.segment "RESETVEC"
    .word   $0F00    ; NMI
    .word   RESET    ; RESET
    .word   IRQ_INT  ; IRQ
