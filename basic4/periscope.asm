!to "periscope.prg",cbm

;  _ __  ___  _ _ (_) ___ __  ___  _ __  ___ 
; | '_ \/ -_)| '_|| |(_-</ _|/ _ \| '_ \/ -_)
; | .__/\___||_|  |_|/__/\__|\___/| .__/\___|
; |_|                             |_|        
;
;
; build march 2025
;
; revision 0.2

s_lo         = $0a
s_hi         = $0b
t_lo         = $0c
t_hi         = $0d
bytes_line   = $0e
temp         = $0f
byte_counter = $b3
down_counter = $10  
up_counter   = $11  
track        = $12
sector       = $13
port         = $20
lo_nib       = $15
hi_nib       = $16
ofs          = $17
bytes        = $18
chipline     = $19
addrline     = $20

screen_ram   = $8000
register0    = $8800
register1    = $8801

reset        = $fd16
hexout       = $d722
space        = $d52e
clrscr       = $e015
bsout        = $ffd2
get          = $ffe4
basin        = $ffcf
warmstart    = $b74a 
c_col        = $c6
c_row        = $d8

portbuf = $027a

; Basicstart
*= $0401
!byte $0c,$08,$0a,$00,$9e,$31,$30,$33,$39,$00,$00,$00,$00
*=$040f
        
          
          
main:     jsr clrscr     
          lda #$0e
          sta $e84c
; build start-screen
          ldy #$00
-         lda startscreen,y
          sta $8000,y 
          lda startscreen+$100,y
          sta $8100,y 
          lda startscreen+$200,y
          sta $8200,y 
          lda startscreen+$300,y
          sta $8300,y 
          iny
          bne -
 ;setups 
          lda #$8c
          sta $0901
          lda #$02
          sta $0902  
          ldy #$00
          sty chipline
          sty addrline          
          lda #$81
          sta t_hi
          lda #$1c
          sta t_lo                   
          lda #$82
          sta s_hi
          lda #$84
          sta s_lo

; build imverted lines          
-         lda (t_lo),y
          ora #$80
          sta (t_lo),y
          iny
          cpy #$17
          bne -
                   
          ldy #$00
-         lda (s_lo),y
          ora #$80
          sta (s_lo),y
          iny
          cpy #$0e
          bne -
         
           
; keyboard

keys:
-         jsr get
          cmp #$20
          bne + 
          jmp start
+         cmp #$43
          bne +
          jsr move_chip
+         cmp #$41
          bne +
          jsr move_addr 

+         jmp - 


; lightbar for chip-selection
move_chip:
          inc chipline
          lda $0902 
          asl
          sta $0902
          ldy #$00
-         lda (t_lo),y
          and #$7f
          sta (t_lo),y
          iny
          cpy #$17
          bne -
          lda chipline
          cmp #$03
          bne +
          lda #$02
          sta $0902
          lda #$80
          sta t_hi
          lda #$f4
          sta t_lo
          lda #$00
          sta chipline
+         clc
          lda t_lo
          adc #$28
          sta t_lo
          bcc + 
          inc t_hi
+         ldy #$00
-         lda (t_lo),y
          ora #$80
          sta (t_lo),y
          iny
          cpy #$17
          bne -
          jmp keys

; lightbar for address-selection
move_addr: 
          inc $0901
          inc addrline
          ldy #$00
-         lda (s_lo),y
          and #$7f
          sta (s_lo),y
          iny
          cpy #$0e
          bne -
          lda addrline
          cmp #$02
          bne +        
          lda #$82
          sta s_hi
          lda #$5c
          sta s_lo    
          lda #$00
          sta addrline
          lda #$8c
          sta $0901
+         clc
          lda s_lo
          adc #$28
          sta s_lo
          bcc + 
          inc s_hi
+         ldy #$00
-         lda (s_lo),y
          ora #$80
          sta (s_lo),y
          iny
          cpy #$0e
          bne -
          jmp keys

; monitor

start:
          jsr clrscr
          lda #$0e
          sta $e84c
          lda #$00
          tay
          sta sector
          sta track
          sta register0
          sta register1
          sta ofs 
          sta lo_nib
          sta bytes
          lda $0900
          sta port
          lda $0901
          sta port+1
          lda $0902
          sta maxtrack
          jsr show_sector

show_sector:
          lda track
          ora #$80
          sta register1          
          lda #$80
          sta t_hi
          lda #$6e
          sta t_lo          
          ldy #$4f            
-         lda screen,y
          sta screen_ram,y
          dey
          bpl -
          ldy #$00  
          sty temp
          sty bytes_line                  
          lda #$00
          sta c_row
          lda #$1a
          sta c_col
          lda #$20
          jsr bsout
          lda #$20
          jsr bsout
          lda #$1a
          sta c_col
          lda track
          jsr hexout          ; show track  
          lda #$00
          sta c_row
          lda #$25
          sta c_col
          lda sector
          jsr hexout
          lda #$02
          sta c_row
          and #$00
          tay  
          tax 
          sta c_col
          sty down_counter          
; offset

          lda #$80
          sta s_hi
          lda #$50
          sta s_lo          
-         jsr byteline        ; build 
          inc temp
          lda temp
          cmp #20             ; 23 lines  
          bne -
          sty up_counter  
          lda track
          and #$7f
          sta register1            


keyboard:
          jsr get
          cmp #$11            ; cursor 
          bne + 
          jmp cur_up
+         cmp #"2"            ; down
          bne +
          jmp cur_up                     
+         cmp #$91            ; cursor 
          bne +
          jmp cur_down:  
+         cmp #"8"            ; up
          bne +
          jmp cur_down
+         cmp #$48            ; display help
          bne +
          jmp help
+         cmp #$51            ; quit
          bne +
          jsr clrscr
          lda #$0e
          sta $e84c
          ldy #$00
-         lda msg,y
          sta $8000,y
          iny
          cpy #$19
          bne -
          jmp warmstart
+         cmp #$53            ; sector 
          bne +
          jmp user_sector
+         cmp #$54            ; track
          bne +
          jmp user_track
+         cmp #$52            ; restart
          bne +
          jmp main
+         jmp keyboard

msg: 
!pet "have a nice day, hacker !"

;--------------------------------------
; build line
byteline:         
          lda #$00 
          sta bytes_line
          lda track                      
          ora #$80
          sta register1           
; show offset $xx
          ldy #$00
          lda #"$"
          sta (s_lo),y 
          jsr inc_lo 
          lda ofs 
          pha 
          lsr
          lsr
          lsr
          lsr
          tay 
          lda hex_table,y
          ldy #$00
          sta (s_lo),y
          jsr inc_lo 
          pla      
          and #$0f
          tay
          lda hex_table,y
          ldy #$00
          sta (s_lo),y
          jsr inc_lo 
          lda #$20
          sta (s_lo),y          
          clc 
          lda ofs
          adc #$08
          sta ofs 
          lda bytes 
          tay             
-         lda (port),y
          sta portbuf,y
          tya
          pha
          lda (port),y  
          pha 
          lsr
          lsr
          lsr
          lsr
          tay 
          lda hex_table,y
          sta hi_nib        
          pla      
          and #$0f
          tay
          lda hex_table,y
          sta lo_nib
          ldy #$00            
          jsr inc_lo 
          lda hi_nib
          sta (s_lo),y
          jsr inc_lo 
          lda lo_nib
          sta (s_lo),y
          jsr inc_lo 
          lda #$20
          sta (s_lo),y
          pla
          tay
          iny         
          tya
          sta bytes  
          inc bytes_line
          lda bytes_line
          cmp #$08
          bne -                      
          jsr inc_lo 
          clc
          lda s_lo
          adc #$03
          sta s_lo
          bcc +
          inc s_hi 
+         ldy #$00
          lda bytes
          sbc #$07
          tax
-         lda portbuf,x          
          and #$7f
          sta (s_lo),y
          jsr inc_lo 
          inx
          cpx bytes
          bne -         
inc_lo:   inc s_lo 
          lda s_lo
          bne +
          inc s_hi
+         rts

; cursor up                  
cur_up:   
          lda ofs
          bne +
          jmp keyboard
+         lda bytes
          sbc #152
          sta bytes
          lda ofs
          sbc #152
          sta ofs
          lda #$80
          sta s_hi
          lda #$50
          sta s_lo          
          lda #$00
          tax  
          sta temp
-         jsr byteline        ; build 
          inc temp
          lda temp
          cmp #20             ; 23 lines  
          bne -
          jmp keyboard

;cursor down
cur_down:   

          lda ofs
          cmp #$a0
          beq ++
          cmp #$00
          bne + 
          lda #88
          sta ofs
          lda bytes
          sbc #168
          sta bytes
          jmp j  
+         lda bytes
          sbc #168
          sta bytes
          lda ofs
          sbc #168
          sta ofs
j:        lda #$80
          sta s_hi
          lda #$50
          sta s_lo          
          lda #$00
          tax  
          sta temp
-         jsr byteline        ; build
          inc temp
          lda temp
          cmp #20             ; 23 lines  
          bne -
++        jmp keyboard


; capture screen and display help

help:     ldy #$00
-         lda $8000,y
          sta buffer+$100,y 
          lda helpscreen,y
          sta $8000,y
          lda $8100,y
          sta buffer+$200,y 
          lda helpscreen+$100,y
          sta $8100,y
          lda $8200,y
          sta buffer+$300,y 
          lda helpscreen+$200,y
          sta $8200,y
          lda $8300,y
          sta buffer+$400,y 
          lda helpscreen+$300,y
          sta $8300,y
          iny
          bne -            
-         jsr get
          cmp #$20
          beq +
          bne -
+         ldy #$00
-         lda buffer+$100,y 
          sta $8000,y 
          lda buffer+$200,y 
          sta $8100,y 
          lda buffer+$300,y 
          sta $8200,y 
          lda buffer+$400,y 
          sta $8300,y 
          iny
          bne -                    
          jmp keyboard

; input for track and sector

user_input:
          ldy #$00 
-         jsr basin
          cmp #$0d
          beq +  
          sta $0330,y
          iny
          bne -
+         lda $0331
          and #$f0
          cmp #$40
          beq +
          lda $0331
          and #$0f
          sta $0333
          jmp ++
+         lda $0331
          and #$0f
          tay
          lda hex_low_bytes,y
          sta $0333                      
++        lda $0330
          and #$f0
          cmp #$40
          beq +
          lda $0330
          and #$0f
          asl
          asl
          asl
          asl
          sta $0334
          jmp ++
+         lda $0330
          and #$0f
          tay
          lda hex_bytes,y
          sta $0334                      
++        lda $0334
          ora $0333
          sta $0335
          rts

;sector input          

user_sector:
          lda #$00
          sta c_row
          lda #$25
          sta c_col
          jsr user_input
          lda $0335
          sta sector
          sta register0
          ldy #$00
          tya
          sta lo_nib
          sta bytes
          sta ofs
          jsr show_sector
          jmp keyboard      

;track input

user_track:
          lda #$00
          sta c_row
          lda #$1a
          sta c_col
          jsr user_input
          lda $0335
          sta track
          sta register1
          ldy #$00
          tya
          sta lo_nib
          sta bytes
          sta ofs
          jsr show_sector
          jmp keyboard      

hex_table:   
 !scr "0123456789ABCDEF"
hex_bytes:
 !by $00,$a0,$b0,$c0,$d0,$e0,$f0

hex_low_bytes:
 !by $00,$0a,$0b,$0c,$0d,$0e,$0f

screen:!pet "- periscope - Help Track $   Sector $   "      
       !pet "----------------------------------------"        
maxtrack: !by $07

*=$0900
!by $00,$8c   ; chip address
!by $02       ; banks   

startscreen:
!pet"                                        "
!pet"      periscope - build march 2025      "
!pet"                                        "
!pet"----------------------------------------"
!pet"                                        "
!pet"  Chip                                  "
!pet"                                        "
!pet"     atmel 90c010 -  128kb              "
!pet"     atmel 90c020 -  256kb              "
!pet"     atmel 90c040 -  512kb  (sram)      "
!pet"                                        "
!pet"                                        "
!pet"                                        "
!pet"                                        "
!pet"  Address                               "
!pet"                                        "
!pet"     ram0 - $8c00                       "
!pet"     ram1 - $8d00                       "
!pet"                                        "
!pet"                                        "
!pet"                                        "
!pet"----------------------------------------"
!pet"                                        "
!pet"    choose and press space to go on     "
!pet"                                        "

helpscreen:
!pet"                                        "
!pet"           periscope help               "
!pet"                                        "
!pet"----------------------------------------"
!pet"                                        "
!pet"    (h) this screen                     "
!pet"                                        "
!pet"    (8) scroll up   (cursor up)         "
!pet"                                        "
!pet"    (4) scroll down (cursor down)       "
!pet"                                        "
!pet"    (s)ector change                     "
!pet"                                        "
!pet"    (t)rack  change (64 kb block)       "
!pet"                                        "
!pet"    (r)estart                           "
!pet"                                        "
!pet"                                        "
!pet"    (q)uit                              "
!pet"                                        "
!pet"                                        "
!pet"----------------------------------------"
!pet"                                        "
!pet"        press space to go back          "
!pet"                                        "

buffer:


