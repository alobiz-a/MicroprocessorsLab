#include <xc.inc>
    
global  KeyPad_setup, KeyPad_main

psect	udata_acs ; what comes after this is data
; reserve data space in access ram ?????
KeyPad_counter: ds    1	    ; reserve 1 byte for variable UART_counter
KEY_PORT EQU PORTE
low_bits: ds	1
high_bits: ds  1; defined space
keyval: ds 1 ; where we store the byte of truth
delay_store: ds 1
delay EQU 0xFF

psect keypad_code,class=CODE ; what comes after this is code
KeyPad_setup:
    movlb 15; go to access bank 15
    bsf REPU; pull-up the byte in access bank 15
    movlb 0; for cleanliness
    clrf LATE; we want LATCHE to be cleared throughout
    clrf TRISD
    return

KeyPad_main:
    movlw 0x0F ; left nibble 0000, right nibble 1111 (input)
    movwf TRISE ; move whatever is in W into TRISE (so 0x0F goes to TRISE)
    call MYsleep
    movff PORTE, low_bits ; move what's in portE (right nibble) to low_bits 
			    ;we're reading pins 0-3 (low pins) with pins 4-7 (high pins)
    movlw 0x0F 
     
    andwf low_bits, f ; to ensure left nibble is still 0000 (as were floating)
    ; Now to reading the right nibble
    movlw 0xF0 ; 0000 (input) 1111 (output)
    movwf TRISE
    call MYsleep
    movf PORTE, W ; move what you read (high bits) into the working register
    iorwf low_bits, W ; do an OR op with what's stored in the 'low_bits' file register and what's in W (high_bits)
		; and store in W
    movwf keyval ; move the answer into keyval 
    movwf PORTD
    ;e.g. 1011 1101 would give the coordinates of the key that has been pressed
    return
    
MYsleep: ; we need to call it, then it will go back to where it was called, delay move from constant into w and then dec that? s
    movlw delay
    movwf delay_store
sleep_loop:
    decfsz delay_store  
    bra sleep_loop
    return
    
Combo_tests: ; iteratively go through each of the 16 combinations until the value in the keyval register matches with the one being tested
    movlw 0xFF ; i.e. if no value has been pressed, stay within this loop until no longer true 
    cpfseq keyval, A ; compare value in keyval with W, store result in A
    bra test_0 ; move on to next test if not equal
    retlw 0x00; clear W
    
test_0: ;0111 0111
    movlw 0x77 ; CHECK
    cpfseq keyval, A 
    bra test_1
    retlw 0x77 ; REPLACE WITH APPROPRIATE ASCII CHARACTER!

test_1: ;0111 1011
    movlw 0x7B ; CHECK
    cpfseq keyval, A 
    bra test_2
    retlw 0x7B;REPLACE WITH APPROPRIATE ASCII CHARACTER!

test_2: ;0111 1101
    movlw 0x7D ; CHECK
    cpfseq keyval, A 
    bra test_3
    retlw 0x7D ; REPLACE WITH APPROPRIATE ASCII CHARACTER!

test_3: ;0111 1110
    movlw 0x7E ; CHECK
    cpfseq keyval, A 
    bra test_4
    retlw 0x7E ; REPLACE WITH APPROPRIATE ASCII CHARACTER!

test_4: ;1011 0111
    movlw 0xB7 ; CHECK
    cpfseq keyval, A 
    bra test_5
    retlw 0xB7 ; REPLACE WITH APPROPRIATE ASCII CHARACTER!
    
test_5: ;0111 1011
    movlw 0xBB ; CHECK
    cpfseq keyval, A 
    bra test_6
    retlw 0xBB ; REPLACE WITH APPROPRIATE ASCII CHARACTER!
    
test_6: ;0111 1101
    movlw 0xBD ; CHECK
    cpfseq keyval, A 
    bra test_7
    retlw 0xBD ; REPLACE WITH APPROPRIATE ASCII CHARACTER!

test_7: ;0111 1110
    movlw 0xBE ; CHECK
    cpfseq keyval, A 
    bra test_8
    retlw 0xBE ; REPLACE WITH APPROPRIATE ASCII CHARACTER!

test_8: ;1101 0111
    movlw 0xD7 ; CHECK
    cpfseq keyval, A 
    bra test_1
    retlw 0xD7 ; REPLACE WITH APPROPRIATE ASCII CHARACTER!
    
Write_LCD:
    