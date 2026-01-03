.segment "CODE"

.ifdef NODERYOS

SPI_SI  = %00000001 ; PB0
SPI_CLK = %00000010 ; PB1 CB1
SPI_CSB = %00000100 ; PB2

SPI_INIT:
    LDA DDRB
    ORA #(SPI_SI | SPI_CLK | SPI_CSB)
    STA DDRB

    LDA PORTB
    ORA #SPI_CSB ; Disable chip
    STA PORTB

    LDA ACR
    AND #%11100011
    ORA #%00001100
    STA ACR
    RTS

; Modifies: A
SPI_ENABLE:
    LDA PORTB
    AND #($FF ^ SPI_CSB) ; CSB = 0
    STA PORTB
    RTS

; Modifies: A
SPI_DISABLE:
    LDA PORTB
    ORA #SPI_CSB ; CSB = 1
    STA PORTB
    RTS

; Modifies: A, X
SPI_READ:
    lda PORTB
    ORA #SPI_SI ; To send 11111111 aka no data
    STA PORTB

    AND #($FF ^ SPI_CLK)
    TAX
    ORA #SPI_CLK

    STA PORTB
    STX PORTB
    STA PORTB
    STX PORTB
    STA PORTB
    STX PORTB
    STA PORTB
    STX PORTB
    STA PORTB
    STX PORTB
    STA PORTB
    STX PORTB
    STA PORTB
    STX PORTB
    STA PORTB
    STX PORTB

    LDA SR
    RTS

; Modifies: A, X
SPI_WRITE:
    PHY
    STA SPI_SR

    LDX #$08

    LDA PORTB
    AND #($FF ^ SPI_SI)

    TAY

@spi_w_loop:
    ROL SPI_SR
    TYA
    ROL

    STA PORTB
    EOR #SPI_CLK
    STA PORTB

    DEX
    BNE @spi_w_loop

    EOR #SPI_CLK
    STA PORTB

    LDA SR ; Retrieve data received
    PLY
    RTS

; Modifies: A
SPI_WAIT:
    JSR SPI_ENABLE

@spi_wait:
    LDA #$05 ; Read Status Register
    JSR SPI_WRITE
    JSR SPI_READ
    AND #$01 ; WIP
    BNE @spi_wait

    JSR SPI_DISABLE
    RTS

.endif
