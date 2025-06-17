ISCNTC:
        jsr MONRDKEY
        bcc @cntc_rts
        cmp #3
        bne @cntc_rts
        jmp @cntc_fall

@cntc_rts:
        rts

@cntc_fall:
        ; Fall through
