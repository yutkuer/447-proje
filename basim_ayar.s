; Pin connections
; ------------------------------------------
; 3.3V			(VCC) connected to 3.3V
; Ground 		(GND) CONNECTED TO GND
; SSI2Fss  		(SCE) connected to PA3
; Reset         	(RST) connected to PB2
; Data/Command  	(D/C) connected to PB3
; SSI0Tx        	(DN)  connected to PA5
; SSI0Clk       	(SCL) connected to PA2
; back light    	(LED) connected to VCC
;----------------------------------------------
GPIO_PORTB_DATA			EQU	0x400043FC	; Port B Data
SSI2_DR					EQU	0x40008008 ; DATA
SSI2_SR					EQU	0x4000800C ; STATUS

;LABEL			DIRECTIVE	VALUE				COMMENT	
				AREA screen,	CODE,	READONLY,	ALIGN=2
				THUMB
					
				EXPORT		SCR_XY
				EXPORT		SCR_CHAR
				EXPORT		SCR_BYTE




; ASCII table for characters to be displayed
ASCII	DCB		0x00, 0x00, 0x00, 0x00, 0x00 ;// 20
		DCB		0x00, 0x00, 0x5f, 0x00, 0x00 ;// 21 !
		DCB		0x00, 0x07, 0x00, 0x07, 0x00 ;// 22 "
		DCB		0x14, 0x7f, 0x14, 0x7f, 0x14 ;// 23 #
		DCB		0x24, 0x2a, 0x7f, 0x2a, 0x12 ;// 24 $
		DCB		0x23, 0x13, 0x08, 0x64, 0x62 ;// 25 %
		DCB		0x36, 0x49, 0x55, 0x22, 0x50 ;// 26 &
		DCB		0x00, 0x05, 0x03, 0x00, 0x00 ;// 27 '
		DCB		0x00, 0x1c, 0x22, 0x41, 0x00 ;// 28 (
		DCB		0x00, 0x41, 0x22, 0x1c, 0x00 ;// 29 )
		DCB		0x14, 0x08, 0x3e, 0x08, 0x14 ;// 2a *
		DCB		0x08, 0x08, 0x3e, 0x08, 0x08 ;// 2b +
		DCB		0x00, 0x50, 0x30, 0x00, 0x00 ;// 2c ,
		DCB		0x08, 0x08, 0x08, 0x08, 0x08 ;// 2d -
		DCB		0x00, 0x60, 0x60, 0x00, 0x00 ;// 2e .
		DCB		0x20, 0x10, 0x08, 0x04, 0x02 ;// 2f /
		DCB		0x3e, 0x51, 0x49, 0x45, 0x3e ;// 30 0
		DCB		0x00, 0x42, 0x7f, 0x40, 0x00 ;// 31 1
		DCB		0x42, 0x61, 0x51, 0x49, 0x46 ;// 32 2
		DCB		0x21, 0x41, 0x45, 0x4b, 0x31 ;// 33 3
		DCB		0x18, 0x14, 0x12, 0x7f, 0x10 ;// 34 4
		DCB		0x27, 0x45, 0x45, 0x45, 0x39 ;// 35 5
		DCB		0x3c, 0x4a, 0x49, 0x49, 0x30 ;// 36 6
		DCB		0x01, 0x71, 0x09, 0x05, 0x03 ;// 37 7
		DCB		0x36, 0x49, 0x49, 0x49, 0x36 ;// 38 8
		DCB		0x06, 0x49, 0x49, 0x29, 0x1e ;// 39 9
		DCB		0x00, 0x36, 0x36, 0x00, 0x00 ;// 3a :
		DCB		0x00, 0x56, 0x36, 0x00, 0x00 ;// 3b ;
		DCB		0x08, 0x14, 0x22, 0x41, 0x00 ;// 3c <
		DCB		0x14, 0x14, 0x14, 0x14, 0x14 ;// 3d =
		DCB		0x00, 0x41, 0x22, 0x14, 0x08 ;// 3e >
		DCB		0x02, 0x01, 0x51, 0x09, 0x06 ;// 3f ?
		DCB		0x32, 0x49, 0x79, 0x41, 0x3e ;// 40 @
		DCB		0x7e, 0x11, 0x11, 0x11, 0x7e ;// 41 A
		DCB		0x7f, 0x49, 0x49, 0x49, 0x36 ;// 42 B
		DCB		0x3e, 0x41, 0x41, 0x41, 0x22 ;// 43 C
		DCB		0x7f, 0x41, 0x41, 0x22, 0x1c ;// 44 D
		DCB		0x7f, 0x49, 0x49, 0x49, 0x41 ;// 45 E
		DCB		0x7f, 0x09, 0x09, 0x09, 0x01 ;// 46 F
		DCB		0x3e, 0x41, 0x49, 0x49, 0x7a ;// 47 G
		DCB		0x7f, 0x08, 0x08, 0x08, 0x7f ;// 48 H
		DCB		0x00, 0x41, 0x7f, 0x41, 0x00 ;// 49 I
		DCB		0x20, 0x40, 0x41, 0x3f, 0x01 ;// 4a J
		DCB		0x7f, 0x08, 0x14, 0x22, 0x41 ;// 4b K
		DCB		0x7f, 0x40, 0x40, 0x40, 0x40 ;// 4c L
		DCB		0x7f, 0x02, 0x0c, 0x02, 0x7f ;// 4d M
		DCB		0x7f, 0x04, 0x08, 0x10, 0x7f ;// 4e N
		DCB		0x3e, 0x41, 0x41, 0x41, 0x3e ;// 4f O
		DCB		0x7f, 0x09, 0x09, 0x09, 0x06 ;// 50 P
		DCB		0x3e, 0x41, 0x51, 0x21, 0x5e ;// 51 Q
		DCB		0x7f, 0x09, 0x19, 0x29, 0x46 ;// 52 R
		DCB		0x46, 0x49, 0x49, 0x49, 0x31 ;// 53 S
		DCB		0x01, 0x01, 0x7f, 0x01, 0x01 ;// 54 T
		DCB		0x3f, 0x40, 0x40, 0x40, 0x3f ;// 55 U
		DCB		0x1f, 0x20, 0x40, 0x20, 0x1f ;// 56 V
		DCB		0x3f, 0x40, 0x38, 0x40, 0x3f ;// 57 W
		DCB		0x63, 0x14, 0x08, 0x14, 0x63 ;// 58 X
		DCB		0x07, 0x08, 0x70, 0x08, 0x07 ;// 59 Y
		DCB		0x61, 0x51, 0x49, 0x45, 0x43 ;// 5a Z
		DCB		0x00, 0x7f, 0x41, 0x41, 0x00 ;// 5b [
		DCB		0x02, 0x04, 0x08, 0x10, 0x20 ;// 5c '\'
		DCB		0x00, 0x41, 0x41, 0x7f, 0x00 ;// 5d ]
		DCB		0x04, 0x02, 0x01, 0x02, 0x04 ;// 5e ^
		DCB		0x40, 0x40, 0x40, 0x40, 0x40 ;// 5f _
		DCB		0x00, 0x01, 0x02, 0x04, 0x00 ;// 60 `
		DCB		0x20, 0x54, 0x54, 0x54, 0x78 ;// 61 a
		DCB		0x7f, 0x48, 0x44, 0x44, 0x38 ;// 62 b
		DCB		0x38, 0x44, 0x44, 0x44, 0x20 ;// 63 c
		DCB		0x38, 0x44, 0x44, 0x48, 0x7f ;// 64 d
		DCB		0x38, 0x54, 0x54, 0x54, 0x18 ;// 65 e
		DCB		0x08, 0x7e, 0x09, 0x01, 0x02 ;// 66 f
		DCB		0x0c, 0x52, 0x52, 0x52, 0x3e ;// 67 g
		DCB		0x7f, 0x08, 0x04, 0x04, 0x78 ;// 68 h
		DCB		0x00, 0x44, 0x7d, 0x40, 0x00 ;// 69 i
		DCB		0x20, 0x40, 0x44, 0x3d, 0x00 ;// 6a j
		DCB		0x7f, 0x10, 0x28, 0x44, 0x00 ;// 6b k
		DCB		0x00, 0x41, 0x7f, 0x40, 0x00 ;// 6c l
		DCB		0x7c, 0x04, 0x18, 0x04, 0x78 ;// 6d m
		DCB		0x7c, 0x08, 0x04, 0x04, 0x78 ;// 6e n
		DCB		0x38, 0x44, 0x44, 0x44, 0x38 ;// 6f o
		DCB		0x7c, 0x14, 0x14, 0x14, 0x08 ;// 70 p
		DCB		0x08, 0x14, 0x14, 0x18, 0x7c ;// 71 q
		DCB		0x7c, 0x08, 0x04, 0x04, 0x08 ;// 72 r
  		DCB		0x48, 0x54, 0x54, 0x54, 0x20 ;// 73 s
  		DCB		0x04, 0x3f, 0x44, 0x40, 0x20 ;// 74 t
		DCB		0x3c, 0x40, 0x40, 0x20, 0x7c ;// 75 u
		DCB		0x1c, 0x20, 0x40, 0x20, 0x1c ;// 76 v
		DCB		0x3c, 0x40, 0x30, 0x40, 0x3c ;// 77 w
		DCB		0x44, 0x28, 0x10, 0x28, 0x44 ;// 78 x
		DCB		0x0c, 0x50, 0x50, 0x50, 0x3c ;// 79 y
		DCB		0x44, 0x64, 0x54, 0x4c, 0x44 ;// 7a z
  		DCB		0x00, 0x08, 0x36, 0x41, 0x00 ;// 7b {
  		DCB		0x00, 0x00, 0x7f, 0x00, 0x00 ;// 7c |
  		DCB		0x00, 0x41, 0x36, 0x08, 0x00 ;// 7d }
  		DCB		0x10, 0x08, 0x08, 0x10, 0x08 ;// 7e ~

		SPACE	1		; added for padding

