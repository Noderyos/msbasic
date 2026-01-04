.segment "CODE"

.setcpu "65C02"

; Modifies: A, X
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

    PHY
    LDY #$00
@load_loop:
    JSR SPI_READ
    CMP #$FF
    BEQ @load_end

    STA (FLPTR),Y

    ; 16-bit INC
    INC FLPTR
    BNE @load_loop
    INC FLPTR+1
    JMP @load_loop

@load_end:
    PLY
    JSR SPI_DISABLE

    LDA FLPTR
    STA VARTAB
    STA ARYTAB
    LDA FLPTR+1
    STA VARTAB+1
    STA ARYTAB+1

    JMP FIX_LINKS
    RTS ; Should never execute this

; Modifies: A, X
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

    PHY
    LDY #$00
@save_loop:
    ; Compare FLPTR+Y to VARTAB <=> end of TXTTAB
    TYA
    CLC
    ADC FLPTR
    TAX             ; Low byte sum -> X
    LDA #$00
    ADC FLPTR+1     ; High byte sum -> A

    CMP VARTAB+1
    BCC @continue   ; if High < VARTAB High, keep going
    BNE @save_end   ; if High > VARTAB High, stop
    CPX VARTAB      ; if High == VARTAB High, check Low
    BCS @save_end

@continue:
    LDA (FLPTR),Y
    JSR SPI_WRITE

    INY
    BNE @save_loop
    INC FLPTR+1
    JMP @save_loop

@save_end:
    PLY
    JSR SPI_DISABLE

    JSR SPI_WAIT ; Wait for writing

    RTS
