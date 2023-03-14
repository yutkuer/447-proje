SYSCTL_RCGCGPIO  		EQU 0x400FE608
GPIO_PORTA_DATA			EQU	0x400043FC
GPIO_PORTA_IM      		EQU 0x40004010
GPIO_PORTA_DIR   		EQU 0x40004400
GPIO_PORTA_AFSEL 		EQU 0x40004420
GPIO_PORTA_DEN   		EQU 0x4000451C
GPIO_PORTA_AMSEL 		EQU 0x40004528
GPIO_PORTA_PCTL  		EQU 0x4000452C
	
SYSCTL_RCGCSSI			EQU	0x400FE61C
SSI0_CR0				EQU	0x40008000
SSI0_CR1				EQU	0x40008004
SSI0_DR					EQU	0x40008008
SSI0_SR					EQU	0x4000800C
SSI0_CPSR				EQU	0x40008010
SSI0_CC					EQU	0x40008FC8
	
	
;LABEL			DIRECTIVE	VALUE				COMMENT	
				AREA screen,	CODE,	READONLY,	ALIGN=2
				THUMB
					
				IMPORT		DELAY100
				IMPORT		SCR_XY
				IMPORT		SCR_CHAR
				IMPORT		SCR_BYTE
				EXPORT		SCREEN_INIT
										
				
SCREEN_INIT			PROC
					PUSH	{LR}
					; SETUP GPIO
					LDR 	R1, =SYSCTL_RCGCGPIO
					LDR 	R0, [R1]             
					ORR 	R0, #0x01				;PORTA
					STR 	R0, [R1]                   
					NOP							
					NOP
					NOP								
					LDR		R1,=GPIO_PORTA_DIR
					LDR		R0, [R1]
					ORR 	R0, #0xEC				; OUTPUT 2,3,5,6,7
					STR		R0,[R1]
					LDR		R1,=GPIO_PORTA_AFSEL
					LDR		R0, [R1]
					ORR	 	R0, #0x2C				; ALTERNATE PA2,3,5
					STR		R0,[R1]
					LDR		R1,=GPIO_PORTA_DEN	
					LDR		R0, [R1]
					ORR		R0, #0XEC
					STR		R0,[R1]					
					LDR		R1,=GPIO_PORTA_PCTL
					LDR 	R0, =0x00202200			; PA2,3,5 SSI		
					STR		R0,[R1]
					LDR		R1,=GPIO_PORTA_AMSEL
					LDR		R0, [R1]
					BIC 	R0, #0xEC
					STR		R0,[R1]
					
					; Setup SSI	
					LDR 	R1,=SYSCTL_RCGCSSI
					LDR 	R0,[R1]                   
					ORR 	R0, #0x01				; SSI0
					STR 	R0,[R1]                
					BL		DELAY100
					NOP
					NOP
					LDR		R1,=SSI0_CR1
					MOV		R0, #0x00				; DISABLE SSI
					STR		R0,[R1]
					
					; 1MHZ BAUD, SYSCLOCK, CPSDVSR = 8, SCR = 1
					LDR		R1,=SSI0_CC
					MOV		R0,#0x05				; PIOSC
					STR		R0,[R1]
					LDR		R1,=SSI0_CR0		
					LDR		R0,[R1]
					ORR		R0, #0x0100				; SCR 1
					STR		R0,[R1]
					LDR		R1,=SSI0_CPSR		
					MOV 	R0, #0x08				; CPSDVSR 8
					STR		R0,[R1]
					LDR		R1,=SSI0_CR0		
					LDR		R0,[R1]					
					BIC		R0, #0x3F				; FREESCALE 	
					ORR		R0, #0x07				; 8BIT
					STR		R0,[R1]
					LDR		R1,=SSI0_CR1			; ENABLE SSI
					LDR		R0,[R1]
					ORR 	R0, #0x02
					STR		R0,[R1]
				
					; RESET LCD	
					LDR		R1,=GPIO_PORTA_DATA	
					LDR		R0, [R1]
					BIC 	R0, #0x80				; LOW RESET
					STR		R0,[R1]	
					BL		DELAY100				; LOW FOR 100MSEC
					LDR		R1,=GPIO_PORTA_DATA
					ORR 	R0, #0x80				; HIGH RESET
					STR		R0,[R1]	
					; SETUP LCD
					LDR		R1,=GPIO_PORTA_DATA		; COMMAND MODE
					LDR		R0,[R1]
					BIC 	R0, #0x40			
					STR		R0,[R1]


					MOV		R5,#0x21				; H=1, V=0
					BL		SCR_BYTE	
					MOV		R5,#0xB8				; VOP
					BL		SCR_BYTE
					MOV		R5,#0x04				; TEMP COEF
					BL		SCR_BYTE
					MOV		R5,#0x20				; BIAS (0X13 IS BAD)
					BL		SCR_BYTE
					MOV		R5,#0x20				; H=0
					BL		SCR_BYTE
					MOV		R5,#0x0C				; NORMAL DISPLAY MODE
					BL		SCR_BYTE

					; CLEAR SCREEN
CLRBSY				LDR		R1,=SSI0_SR				; CHECK BUSY
					LDR		R0,[R1]
					ANDS	R0,R0,#0x10
					BNE		CLRBSY
					LDR		R1,=GPIO_PORTA_DATA		
					LDR		R0,[R1]
					ORR		R0,#0x40				; DATA MODE
					STR		R0,[R1]	
					MOV		R0,#504					; 48*84/8					
					MOV		R5,#0x00
					
CLRLOOP				BL		SCR_BYTE
					SUBS	R0,#1
					BNE		CLRLOOP
					
CLREND				LDR		R1,=SSI0_SR				
					LDR		R0,[R1]
					ANDS	R0,R0,#0x10				;CHECK BUSY
					BNE		CLREND
					
					POP		{LR}
					BX		LR
					ALIGN
					END