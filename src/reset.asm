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
  sta xhigh
  sta xlow
  sta speed

  WAIT_VBLANK
  
  jmp main
.endproc