.segment "ZEROPAGE"

.segment "CODE"
.export reset_handler
.proc reset_handler
  sei
  cld
  ldx #$40
  stx APU
  ldx #$FF
  txs
  inx
  stx PPUCTRL
  stx PPUMASK
  stx IRQ_ENABLE
  bit PPUSTATUS

  WAIT_VBLANK

	ldx #$00
	lda #$FF
clear_oam:
	sta PPUCTRL, x ; set sprite y-positions off the screen
	inx
	inx
	inx
	inx
	bne clear_oam

; --------------------------------------------------
; reset variables here
; --------------------------------------------------
  lda #$00
  sta x_pos_hi
  sta x_pos_lo
  sta y_pos_hi
  sta y_pos_lo
  sta x_speed_hi
  sta x_speed_lo
  sta y_speed_hi
  sta y_speed_lo

  WAIT_VBLANK
  
  jmp main
.endproc