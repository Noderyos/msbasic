.segment "CODE"

.ifdef NODERYOS

RS = %0010000
RW = %0100000
E  = %1000000

LCD_INIT:
    LDA #%11111111
    STA DDRA

    ; Forcing 8-bit
    LDA #%0011
    STA PORTA
    ORA #E
    STA PORTA
    EOR #E
    STA PORTA

    LDA #%0011
    STA PORTA
    ORA #E
    STA PORTA
    EOR #E
    STA PORTA

    LDA #%0011
    STA PORTA
    ORA #E
    STA PORTA
    EOR #E
    STA PORTA

    ; Switching to 4-bit
    LDA #%0010
    STA PORTA
    ORA #E
    STA PORTA
    EOR #E
    STA PORTA

    LDA #%00101000 ; 4 bit; 2 lines; 5x8 font
    JSR INST_SEND
    LDA #%00001110 ; Disp on; Cursor on; Blink off
    JSR INST_SEND
    LDA #%00000110 ; Increment ptr; No shift
    JSR INST_SEND
    LDA #%00000001 ; Clear display
    JSR INST_SEND
    RTS


LCD_WAIT:
    PHA
    LDA #%11110000  ; Set D0-D3 as input
    STA DDRA
@lcd_busy:
    LDA #RW
    STA PORTA
    LDA #(RW | E)
    STA PORTA
    LDA PORTA
    PHA
    LDA #RW        ; Useless
    STA PORTA      ; fetch but
    LDA #(RW | E)  ; we need to
    STA PORTA      ; complete
    LDA PORTA      ; the 8-bit fetch
    PLA
    AND #%00001000
    BNE @lcd_busy

    LDA #RW
    STA PORTA
    LDA #%11111111
    STA DDRA
    PLA
    RTS


LCD_INST:
    JSR GETBYT
    TXA
INST_SEND:
    JSR LCD_WAIT

    PHA
    LSR
    LSR
    LSR
    LSR
    STA PORTA
    ORA #E
    STA PORTA
    EOR #E
    STA PORTA

    PLA
    AND #$0f
    STA PORTA
    ORA #E
    STA PORTA
    EOR #E
    STA PORTA

    RTS

LCD_SEND:
    JSR GETBYT
    TXA
DATA_SEND:
    JSR LCD_WAIT

    PHA
    LSR
    LSR
    LSR
    LSR
    ORA #RS
    STA PORTA
    ORA #E
    STA PORTA
    EOR #E
    STA PORTA

    PLA
    AND #$0f
    ORA #RS
    STA PORTA
    ORA #E
    STA PORTA
    EOR #E
    STA PORTA

    RTS
.endif