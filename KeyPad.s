#include <xc.inc>
    
;global  KeyPad_Setup, KeyPad_Transmit_Message

psect	udata_acs ; what comes after this is data
; reserve data space in access ram ?????
KeyPad_counter: ds    1	    ; reserve 1 byte for variable UART_counter
KEY_PORT EQU PORTE
low_bits: ds	1
high_bits: ds  1; defined space
keyval: ds 1

psect keypad_code,class=CODE ; what comes after this is code
KeyPad_setup:
    movlb 15; go to access bank 15
    bsf REPU; pull-up the byte in access bank 15
    movlb 0; for cleanliness
    clrf LATE; we want LATCHE to be cleared throughout

KeyPad_main:
    movlw 0x0F ; left nibble 0000, right nibble 1111 (input)
    movwf TRISE ; move whatever is in W into TRISE (so 0x0F goes to TRISE)
    movff PORTE, low_bits ; move what's in portE (right nibble) to low_bits 
			    ;we're reading pins 0-3 (low pins) with pins 4-7 (high pins)
    ; movlw 0x0F 
    andwf low_bits ; to ensure left nibble is still 0000 (as were floating)
    ; Now to reading the right nibble
    movlw 0xF0 ; 0000 (input) 1111 (output)
    movwf TRISE 
    movf PORTE, W ; move what you read (high bits) into the working register
    iorwf low_bits, W ; do an OR op with what's stored in the 'low_bits' file register and what's in W (high_bits)
		; and store in W
    movwf keyval ; move the answer into keyval 
    ;e.g. 1111 1101 would mean that whatever key is at bit 1 (0-value) has been pressed
    
    
    
    
;Keypad subroutine 
/*
Chk_Keys:   	
		movlw   0x00         	;wait until no key pressed 
      		movwf   KEY_PORT      	;set all output pins low 
      		movf   	KEY_PORT,   W 
      		andlw   0x0F         	;mask off high byte 
      		sublw   0x0F 
      		btfsc   STATUS, Z      	;test if any key pressed 
      		goto   	Keys         	;if none, read keys 
      		call   	Delay20 
      		goto   	Chk_Keys      	;else try again 

Keys:        	
		call    Scan_Keys 
            	movlw   0x10         	;check for no key pressed 
            	subwf   key, w 
            	btfss   STATUS, Z 
            	goto    Key_Found 
      		call   	Delay20 
      		goto   	Keys 
		
Key_Found:   	
		movf    key, w 
      		andlw   0x0f 
      		call   	Key_Table      	;lookup key in table    
      		movwf   key         	;save back in key 
      		return            	;key pressed now in W 

Scan_Keys:   	
		clrf    key 
      		movlw   0xF0         	;set all output lines high 
            	movwf   KEY_PORT 
            	movlw   0x04 
            	movwf   rows         	;set number of rows 
            	bcf     STATUS, C      	;put a 0 into carry 
Scan        	rrf     KEY_PORT, f 
            	bsf     STATUS, C      	;follow the zero with ones 
;comment out next two lines for 4x3 numeric keypad. 
            	btfss   KEY_PORT, Col4 
            	goto    Press 
            	incf    key, f 
            	btfss   KEY_PORT, Col3 
            	goto    Press 
            	incf    key, f 
            	btfss   KEY_PORT, Col2 
            	goto    Press 
            	incf    key, f 
            	btfss   KEY_PORT, Col1 
            	goto    Press 
            	incf    key, f 
            	decfsz  rows, f 
            	goto    Scan 
Press       	return */