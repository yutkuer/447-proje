;LABEL			DIRECTIVE	VALUE				COMMENT	
				AREA screen,	CODE,	READONLY,	ALIGN=2
				THUMB				
				
				IMPORT		SCREEN_INIT
				IMPORT		SCR_XY
				IMPORT		SCR_CHAR
					
					
				
				EXPORT		DISPLAY_TEMP
				EXPORT		DISPLAY_RANGE	
				EXPORT		SCRR
;---------------------------------------------------------
; 3.3V			(VCC) connected to 3.3V
; Ground 		(GND) CONNECTED TO GND
; SSI2Fss  		(SCE) connected to PB5
; Reset         	(RST) connected to PB2
; Data/Command  	(D/C) connected to PB3
; SSI0Tx        	(DN)  connected to PB7
; SSI0Clk       	(SCL) connected to PB4
; back light    	(LED) connected to VCC
;----------------------------------------------------------


SCRR	PROC
				PUSH	{LR}

				;THESE WILL BE ON THE SCREEN ALL THE TIME
				MOV		R0,#0X00
				MOV		R1,#0X00
				BL		SCR_XY			;SET CURSOR TO THE BEGINNING
				
				MOV		R5,#0X54		;T
				BL		SCR_CHAR
				MOV		R5,#0X65		;e
				BL		SCR_CHAR
				MOV		R5,#0X6D		;m
				BL		SCR_CHAR
				MOV		R5,#0X70		;p
				BL		SCR_CHAR
				MOV		R5,#0X65		;e
				BL		SCR_CHAR	
				MOV		R5,#0X72		;r
				BL		SCR_CHAR				
				MOV		R5,#0X61		;a
				BL		SCR_CHAR	
				MOV		R5,#0X74		;t
				BL		SCR_CHAR				
				MOV		R5,#0X75		;u
				BL		SCR_CHAR
				MOV		R5,#0X72		;r
				BL		SCR_CHAR				
				MOV		R5,#0X65		;e
				BL		SCR_CHAR			
				MOV		R5,#0X3A		;:
				BL		SCR_CHAR
				MOV		R5,#0X20		;SPACE
				BL		SCR_CHAR
				
				MOV		R0,#0X24 		;
				MOV		R1,#0X1
				BL		SCR_XY			;SET CURSOR TO THE NEARLY END OF THE ROW

				MOV		R5,#0X43		;C
				BL		SCR_CHAR
				MOV		R5,#0X65		;e
				BL		SCR_CHAR
				MOV		R5,#0X6C		;l
				BL		SCR_CHAR
				MOV		R5,#0X63		;c
				BL		SCR_CHAR
				MOV		R5,#0X69		;i
				BL		SCR_CHAR
				MOV		R5,#0X75		;u
				BL		SCR_CHAR
				MOV		R5,#0X73		;s
				BL		SCR_CHAR
				

				MOV		R0,#0X00
				MOV		R1,#0X03
				BL		SCR_XY			;SET CURSOR TO THE START OF ROW1
	

				MOV		R5,#0X52		;R
				BL		SCR_CHAR				
				MOV		R5,#0X61		;a
				BL		SCR_CHAR				
				MOV		R5,#0X6E		;n
				BL		SCR_CHAR
				MOV		R5,#0X67		;g
				BL		SCR_CHAR				
				MOV		R5,#0X65		;e
				BL		SCR_CHAR				
				MOV		R5,#0X3A		;:
				BL		SCR_CHAR
				MOV		R5,#0X20		;SPACE
				BL		SCR_CHAR
				
				MOV		R0,#0X24		; RANGE IS SHORTER MAY NOT NEED 
				MOV		R1,#0X05
				BL		SCR_XY			;SET CURSOR TO THE END OF THE ROW
				
				MOV		R5,#0X43		;C
				BL		SCR_CHAR
				MOV		R5,#0X65		;e
				BL		SCR_CHAR
				MOV		R5,#0X6C		;l
				BL		SCR_CHAR
				MOV		R5,#0X63		;c
				BL		SCR_CHAR
				MOV		R5,#0X69		;i
				BL		SCR_CHAR
				MOV		R5,#0X75		;u
				BL		SCR_CHAR
				MOV		R5,#0X73		;s
				BL		SCR_CHAR			
				
				
				POP		{LR}
				BX		LR
				ENDP
				
