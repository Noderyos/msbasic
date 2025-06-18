.segment "CODE"

.ifdef NODERYOS

RS = %001
RW = %010
E  = %100


LCD_INIT:
	PHA

    LDA #$FF
    STA DDRA       ; Set A to output
    STA DDRB       ; Set B to output

    LDA #%00111000 ; 8 bit; 2 lines; 5x8 font
    STA PORTA
    LDA #$0
    STA PORTB
    LDA #E
    STA PORTB
    LDA #$0
    STA PORTB

    LDA #%00001110 ; Disp on; Cursor on; Blink off
    STA PORTA
    LDA #$0
    STA PORTB
    LDA #E
    STA PORTB
    LDA #$0
    STA PORTB

    LDA #%00000110 ; Increment ptr; No shift
    STA PORTA
    LDA #$0
    STA PORTB
    LDA #E
    STA PORTB
    LDA #$0
    STA PORTB

    LDA #%00000001 ; Clear display
    JSR LCD_WAIT
    STA PORTA
    LDA #$0
    STA PORTB
    LDA #E
    STA PORTB
    LDA #$0
    STA PORTB

    PLA
    RTS


LCD_WAIT:
    PHA

    LDA #$0
    STA DDRA
@lcd_busy:
    LDA #RW
    STA PORTB
    LDA #(RW | E)
    STA PORTB
    LDA PORTA
    AND #$80
    BNE @lcd_busy

    LDA #RW
    STA PORTB 
    LDA #$FF
    STA DDRA

    PLA
    RTS


LCD_INST:
	PHA

    JSR GETBYT
    TXA
	JSR LCD_WAIT
	STA PORTA
    LDA #$0
    STA PORTB
    LDA #E
    STA PORTB
    LDA #$0
    STA PORTB
	RTS


LCD_SEND:
	PHA
    JSR LCD_WAIT

    JSR GETBYT
    TXA
    STA PORTA
    LDA #RS
    STA PORTB
    LDA #(RS | E)
    STA PORTB
    LDA #RS
    STA PORTB

    PLA
    RTS

.endif