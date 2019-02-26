TITLE Sorting Random Integers     (assignment5.asm)

; Author: Joshua Strozzi	
; Course / Project ID                 Date: February 20, 2018
; Description: Generates user defined amount of random numbers, store them consecutively in an array
; display them, sort them, then display them again in their sorted order 

INCLUDE Irvine32.inc

min = 10
max = 200
lo = 100
hi = 999

.data

introduction	BYTE	"Sorting Random Integers", 9, "Programmed by Joshua Strozzi",13,10, "This program generates random numbers in the range [100.. 999], displays the original list, sorts the list, and calculates the median value.",13,10, "Finally, it displays the list sorted in descending order. ",13,10,0
promptuser		BYTE	"How many numbers should be generated? [10 .. 200]: ",0
Failure			BYTE	"Invalid Input",13,10,0
unsorted		BYTE	"The unsorted random numbers: ",13,10,0
sorted			BYTE	"The sorted list: ",13,10,0
medianis		BYTE	"The Median is: ",0
tabstring		BYTE	9,0

NUMS			DWORD	?
PRINTED			DWORD	10


array			DWORD	max DUP(?)
kvar			DWORD	0
ivar			DWORD	?
jvar			DWORD	?

.code
main PROC
	call	randomize
	call	intro
	
	push	offset Failure
	push	offset promptuser
	push	offset NUMS
	call	getData
	
	push	offset array				;set up parameter (@array)
	push	NUMS						;set up parameter (number of Nums in array)
	call	fillArray
	
	push	offset unsorted
	push	offset tabstring
	push	PRINTED						
	push	offset array				;set up parameter (@array)
	push	NUMS						;set up parameter (number of Nums in array)
	call	displayList
	

	push	kvar						;ebx+24
	push	jvar						;ebp+20
	push	ivar						;ebp+16
	push	offset array				;set up parameter (@array)
	push	NUMS						;set up parameter (number of Nums in array)
	call	sortList


	push    offset sorted
	push	offset tabstring
	push	PRINTED						
	push	offset array				;set up parameter (@array)
	push	NUMS						;set up parameter (number of Nums in array)
	call	displayList
	
	call	crlf
	mov		edx, offset medianis
	call	writestring

	push	offset array				;set up parameter (@array)
	push	NUMS						;set up parameter (number of Nums in array)
	call	displayMedian





	exit	; exit to operating system
main ENDP


;-------------------------------
intro PROC


;------------------------------
	mov		edx, offset introduction
	call	writestring
	
	ret
intro ENDP


;-----------------------------------
getData PROC

;----------------------------------- 
	push	ebp
	mov		ebp, esp
	mov		esi, [ebp+8]

start:
	mov		edx, [ebp+12]		;ask for number of random numbers to be generated
	call	writestring					
	call	readInt						;take that number
	xor		ebx, ebx					
	call	validate					;check if the number is valid (1=valid, 0=invalid)
	cmp		ebx, 1						;if its valid (1) then update NUMS
	jne		start						;if it's not valid (0), then try again
	mov		[esi], eax

	pop		ebp
	ret     12
getData	ENDP


;---------------------------------
validate PROC

;---------------------------------
	cmp		eax, min					;see if its more than the min
	jl		fail
	cmp		eax, max					;and less than the max
	jg		fail
	jmp		notfail						;if within boundaries, then return a 1 to calling PROC

fail:	
	mov		ebx, 0						;if not within boundaries, return a 0 to calling PROC
	mov		edx, [ebp+16]
	call	writestring
	jmp		endvblock
notfail:
	mov		ebx, 1
endvblock:
	ret
validate ENDP



;-------------------------------
fillArray PROC

;-------------------------------
	push	ebp				;push ebp to top of stack and
	mov		ebp, esp		;point ebp to it so to create stack frame
	mov		esi, [ebp+12]	;@ of array
	mov		ecx, [ebp+8]	;number of loops
	
	xor		edx,edx


arrayfill:
	mov		eax, hi			;
	sub		eax, lo			;set up range of random number to be 0 to (hi-(lo-1))
	inc		eax				;make it 0 to (hi-lo)
	call	RandomRange		;generate the random number in this range
	add		eax, lo			;add lo to make its range lo to hi

	mov		[esi+edx], eax	;move number into current index of the array
	add		edx, 4			;increment index

	loop	arrayFill
	
	pop		ebp				;restore old ebp
	ret		8				;return to stack to before anything was pushed onto it

	
fillArray ENDP


;------------------------------
sortList PROC

;for(k=0; k<request-1; k++) { 
;   i = k; 
;   for(j=k+1; j<request; j++) { 
;      if(array[j] > array[i]) 
;         i = j; 
;   } 
;   exchange(array[k], array[i]); 
;} 
;------------------------------
	xor		eax, eax
	push	ebp					;push ebp to top of stack and
	mov		ebp, esp			;point ebp to it so to create stack frame
	mov		esi, [ebp+12]		;@ of array
	mov		ecx, [ebp+8]		;number of loops

	dec		ecx					;request-1
	xor		edx, edx			;k=0
