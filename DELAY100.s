			AREA    	DELAY100, READONLY, CODE
			THUMB
			EXPORT	DELAY100
				
__DELAY100	PROC
			PUSH	{R0}
			MOV32	R0,#400000 				; Clock Freq 16 MHz. We created 6 cycle loop (1+1+1+3).
loop		SUBS	R0,#1					; 1 Machine Cycle = 1/16 = 0.0625 us
			NOP								; 6 * 1 Machine Cycle = 0.375
			CMP		R0,#0					; 150ms = 150000,  150000/ 0.375  = 400000. Hence, we set R0 = 400000
			BNE		loop		
			POP		{R0}
			BX 		LR
			
			ENDP
			END