#include "TM4C123GH6PM.h"

// Function prototypes initialize, tranmit and rea functions 
void I2C3_Init ( void );  
char I2C3_Write_Multiple(int slave_address, char slave_memory_address, int bytes_count, int* data);
char I2C3_read_Multiple(int slave_address, char slave_memory_address, int bytes_count, volatile int* data);
long signed int bmp280_compensate_T_int32(long signed int adc_T);

extern void DISPLAY_TEMP(int);
extern void DISPLAY_RANGE(int,int);
extern void DELAY100(void);
extern void SCREEN_INIT(void);
extern void basim_ayar(void);
extern void SCRR(void);

void SysTick_Init(void);
void SysTick_Handler(void);
void port_init(void);

static int dig_T1 = 27504;
static int dig_T2 = 26435;
static int dig_T3 = -1000;


long unsigned int t_fine;

int AVG = 0;

int second;

int main(void)
{
	 int data1[1];
	 volatile int data2[2];
	 int construct, msb,lsb, temp;
   int	no = 0;
	int i;
	 //int AVG = 0;
	int AVD1;
	 int  quadrant = 0;
	 int avg_1, avg_2,avg_3,avg_4,sum;
	 int samples_1 [64];
	 data1[0] = 0x23;
	
	  SCREEN_INIT();
		SCRR();
	  I2C3_Init();
	 	port_init();
	  SysTick_Init();
	 
	  I2C3_Init();
	 	port_init();
	  SysTick_Init();

//	 I2C3_Write_Multiple(0x76,0xF4,1,data1);
//	 I2C3_read_Multiple(0x76,0xD0,1,data2); prototypes for write and read
	
	   I2C3_Write_Multiple(0x76,0xF4,1,data1);
	    data1[0] = 0x00;
	   I2C3_Write_Multiple(0x76,0xF5,1,data1);

	I2C3_read_Multiple(0x76,0xFA,2,data2);
		
	  msb = data2[0];
		lsb  = data2[1] ;
		
		construct = (msb << 8)|lsb;
		construct = construct << 4 ;
		temp = bmp280_compensate_T_int32(construct);
	while(1){
		
		while(no < 64){
		I2C3_read_Multiple(0x76,0xFA,2,data2);
		
	  msb = data2[0];
		lsb  = data2[1] ;
		
		construct = (msb << 8)|lsb;
		construct = construct << 4 ;
		
		// 4 left shift yapilabilir
		
		
	temp = bmp280_compensate_T_int32(construct);
		
		samples_1[no] = temp;
					
		
		no++;
			
		if(no ==64){

    for(i = 0; i <64; i++){
			
		 
    		sum += samples_1[i];	
			
		
		}
		
		if(quadrant == 0){
			
			avg_1= sum/64;
			sum = 0;
			
		}
		
		if(quadrant == 1){
			
			avg_2= sum/64;
			sum = 0;
		}
		
	if(quadrant == 2){
			
			avg_3= sum/64;
			sum = 0;
		}
		
		if(quadrant == 3){
			
			avg_4= sum/64;
			sum = 0;
		}

		quadrant++;
		if(quadrant == 4){
			
			AVG = 0;
			AVG += avg_1; 
			AVG += avg_2; 
			AVG += avg_3; 
			AVG += avg_4; 
			AVG /= 40; 
			
		}
		AVD1= AVG;
		quadrant %= 4;
		no = 0;
			
		}			
		}
		
		
		
		
	}
}
	

	

