TITLE Composite Numbers     (assignment4.asm)

; Author:
; Course / Project ID                 Date:
; Description:

INCLUDE Irvine32.inc


upperLim = 400


.data
myname			BYTE	"Composite Numbers",9,"Programmed by Joshua Strozzi",13,10,0
Instruct		BYTE	"Enter the number of composite numbers you would like to see. ",13,10, "I will accept orders for up to 400 composites.",13,10,0
Failure			BYTE	"Out of range. Try again. ",13,10,0
promptuser		BYTE	"Enter the number of composites to display [1 .. 400]: ",0
toodaloo		BYTE	"Results certified by Joshua. Goodbye.",13,10,0
Tabstring		BYTE	9,0

extracredit		BYTE	"**EC: Align the output columns.",13,10,0

NUM				DWORD	?

PRINTED			DWORD	10

.code
main PROC
	
	call	intro
	call	getUserData
	call	showComposites
	call	farewell
	


	exit	; exit to operating system
main ENDP



intro PROC

	mov		edx, offset myname		;display my program title and my name
	call	writestring

	call	crlf
	mov		edx, offset extracredit
	call	writestring
	call	crlf

	mov		edx, offset instruct	;describe to user what do do
	call	writestring

	ret
intro ENDP




getUserData PROC
start:
	mov		edx, offset promptuser	;pretty self explanatory
	call	writestring
	call	readInt					;take in the users input for k
	xor		ebx, ebx				;make sure ebx is 0
	call	validate				;make sure the number falls between 1 and 400
	cmp		ebx, 1					;the proc returns a 1 for valid and 0 for not
	jne		start					;if it's not valid, redo user input
	mov		NUM, eax				;if valid, save input into NUM 

	ret
getUserData	ENDP






validate PROC
	cmp		eax,0					
	jle		fail					;if less than 0, jump to fail block
	cmp		eax, upperLim			
	jg		fail					;if more than 400, jump to fail block
	jmp		notfail					;otherwise, jump to the not fail block

fail:	
	mov		ebx, 0					;set ebx to 0 for "not valid"
	mov		edx, offset Failure		;print error message
	call	writestring
	jmp		endvblock				;jump to return
notfail:
	mov		ebx, 1					;move 1 into ebx for "valid"
endvblock:
	ret
validate ENDP




;NOT COMPLETE
showComposites PROC
	mov		eax, 0
displayTop:
	inc		eax						;increment eax at the top of every loop
	call	isComposite				;check if eax is composite, if it is, ebx will be 1

	cmp		ebx, 1					;check if procedure returned true (1) in ebx
	jne		displaytop				;if not then go back to top
	
	call	writedec				;print if it does pass the procedure
	mov		edx, offset Tabstring
	call	writeString				;print tab to screen between each number
	
	mov		ebx, NUM			
	dec		ebx						;decrement the amount loop count by one
	cmp		ebx, 0					;check it it has reached 0
	je		endDisplay				;if so, end
	
	mov		NUM, ebx				;otherwise return number into it's memory location

	mov		ebx, PRINTED		
	cmp		ebx, 0					;check to see if I've printed a set of 10 numbers
	dec		ebx						;then decrement 
	mov		PRINTED, ebx			;and update
	jne		nonewline				;if I've not yet printed 10 numbers, don't print new line


	call	crlf					;print new line
	mov		ebx, 10					;restore the newline counter
	mov		PRINTED, ebx			;update
nonewline:
	jmp		displayTop				;and jump to top of loop



endDisplay:
	call	crlf				
	ret
showComposites ENDP





;-------------------------------------
;checks if number in eax is composite and returns a 1 or 0 in ebx
;eax, ebx, ecx, and edx are all altered in the process

isComposite PROC

;COMPLETE
;-------------------------------------

	mov		ecx, eax		; set up loop number
	xor		ebx, ebx
top:
	xor		edx, edx		;make sure edx is zero
	push	eax
	div		ecx				;divide k by k-x til k-x=1
	cmp		edx, 0			;check to see if the number divides evenly
	jne		notzero			;if it's not zero then just loop back to top
	inc		ebx				;if its equal, increment ebx
notzero:
	pop		eax				;restore eax with the number being checked
	loop	top				;loop back to top


	cmp		ebx, 2			;if the number divides evenly more than 2 times, then it's a composite number
	jle		itsnotcomp		;if it doesn't divide cleanly more than 2 times, then its not
	mov		ebx, 1			;move 1 into ebx for "is composite" if it divides evenly twice
	jmp		endBlock		;return

itsnotcomp:
	mov ebx, 0				;doesn't divide evenly >2 times then move 0 for not composite into ebx
	
endBlock:
	ret
isComposite ENDP






farewell PROC
	mov		edx, offset toodaloo	;say bye
	call	writestring

	ret
farewell ENDP





END main