SCR_BYTE			PUSH	{R0,R1}
BYTELOOP			LDR			R1,=SSI2_SR				; FIFO NOT FULL YET
					LDR		R0,[R1]
					ANDS		R0,R0,#0x02
					BEQ		BYTELOOP
					LDR		R1,=SSI2_DR
					STRB		R5,[R1]
					POP		{R0,R1}
					BX		LR	


					; DISPLAY ASCII CHARACTER ON R5
SCR_CHAR			PUSH	{R0-R4,LR}
					LDR		R1,=GPIO_PORTB_DATA		; DATA MODE
					LDR		R0,[R1]
					ORR		R0,#0x40				; PB 3
					STR		R0,[R1]
					LDR		R1,=ASCII
					SUB		R2,R5,#0x20				; SUBSTITUDE THE ASCI OFFSET
					MOV		R3,#0x05
					MUL		R2,R2,R3				; EACH CHAR IS 5 BYTE 
					ADD		R1,R1,R2
					MOV		R0,#0x05				
					
DISP_CHAR				LDRB	R5,[R1],#1				
					BL		SCR_BYTE				
					SUBS		R0,R0,#1
					BNE		DISP_CHAR
					
					MOV		R5,#0X00				; SPACE AFTER
					BL		SCR_BYTE				
					