// I2C intialization and GPIO alternate function configuration
void I2C3_Init ( void )
{
SYSCTL->RCGCGPIO  |= 0x00000008 ; // Enable the clock for port D
SYSCTL->RCGCI2C   |= 0x00000008 ; // Enable the clock for I2C 3
GPIOD->DEN |= 0x03; // Assert DEN for port D
// Configure Port D pins 0 and 1 as I2C 3
GPIOD->AFSEL |= 0x00000003 ;
GPIOD->PCTL |= 0x00000033 ;
GPIOD->ODR |= 0x00000002 ; // SDA (PD1 ) pin as open darin
I2C3->MCR  = 0x0010 ; // Enable I2C 3 master function
/* Configure I2C 3 clock frequency
(1 + TIME_PERIOD ) = SYS_CLK /(2*
( SCL_LP + SCL_HP ) * I2C_CLK_Freq )
TIME_PERIOD = 16 ,000 ,000/(2(6+4) *100000) - 1 = 7 */
I2C3->MTPR  = 0x07 ;
}
/* wait untill I2C Master module is busy */
/*  and if not busy and no error return 0 */
static int I2C_wait_till_done(void)
{
    while(I2C3->MCS & 1);   /* wait until I2C master is not busy */
    return I2C3->MCS & 0xE; /* return I2C error code, 0 if no error*/
}
// Receive one byte of data from I2C slave device
char I2C3_Write_Multiple(int slave_address, char slave_memory_address, int bytes_count, int* data)
{   
    int error;
    if (bytes_count <= 0)
        return -1;                  /* no write was performed */
    /* send slave address and starting address */
    I2C3->MSA = slave_address << 1;
    I2C3->MDR = slave_memory_address;
    I2C3->MCS = 3;                  /* S-(saddr+w)-ACK-maddr-ACK */

    error = I2C_wait_till_done();   /* wait until write is complete */
    if (error) return error;

    /* send data one byte at a time */
    while (bytes_count > 1)
    {
        I2C3->MDR = *data++;             /* write the next byte */
        I2C3->MCS = 1;                   /* -data-ACK- */
        error = I2C_wait_till_done();
        if (error) return error;
        bytes_count--;
    }
    
    /* send last byte and a STOP */
    I2C3->MDR = *data++;                 /* write the last byte */
    I2C3->MCS = 5;                       /* -data-ACK-P */
    error = I2C_wait_till_done();
    while(I2C3->MCS & 0x40);             /* wait until bus is not busy */
    if (error) return error;
    return 0;       /* no error */
}
/* This function reds from slave memory location of slave address */
/* read address should be specified in the second argument */
/* read: S-(saddr+w)-ACK-maddr-ACK-R-(saddr+r)-ACK-data-ACK-data-ACK-...-data-NACK-P */
char I2C3_read_Multiple(int slave_address, char slave_memory_address, int bytes_count, volatile int* data)
{
    int error;
    
    if (bytes_count <= 0)
        return -1;         /* no read was performed */

    /* send slave address and starting address */
    I2C3->MSA = slave_address << 1;
    I2C3->MDR = slave_memory_address;
    I2C3->MCS = 3;       /* S-(saddr+w)-ACK-maddr-ACK */
    error = I2C_wait_till_done();
    if (error)
        return error;

    /* to change bus from write to read, send restart with slave addr */
    I2C3->MSA = (slave_address << 1) + 1;   /* restart: -R-(saddr+r)-ACK */

    if (bytes_count == 1)             /* if last byte, don't ack */
        I2C3->MCS = 7;              /* -data-NACK-P */
    else                            /* else ack */
        I2C3->MCS = 0xB;            /* -data-ACK- */
    error = I2C_wait_till_done();
    if (error) return error;

    *data++ = I2C3->MDR;            /* store the data received */

    if (--bytes_count == 0)           /* if single byte read, done */
    {
        while(I2C3->MCS & 0x40);    /* wait until bus is not busy */
        return 0;       /* no error */
    }
 
    /* read the rest of the bytes */
    while (bytes_count > 1)
    {
        I2C3->MCS = 9;              /* -data-ACK- */
        error = I2C_wait_till_done();
        if (error) return error;
        bytes_count--;
        *data++ = I2C3->MDR;        /* store data received */
    }

    I2C3->MCS = 5;                  /* -data-NACK-P */
    error = I2C_wait_till_done();
    *data = I2C3->MDR;              /* store data received */
    while(I2C3->MCS & 0x40);        /* wait until bus is not busy */
    
    return 0;       /* no error */
}

long signed int bmp280_compensate_T_int32(long signed int adc_T){
	
	
long signed int var1,var2,T;

var1 = ((((adc_T>>3) - ((long signed int)dig_T1<<1))) * ((long signed int)dig_T2)) >>11;
var2 = (((((adc_T>>4) - ((long signed int)dig_T1)) * ((adc_T>>4) - ((long signed int)dig_T1))) >> 12) * ((long signed int)dig_T3)) >> 14;	
	
t_fine = var1 + var2;	
	
T = (t_fine * 5 + 128	) >> 8;

return T;
	
}

