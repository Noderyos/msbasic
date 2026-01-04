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
LOAD:
    JSR SPI_ENABLE
    LDA #$03 ; Read data bytes
    JSR SPI_WRITE

    LDA #$00 ; First block
    JSR SPI_WRITE
    LDA #$00
    JSR SPI_WRITE
    LDA #$00
    JSR SPI_WRITE

    LDA #<RAMSTART2
    STA FLPTR
    LDA #>RAMSTART2
    STA FLPTR+1

    ; TXTTAB-1 must be NULL
    LDA #$00
    TAY
    STA (FLPTR), Y
    INC FLPTR

    LDA FLPTR
    STA TXTTAB
    LDA FLPTR+1
    STA TXTTAB+1

@load_loop:
    JSR SPI_READ
    CMP #$FF
    BEQ @load_end

    LDY #$00
    STA (FLPTR),Y

    INC FLPTR
    BNE @load_loop
    INC FLPTR+1
    JMP @load_loop

@load_end:
    JSR SPI_DISABLE

    LDA FLPTR
    STA VARTAB
    STA ARYTAB
    LDA FLPTR+1
    STA VARTAB+1
    STA ARYTAB+1

    JMP FIX_LINKS
    RTS ; Should never execute this

; Modifies:
SAVE:
    JSR SPI_ENABLE
    LDA #$06 ; Write enable
    JSR SPI_WRITE
    JSR SPI_DISABLE

    JSR SPI_ENABLE
    LDA #$C7 ; Chip erase
    JSR SPI_WRITE
    JSR SPI_DISABLE

    JSR SPI_WAIT ; Wait for erasing

    JSR SPI_ENABLE
    LDA #$06 ; Write enable
    JSR SPI_WRITE
    JSR SPI_DISABLE

    JSR SPI_ENABLE
    LDA #$02 ; Page program
    JSR SPI_WRITE

    LDA #$00 ; First block
    JSR SPI_WRITE
    LDA #$00
    JSR SPI_WRITE
    LDA #$00
    JSR SPI_WRITE

    LDA TXTTAB
    STA FLPTR
    LDA TXTTAB+1
    STA FLPTR+1

@save_loop:
    LDA FLPTR
    CMP VARTAB
    LDA FLPTR+1
    SBC VARTAB+1
    BCS @save_end ; FLPTR >= VARTAB, end for TXTTAB

    LDY #$00
    LDA (FLPTR),Y
    JSR SPI_WRITE

    ; 16-bit INC
    INC FLPTR
    BNE @save_loop
    INC FLPTR+1
    JMP @save_loop

@save_end:
    JSR SPI_DISABLE

    JSR SPI_WAIT ; Wait for writing

    RTS

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
