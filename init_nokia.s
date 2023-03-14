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

;SYS Registers
SYSCTL_RCGCGPIO  		EQU 	0x400FE608
SYSCTL_RCGCSSI			EQU	0x400FE61C	; SSI Gate Control

;GPIO Registers
GPIO_PORTB_DATA			EQU	0x400053FC	; Port B Data
GPIO_PORTB_IM      		EQU 	0x40005410	; Interrupt Mask //5010 ??
GPIO_PORTB_DIR   		EQU 	0x40005400	; Port Direction
GPIO_PORTB_AFSEL 		EQU 	0x40005420	; Alt Function enable
GPIO_PORTB_DEN   		EQU 	0x4000551C	; Digital Enable
GPIO_PORTB_AMSEL 		EQU 	0x40005528	; Analog enable
GPIO_PORTB_PCTL  		EQU 	0x4000552C	; Alternate Functions

;SSI Registers
SSI2_CR0				EQU	0x4000A000 ; CONTROL 0
SSI2_CR1				EQU	0x4000A004 ; CONTROL 1 
SSI2_DR					EQU	0x4000A008 ; DATA
SSI2_SR					EQU	0x4000A00C ; STATUS
SSI2_CPSR				EQU	0x4000A010 ; CLK PRESCALE 
SSI2_CC					EQU	0x4000AFC8 ; CLK CONFIG	
	
;LABEL			DIRECTIVE	VALUE				COMMENT	
				AREA screen,	CODE,	READONLY,	ALIGN=2
				THUMB
					
				IMPORT		DELAY100
				IMPORT		SCR_XY
				IMPORT		SCR_CHAR
				IMPORT		SCR_BYTE
				EXPORT		init_nokia
										
				
init_nokia			PROC
		PUSH	{LR}
				;Setup GPIO
		LDR 	R1, =SYSCTL_RCGCGPIO	; start GPIO clock
		LDR 	R0, [R1]                   
		ORR 	R0, #0x02				; set bit 1 // B port enabled	
		STR 	R0, [R1]                   
		NOP								
		NOP
		NOP						; allow clock to settle						
		LDR		R1,=GPIO_PORTB_DIR		; make PB 2,3,4,5,7 output
		MOV 		R0, #0xBC			; and make PB6 input
		STR		R0,[R1]
		LDR		R1,=GPIO_PORTB_AFSEL		; enable alt funct on PB4,5,7 
		MOV 		R0, #0xB0			;
		STR		R0,[R1]
		LDR		R1,=GPIO_PORTB_DEN		; enable digital I/O at PB2,3,4,5,7
		MOV 		R0, #0xFC			;
		STR		R0,[R1]					
		LDR		R1,=GPIO_PORTB_PCTL 		; configure PB 4,5,6,7 as SSI
		LDR 		R0, =0x22220000			; set 4,5,6 and 7 as half byte (nibble)		
		STR		R0,[R1]
		LDR		R1,=GPIO_PORTB_AMSEL		; disable analog functionality
		LDR		R0, [R1]
		BIC 		R0, #0xFC			;
		STR		R0,[R1]



					
					;Setup SSI	
		LDR 	R1,=SYSCTL_RCGCSSI			; start SSI clock
		LDR 	R0,[R1]                   
		ORR 	R0, #0x04				; set bit 2 for SSI2
		STR 	R0,[R1]                			; small delay
		BL		DELAY100
		NOP
		NOP
		MOV		R0,#0x0F
waitSSIClk								; allow clock to settle
		SUBS	R0,R0,#0x01
		BNE		waitSSIClk
		LDR		R1,=SSI2_CR1				; disable SSI during setup 
		MOV		R0, #0x00				; clear all bits
		STR		R0,[R1]					;
		
		; Configure baud rate PIOSC=16MHz , Baud Rate=1MHz (supported value), CPSDVSR=8 , SCR=1 // see further on 9.3.7 in LN
		; BR=SysClk/(CPSDVSR * (1 + SCR))
		LDR		R1,=SSI2_CC				; use PIOSC (16MHz)		
		MOV		R0,#0x5					; set bits 3:0 of the SSICC to 0x5 (PIOSC)
		STR		R0,[R1]
		LDR		R1,=SSI2_CR0				; set SCR bits to 0x01
		LDR		R0,[R1]
		ORR		R0, #0x0100				;OR CAN BE USED !!!
		STR		R0,[R1]
		LDR		R1,=SSI2_CPSR				; set CPSDVSR to 0x08
		MOV 		R0, #0x08				;
		STR		R0,[R1]
		LDR		R1,=SSI2_CR0				; clear SPH,SPO
		LDR		R0,[R1]					; choose Freescale frame format
		BIC		R0, #0x3F				; clear bits 5:4, free format is used	
		ORR		R0, #0x07				; 8 bit data will be used =>0x7
		STR		R0,[R1]
		LDR		R1,=SSI2_CR1				; enable SSI
		LDR		R0,[R1]
		ORR 		R0, #0x02				; SSI oprt enabled by setting bit 1
		STR		R0,[R1]
				
						; RESET LCD	
		LDR		R1,=GPIO_PORTB_DATA	
		LDR		R0, [R1]
		BIC 	R0, #0x04				; clear reset(PB2) 	
		STR		R0,[R1]
		BL		DELAY100				; LOW FOR 100MSEC
		LDR		R1,=GPIO_PORTB_DATA		; 
		ORR 	R0, #0x04			; set reset(PB2)
		STR		R0,[R1]				;
		LDR		R1,=GPIO_PORTB_DATA		; set PB3 low for Command (D/C)
		LDR		R0,[R1]				;
		BIC 		R0, #0x08			;
		STR		R0,[R1]				;


					MOV		R5,#0x21				; H=1, V=0
					BL		SCR_BYTE	
					MOV		R5,#0xB0				; Set contrast
					BL		SCR_BYTE
					MOV		R5,#0x04				; Temp coeff
					BL		SCR_BYTE
					MOV		R5,#0x20				; set bias 
					BL		SCR_BYTE
					MOV		R5,#0x20				; H=0
					BL		SCR_BYTE
					MOV		R5,#0x0C				; set control mode to normal
					BL		SCR_BYTE

					; CLEAR SCREEN
CLR_BSY					LDR		R1,=SSI2_SR				; CHECK BUSY (4TH BIT)
					LDR		R0,[R1]
					ANDS		R0,R0,#0x10
					BNE		CLR_BSY
					LDR		R1,=GPIO_PORTB_DATA		
					LDR		R0,[R1]
					ORR		R0,#0x08				; DATA MODE
					STR		R0,[R1]	
					MOV		R0,#504					; 6*84					
					MOV		R5,#0x00
					
CLR_ALL					BL		SCR_BYTE
					SUBS		R0,#1
					BNE		CLR_ALL
					
WAITCLR					LDR		R1,=SSI2_SR				
					LDR		R0,[R1]
					ANDS		R0,R0,#0x10				;CHECK BUSY
					BNE		WAITCLR
					
					POP		{LR}
					BX		LR
					ALIGN
					ENDP
					END