void SysTick_Init(void){
	
	SysTick->CTRL &= 0xFFFC ;						/* Disable the SysTick before configuration */
	SysTick->LOAD = 399999; 						/* Delay relaod value */
	SysTick->VAL = 0x00; 								/* initialize current value register */
	SysTick->CTRL = 0x03 ; 							/* enable counter, interrupt and select piosc/4 as clock */
		
}


void SysTick_Handler(){

	volatile unsigned int DigitalRead = 0;
	volatile float Result_f = 0.0;
	volatile float range_low, range_high, temp_last;
	
	
	second++;
		
	ADC0->PSSI			|= 0x08;							// Processor Initiate on SS3
	
	while((ADC0->RIS & (1 << 3)) != 0x08)		// Stuck until Sampling Done
		{}
	
	DigitalRead = ADC0->SSFIFO3;
	
	Result_f = DigitalRead / 1241.21;				// Scale to 0 - 3.3 V
	//Result_f -= 1.65;												// Subtract offset
		
  Result_f *=100 ;			
	range_low =	Result_f - 5;  // lower temerature range
  range_high = Result_f + 5; // higher temperature range

 // temp_last = 22.5;  // for debug			
	
	if(AVG < range_low){
			GPIOF->DATA = 0x02;
	}
	else if (AVG > range_high){
			GPIOF->DATA = 0x04;
	}
	else {
		GPIOF->DATA = 0x08;
	}

	ADC0->ISC 			&= 0x08;							// Clear the sample flag
	
	if(second ==10){
		
		second = 0;
		
		DISPLAY_TEMP(AVG);
		DISPLAY_RANGE(range_low,range_high);
		
		
	}
}



void port_init(void){

	SYSCTL-> RCGCADC |= 0x01;							// Turn on clk for ADC0 
	__ASM("NOP");
	__ASM("NOP");
	__ASM("NOP");
	
	SYSCTL->RCGCGPIO |= 0x30; 						// Turn on bus clock for GPIOE and GPIOF
	__ASM("NOP");
	__ASM("NOP");
	__ASM("NOP");
	
	GPIOE->DIR			&= ~0x08; 						// set PE3 as INPUT
	GPIOE->AFSEL		|= 0x08 ;  						// Alternate function, no PCTL needed
	GPIOE->DEN			&= ~0x08; 						// Disable PE3 digital
	GPIOE->AMSEL		|= 0x08; 							// Enable analog
	
	GPIOF->DIR			|= 0x02; 							// set PF1 as OUTPUT
	GPIOF->AFSEL		&= 0x00 ;  						// No alternate function
	GPIOF->DEN			|= 0x02; 							// Make PF1 digital
	GPIOF->AMSEL		&= ~0x02; 						// Disable analog
	
	GPIOF->DIR			|= 0x04; 							// set PF2 as OUTPUT
	GPIOF->AFSEL		&= 0x00 ;  						// No alternate function
	GPIOF->DEN			|= 0x04; 							// Make PF2 digital
	GPIOF->AMSEL		&= ~0x04; 						// Disable analog
	
	GPIOF->DIR			|= 0x08; 							// set PF3 as OUTPUT
	GPIOF->AFSEL		&= 0x00 ;  						// No alternate function
	GPIOF->DEN			|= 0x08; 							// Make PF3 digital
	GPIOF->AMSEL		&= ~0x08; 						// Disable analog
	
	ADC0->ACTSS			&= 0x00;							// Disable all SS
	ADC0->EMUX			&= ~0xF000;						// Set EMUX3 = 0000
	ADC0->SSMUX3		|= 0x00;							// Choose the input AIN0, OPTIONAL
	ADC0->SSCTL3		|= 0x06;							// TS0,IE0,END0,D0 = 0110
	ADC0->PC				|= 0x01;							// Set sampling 125 ksps
	ADC0->ACTSS			|= 0x08;							// Enable SS3
}


