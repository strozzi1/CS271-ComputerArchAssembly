TITLE We Be Fibbin    (assignment2.asm)

; Author: Joshua Strozzi
; Course / Project ID                 Date:
; Description: Take users input for name and number of steps they'd like to view of fibonacci's sequence, make sure its within range

INCLUDE Irvine32.inc

; (insert constant definitions here)

FIB_lowerlim=1;
FIB_upperlim=46;


.data

Intro_1			BYTE	"Fibonacci Numbers", 13,10, "Programmed by Joshua Strozzi",13,10, 0
prompt_1		BYTE	"What's your name: ",0
hello_string	BYTE	"Hello, ",0

spaces		    BYTE	9,9, 0
newline			BYTE	13,10,0

number_range	BYTE	"Enter the number of Fibonacci terms to be displayed",13,10, "Give the number as an integer in the range [1 .. 46].",13,10,0
prompt_2		BYTE	"How many Fibonacci terms do you want: ",0
not_in_range	BYTE	"Out of range. Enter a number in [1 .. 46] ",13,10,0


UserName		BYTE	33 DUP(0)
UserNum			DWORD	?

fib				DWORD	?				;f(x)
fib_last		DWORD	?				;f(x-1)
fib_lastlast	DWORD	?				;f(x-2)

outro			BYTE	"Results certified by Joshua Strozzi.",13, 10, "Goodbye, ",0

everyfive		DWORD	5 ;keeps track of when to print new line 




.code
main PROC

;INTRODUCTION SECTION
	mov		edx, OFFSET Intro_1			;Introduce program and programmer
	call	writestring

	mov		edx, OFFSET prompt_1		;ask for name
	call	writestring
	mov		edx, OFFSET	UserName		;
	mov		ecx, 32						;set limit for userName
	call	readstring					;take name

	mov		edx, OFFSET hello_string	;say
	call	writestring					;hello
	mov		edx, OFFSET UserName		;to the user
	call	writestring
	call	crlf
	jmp		number_1					;jump to user input number start

;Ask for number
										
number_fail:							;come to here if they enter bad number
	mov		edx, offset not_in_range	;error message
	call	writestring
	jmp		number_retry				;jump to number input section

number_1:
	mov		edx, offset number_range	;describe range
	call	writestring
number_retry:							;goes through here to initially input number or retry input
	call	crlf
	mov		edx, offset prompt_2		;ask for number
	call	writestring

	call	readint
	cmp		eax, FIB_lowerlim
	jl		number_fail					;retry if number lower than 0
										
	cmp		eax, FIB_upperlim
	jg		number_fail					;and must retry if greater than 46
		
	mov		UserNum, eax				;if number is 0<x<47 then they can continue on to display section

;display fib sequence
	mov		ecx, UserNum
	mov		fib, 1						;f(x)
	mov		fib_last, 1					;f(x-1)
	mov		fib_lastlast, 0				;f(x-2)

fibonacci:
	mov		eax, fib					;f(x)=f(x-1)+f(x-2)
	call	writeDec					;display f(n)
	;call	crlf
	mov		ebx, fib_last				;ebx gets f(x-1)
	add		ebx, fib_lastlast			;ebx gets f(x-1)+f(x-2) which is f(x)
	mov		eax, ebx					;eax gets f(x)
	mov		fib, eax					;fib gets f(x) (updating fib)
	mov		eax, fib_last				;mov f(x-1) to eax
	mov		fib_lastlast, eax			;update new f(x-2) to last f(x-1)
	mov		eax, fib					;mov now old f(x) to eax
	mov		fib_last, eax				;now update f(x-1) to old now old f(x)

	mov		edx, offset spaces			;print a tab 
	call	writestring


	mov		eax, everyfive				;set eax to everyfive to
	cmp		eax, 0						;compare it to zero
	dec		eax							;don't forget to decrement it
	mov		everyfive, eax				;and move it back
	je		printnewline				;if its equal to 0, then we print a new line
	jmp		nonewline					;otherwise we don't


printnewline:
	mov		edx, offset newline
	call	writestring
	mov		everyfive, 5				;also reset this variable everytime it prints new line
nonewline:
	loop fibonacci						;decrement ecx and start over loop til ecx=0


;outro

	call	crlf
	mov		edx, offset outro
	call	writestring
	mov		edx, offset username		;say goodbye to user
	call	writestring
	call	crlf

;program end

	

; (insert executable instructions here)

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
