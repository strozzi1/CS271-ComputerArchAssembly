TITLE Elementary Arithmetic     (Assignment1.asm)

; Author: Joshua
; Course / Project ID : Assignment 1                 Date: Jan 21, 2018
; Description: Will introduce the programmer, two numbers from user and display the sum, 
; difference, product, quotient, and remainder, and store each in variables.

INCLUDE Irvine32.inc

; (insert constant definitions here)

.data
; (insert variable definitions here)
intro_1		BYTE	"Elementary Arithmetic     by Joshua M. Strozzi", 0;
extra_cred	BYTE	"**EC: Repeats until user decides to quit, handles signs for positive and negative numbers when displaying difference", 0
intro_2		BYTE	"Enter 2 numbers, and I'll show you the sum, difference, product, quotient, and remainder. ", 0;
go_again	BYTE	"Would you like to go again? Enter the number 1: ", 0
outro		BYTE	"Impressed? Bye! ", 0

prompt_1	BYTE	"What's your first number: ", 0
prompt_2	BYTE	"What's your second number: ", 0
number_1	DWORD	?			;destination of our 1st number
number_2	DWORD	?			;and second number

sum			DWORD	?			;where out sum goes
difference	DWORD	?			;difference goes
product		DWORD	?			;product
quotient	DWORD	?			;quotient
remainder	DWORD	?			;remainder

plus		BYTE	" + ", 0	;for printing results
minus		BYTE	" - ", 0
multi		BYTE	" X ", 0
divide		BYTE	" / ", 0
equals		BYTE	" = ", 0
Word_remain	BYTE	" remainder ", 0	


.code
main PROC
; (insert executable instructions here)
	;Introduce programmer and program

	mov		edx,OFFSET intro_1		;printing
	call	WriteString				;first intro
	call	crlf					;new line

	mov		edx, OFFSET extra_cred
	call	writestring				;printing extra credit header
	call	crlf

	call	crlf
	mov		edx, OFFSET intro_2		;
	call	WriteString				;printing second part of intro
	call	crlf

again:								;label jumped to if user wants to go again
	;ask for numbers
	mov		edx, OFFSET prompt_1	;prompt for first number
	call	writestring
	call	ReadInt					;read in first number
	mov		number_1, eax			;put first number into it's memory location
	call	crlf

	mov		edx, Offset prompt_2	;same for second number
	call	writestring
	call	ReadInt
	mov		number_2, eax
	call	crlf


	;do the math	
	mov		eax, number_1			
	mov		ebx, number_2
	add		eax, ebx				;sum of 2 numbers
	mov		sum, eax

	mov		eax, number_1
	mov		ebx, number_2
	sub		eax, ebx				;difference
	mov		difference, eax

	mov		eax, number_1
	mul		ebx						;product
	mov		product, eax

	xor		edx, edx				;making sure edx is 0
	mov		eax, number_1			
	div		ebx						;difference
	mov		quotient, eax
	mov		remainder, edx			;remainder too

	;display results
	
	;sum
	mov		eax, number_1			;
	call	writeDec				;
	mov		edx, OFFSET plus		;
	call	writeString				;prints arithmetic used
	mov		eax, number_2			;
	call	writeDec				;
	mov		edx, OFFSET equals		
	call	writeString				;print equal sign
	mov		eax, sum				
	call	writeDec				;and the end result
	call	crlf

	;difference
	mov		eax, number_1
	call	writeDec
	mov		edx, OFFSET minus
	call	writeString
	mov		eax, number_2
	call	writeDec
	mov		edx, OFFSET equals
	call	writeString
	
	mov		eax, number_1
	mov		ebx, number_2
	cmp		eax, ebx			;comparing the numbers to see if the first < second
	jl		negative			;if so I jump to a different print statment
	mov		eax, difference		;That way if it's positive it doens't print the sign
	call	writeDec
	call	crlf
	jmp		endMinus			;and jumps to the end of the printing block for minus

negative:						;and if it is negative
	mov		eax, difference		
	call	writeInt			;it prints the negative sign
	call	crlf
endMinus:
	


	;product
	mov		eax, number_1
	call	writeDec
	mov		edx, OFFSET multi
	call	writeString
	mov		eax, number_2
	call	writeDec
	mov		edx, OFFSET equals
	call	writeString
	mov		eax, product
	call	writeDec
	call	crlf

	;quotient and remainder
	mov		eax, number_1
	call	writeDec
	mov		edx, OFFSET divide
	call	writeString
	mov		eax, number_2
	call	writeDec
	mov		edx, OFFSET equals
	call	writeString
	mov		eax, quotient
	call	writeDec
	mov		edx, offset WORD_remain
	call	writeString
	mov		eax, remainder
	call	writeDec
	call	crlf

	;ask if they'd like to go again
	call	crlf
	mov		edx, offset go_again
	call	WriteString
	call	readInt						;read in user number input into eax
	cmp		eax, 1						;cmp eax to 1
	jz		again						;if user entered number isn't 1, end program


	;Say goodbye
	mov		edx, offset outro
	call	writeString
	call	crlf


	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
