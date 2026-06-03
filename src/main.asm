.include "constants.inc"
.include "macros.asm"
.include "header.inc"
.include "reset.asm"
.include "controllers.asm"

.segment "ZEROPAGE"
sleeping: .res 1
buttons_held: .res 1
buttons_pressed: .res 1

x_pos_hi: .res 1
x_pos_lo: .res 1
y_pos_hi: .res 1
y_pos_lo: .res 1
x_speed_hi: .res 1
x_speed_lo: .res 1
y_speed_hi: .res 1
y_speed_lo: .res 1

.segment "CODE"

.proc irq_handler
  rti
.endproc

.proc nmi_handler
  SAVE_REGISTERS

  lda #$00
  sta OAMADDR
  lda #$02
  sta OAMDMA
  lda #$00

  jsr read_controller

; --------------------------------------------------
; This is the PPU clean up section, so rendering the next frame starts properly.
; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
; enable sprites, enable background, no clipping on left side
; --------------------------------------------------
  lda #%10010000
  sta PPUCTRL
  lda #%00011110
  sta PPUMASK

; --------------------------------------------------
; loop
; --------------------------------------------------
  lda #$00
  sta sleeping

  RESTORE_REGISTERS

  rti
.endproc

.proc clear_oam
  SAVE_REGISTERS

	ldx #$00
	lda #$F8
@clear_oam:
	sta $0200, x ; set sprite y-positions off the screen
	inx
	inx
	inx
	inx
	bne @clear_oam

  RESTORE_REGISTERS

  rts
.endproc

.proc main

vblankwait1:       ; wait for another vblank before continuing
  bit PPUSTATUS
  WAIT_VBLANK

  ldx PPUSTATUS
  ldx #$3f
  stx PPUADDR
  ldx #$00
  stx PPUADDR

load_palettes:
  lda palettes,X
  sta PPUDATA
  inx
  cpx #$20 ; there are 32 colours to load
  bne load_palettes

  lda #%10010000  ; turn on NMIs, sprites use first pattern table
  sta PPUCTRL
  lda #%00011110  ; turn on screen
  sta PPUMASK

  WAIT_VBLANK

mainloop:

; --------------------------------------------------
; update the sprite oam
; --------------------------------------------------
  lda y_pos_hi
  sta $0200
  lda #$01 ; sprite tiile gfx
  sta $0201
  lda #$01 ; palette
  sta $0202
  lda x_pos_hi
  sta $0203

; --------------------------------------------------
; controls
; --------------------------------------------------
  lda buttons_held
  and #BTN_RIGHT
  beq button_released

  inc x_pos_hi
  jmp done
button_released:
  inc y_pos_hi

done:
; --------------------------------------------------
; loop
; --------------------------------------------------
  inc sleeping
sleep:
  lda sleeping
  bne sleep

  jmp mainloop
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "CHR"
.incbin "graphics.chr"

.segment "RODATA"

palettes:
  .byte $0f,$00,$10,$30 ; background
  .byte $0f,$01,$21,$31
  .byte $0f,$06,$16,$26
  .byte $0f,$09,$19,$29

  .byte $0f,$00,$10,$30 ; sprite
  .byte $0f,$01,$21,$31
  .byte $0f,$06,$16,$26
  .byte $0f,$09,$19,$29