mainTop:
	mov		eax, [ebp+24]		;eax=k
	mov		[ebp+16], eax		;i=k

	
	inc		ecx					;ecx is now request, not request-1
	inc		eax					;k+1
	mov		[ebp+20],eax		;j=k+1
;#####################TOP of Inner Loop###########################
innerTop:
	
	mov		edx, [ebp+20]
	mov		ebx, [ebp+16]

	mov		eax, [esi+(edx*4)]	;eax array[j] (or array[i+1])
	mov		ebx, [esi+(ebx*4)]	;ebx array[i] 

	cmp		eax, ebx			; if (array[j] > array[i])
	jle		noswapblock			;
	mov		[ebp+16], edx		;i=j



noswapblock:


	mov		eax, [ebp+20]
	inc		eax			;j++
	mov		[ebp+20], eax
	cmp		ecx, [ebp+20]	;if j<request
	jg		innerTop		;continue looping
;##################end inner loop#########################	
	
	
	dec		ecx					;restore ecx to request-1
	mov		edx, [ebp+24]		;value of k
	mov		ebx, [ebp+16]		;value of i
	push	esi					;save place of original esi (array start)
	mov		eax, 4
	mul		edx					
	add		esi, eax			;@ of array[k]
	push	esi					;pass as parameter
	sub		esi, eax			;restore esi
	mov		eax, 4				;restore eax to 4
	mul     ebx					;eax=k's position
	add		esi, eax			;@ of array[i]
	push	esi


	call	exchange
	pop		esi					;restore original array start
	
	mov		eax, [ebp+24]		;eax gets value of k
	inc		eax					;k++
	mov		[ebp+24], eax		;return updated value of k
	cmp		ecx, [ebp+24]		;if k!=c, then continue looping
	jg		mainTop
	call	crlf


	pop		ebp				;restore stack base

	ret		24				;return to before parameters were pushed onto stack
sortList ENDP


;---------------------------------
exchange PROC
;
;@ of k at ebp+12
;     i at ebp+8
;---------------------------------
	push	ebp
	mov		ebp, esp
	mov		esi, [ebp+8]	;address of array[i] in esi
	mov		eax, [esi]		;contents of i in eax
	
	mov		esi, [ebp+12]	;addresss of array[k] in esi
	xchg	eax, [esi]		;contents of k in eax, i in k
	mov		esi, [ebp+8]	;@ of i in esi
	mov		[esi], eax		;mov number in k into i



	pop		ebp
	ret 8
exchange ENDP


;---------------------------------
displayList PROC

;---------------------------------
	
	push	ebp						;set up stack frame
	mov		ebp, esp				;create new stack base in stack frame
	mov		esi, [ebp+12]			;@ of array
	mov		ecx, [ebp+8]			;number of Numbers in the array

	mov		edx, [ebp+24]			;title string
	call	writestring
	
	xor		edx,edx					


arrayshow:

	mov		eax, [esi+edx]			;display number in current index
	call	writeDec
	
	mov		ebx, [ebp+16]			;print a new line after 10 number have been printed
	cmp		ebx, 0					;if <10 nums have been printed
	dec		ebx
	mov		[ebp+16], ebx			
	jne		nonewline				;don't print a newline

	call	crlf
	mov		ebx, 10					;if new line, restore counter
	mov		[ebp+16], ebx
	jmp		contindis				;and resume printing
	
	
nonewline:	
	push	edx						;save edx in stack so it can be used to print a string
	mov		edx, [ebp+20]	        ;print tab between numbers
	call	writestring	
	xor		edx,edx					;make sure edx is ready to take a number
	pop		edx						;restore edx
contindis:	
	add		edx, 4					;move to next index in array

	loop	arrayshow				;
	pop		ebp						;restore old stack bottom
	ret		20						;return to before anything was pushed onto stack
		
	
displayList ENDP



;---------------------------------
displayMedian PROC

;---------------------------------
	push	ebp						;set up stack frame
	mov		ebp, esp				;create new stack base in stack frame
	mov		esi, [ebp+12]			;@ of array
	mov		eax, [ebp+8]			;number of Numbers in the array
	
	xor		edx,edx					;ensure edx is clear
	mov		ebx, 2					;prepare to divide eax by 2

	div		ebx
		
	cmp		edx, 0					;if the number of numbers in array is even, find avg of middle numbers
	jne		oddBlock				;if num of nums in array is odd, then print middle number

	mov		ebx, [esi+(eax*4)]		;grab ((number of nums in array)/2)+1
	dec		eax
	mov		ecx, [esi+(eax*4)]		;grab ((number of nums in array)/2)
	add		ebx, ecx				;sum the two middle numbers
	mov		eax, ebx				
	mov		ebx, 2					;find avg of the two middle numbers
	div		ebx
	jmp		endBlock

oddBlock:

	mov		ebx, eax				;
	mov		eax, [esi+(ebx*4)]		;grab middle number

endBlock:
	call	writeDec
	call	crlf


	pop		ebp						;restore old stack bottom
	ret 8
displayMedian ENDP





END main