CHAREND				LDR			R1,=SSI2_SR			
					LDR		R0,[R1]
					ANDS		R0,R0,#0x10				; CHECK BUSY
					BNE		CHAREND
					
					POP		{R0-R4,LR}
					BX		LR
					
					; SET THE CURSOR, X ON R0, Y ON R1
SCR_XY				PUSH	{R0-R5,LR}

					PUSH	{R0-R1}
					LDR		R1,=GPIO_PORTB_DATA		; COMMAND MODE
					LDR		R0,[R1]
					BIC		R0,#0x40
					STR		R0,[R1]
					MOV		R5,#0x20				; H=0
					BL		SCR_BYTE	
					POP		{R0-R1}
					MOV		R5,R0					; R0 HOLDS X
					ORR		R5,#0x80
					BL		SCR_BYTE
					MOV		R5,R1					; R1 HOLDS Y
					ORR		R5,#0x40
					BL		SCR_BYTE
					
XYEND				LDR			R1,=SSI2_SR				; wait until SSI is done
					LDR		R0,[R1]
					ANDS		R0,R0,#0x10
					BNE		XYEND
					
					LDR		R1,=GPIO_PORTB_DATA		; BACK TO DATA MODE
					LDR		R0,[R1]
					ORR		R0,#0x40
					STR		R0,[R1]
					POP		{R0-R5,LR}
					BX		LR
	
					ALIGN
					END






