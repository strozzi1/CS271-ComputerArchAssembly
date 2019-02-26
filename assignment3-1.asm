TITLE Integer Accumulator     (assignment3.asm)

; Author: Joshua Michael Strozzi
; Course / Project ID                 Date: 9 Feb. 2018
; Description: Accumulate all negative integers entered by user til a zero is enter, at which point display sum

INCLUDE Irvine32.inc

; (insert constant definitions here)

Lower_Lim= -100;
Upper_Lim= -1;

.data

Intro1		BYTE		"Welcome to the Integer Accumulator by Joshua Strozzi! ", 13, 10, "What's your Name? ",0
UserName	BYTE		33 DUP(0)
Greeting	BYTE		"Hello, ",0
Goodbye		BYTE		"Thank you for playing Integer Accumulator! It's been a pleasure to meet you, ",0
extracred	BYTE		"**EC: Number the Lines during user input",13,10,0

instruct	BYTE		"Please enter integers in [-100, -1].",13,10,"Enter a non-negative number when you are finished to see results. ",13,10,0
Prompt		BYTE		". Enter Number: ",0

SUM			DWORD		?
VALID		DWORD		?
LINENUM		DWORD		1


validnums1	BYTE		"You entered ",0
validnums2	BYTE		" valid numbers.",13, 10, 0
sumnums		BYTE		"The sum of your valid numbers is ",0
rounded		BYTE		"The rounded average is ", 0


.code
main PROC

; INTRODUCTION & INSTRUCTION
	mov		edx, offset extracred
	call	writestring
	mov		edx, offset Intro1
	call	writestring

	mov		edx, offset UserName			;prep UserName to receive input
	mov		ecx, 32							;set max number count
	call	readString						;take in name
	mov		edx, offset	Greeting			;say hello to user
	call	writeString
	mov		edx, offset UserName
	call	writestring
	call	crlf
	call	crlf
			
	mov		edx, offset instruct			;explain rules of program to user
	call	writeString

 ; GET INTEGERS

PromptBlock: 
	mov		eax, LINENUM					;display line number
	call	writeDec
	mov		edx, offset Prompt				;prompt user for number
	call	writeString
	inc		eax								;increment line number
	mov		LINENUM, eax					;update linenum
	call	readInt							;read in signed integers

	cmp		eax, Lower_Lim					;compare to -100
	jl		PromptBlock						;if less than -100, retry
	cmp		eax, Upper_Lim					;compare to -1
	jg		endBlock						;if greater than -1, jump to end
	add		eax, SUM						;add number to sum if within boundary
	mov		SUM, eax						
	xor		eax, eax
	mov		eax, VALID						;increment total number of valid inputs
	add		eax, 1							
	mov		VALID, EAX
	jmp		PromptBlock						;jump back to top of prompt block

endBlock:


;DISPLAY RESULTS AND SAY GOODBYE
	mov		edx, offset validnums1			;tell user
	call	writeString						;how many
	mov		eax, VALID						;numbers were valid
	call	writeDec						;that he/she input
	mov		edx, offset validnums2
	call	writeString

	;sum
	mov		edx, offset sumnums				;add up the valid inputs
	call	writeString
	mov		eax, SUM
	call	writeInt						;display signed sum value
	call	crlf

	;rounded
	mov		edx, offset rounded				;display rounded average
	call	WriteString
	xor		edx, edx						
	mov		eax, SUM						;set up sum to be divided by total valid inputs
	cdq										;cdq to extend sign
	mov		ebx, VALID						;mov number of valid inputs into ebx to be denominator
	idiv	ebx
	call	writeInt						;display average
	call	crlf
	


	mov		edx, offset Goodbye				;say goodbye
	call	writestring
	mov		edx, offset UserName
	call	writeString
	call	crlf





	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