;///////////////////////////////////////////////////////////////;				
				
DISPLAY_TEMP		PROC
				PUSH	{LR,R7}
		
					
				;DISPLAY TEMPERATURE
								
				MOV		R7,R0				;DATA FROM C PART
				MOV		R0,#0X00			;TEMP PART POINT
				MOV		R1,#0X01
				BL		SCR_XY				
				MOV		R0,#0X64			;DIVIDE BY 100 THEN MULTIPLY BY 100 TO GET THE FIRST DIGIT
				UDIV	R5, R7, R0
				MUL		R1, R5, R0
				SUB		R7, R1
				ADD		R5, #0X30			;CONVERT TO ASCII (0x30 ?????????????????)hata olursa degisebilir
				BL		SCR_CHAR
				MOV		R0, #0X0A			;DIVIDE BY 10 THEN MULTIPLY BY 10 TO GET THE SECOND DIGIT JUST TO PATTERN MIGHT BE SHORTENED
				UDIV	R5, R7, R0
				MUL		R1, R5, R0
				SUB		R7, R1
				ADD		R5, #0X30			;CONVERT TO ASCII
				BL		SCR_CHAR
				MOV		R5,#0X2E
				BL		SCR_CHAR

				CPY		R5,R7				;THIRD DIGIT
				ADD		R5, #0X30			;CONVERT TO ASCII
				BL		SCR_CHAR
				
				POP		{LR,R7}
				BX		LR
				ENDP
;///////////////////////////////////////////////////////////////;	
DISPLAY_RANGE		PROC
				PUSH	{LR,R7,R8}
		
					
				;DISPLAY TEMPERATURE RANGE
								
				MOV		R7,R0				;DATA FROM C PART LOW RANGE
				MOV		R8,R1				;HIGH RANGE
				MOV		R0,#0X00			;RANGE XY PT 
				MOV		R1,#0X04
				BL		SCR_XY				
				MOV		R0,#0X64			;DIVIDE BY 100 THEN MULTIPLY BY 100 TO GET THE FIRST DIGIT
				UDIV	R5, R7, R0
				MUL		R1, R5, R0
				SUB		R7, R1
				ADD		R5, #0X30			;CONVERT TO ASCII (0x30 ?????????????????)hata olursa degisebilir
				BL		SCR_CHAR
				MOV		R0, #0X0A			;DIVIDE BY 1 THEN MULTIPLY BY 1 TO GET THE SECOND DIGIT JUST TO PATTERN MIGHT BE SHORTENED
				UDIV	R5, R7, R0
				MUL		R1, R5, R0
				SUB		R7, R1
				ADD		R5, #0X30			;CONVERT TO ASCII
				BL		SCR_CHAR
				MOV		R5,#0X2E			; ADD "." PT FOR 1 POINT AFTER DECIMAL
				BL		SCR_CHAR
				CPY		R5,R7				;THIRD DIGIT
				ADD		R5, #0X30			;CONVERT TO ASCII
				BL		SCR_CHAR
				
				MOV		R5,#0X2D			; ADD "-" PT FOR LOW - HIGH DISCRIMINATION
				BL		SCR_CHAR
				
						
				MOV		R0,#0X64			;DIVIDE BY 100 THEN MULTIPLY BY 100 TO GET THE FIRST DIGIT
				UDIV	R5, R8, R0
				MUL		R1, R5, R0
				SUB		R8, R1
				ADD		R5, #0X30			;CONVERT TO ASCII (0x30 ?????????????????)hata olursa degisebilir
				BL		SCR_CHAR
				MOV		R0, #0X0A			;DIVIDE BY 1 THEN MULTIPLY BY 1 TO GET THE SECOND DIGIT JUST TO PATTERN MIGHT BE SHORTENED
				UDIV	R5, R8, R0
				MUL		R1, R5, R0
				SUB		R8, R1
				ADD		R5, #0X30			;CONVERT TO ASCII
				BL		SCR_CHAR
				MOV		R5,#0X2E			; ADD "." PT FOR 1 POINT AFTER DECIMAL
				BL		SCR_CHAR
				CPY		R5,R8				;THIRD DIGIT
				ADD		R5, #0X30			;CONVERT TO ASCII
				BL		SCR_CHAR
				
				POP		{LR,R7,R8}
				BX		LR
				ENDP
			
					
					
					END

