;Low Level I/O Precedures     (assignment6.asm)

; Author: Joshua Strozzi (932-546-1240
; Course: CS 271-001               Date: 18 March, 2018

; Description: Takes input from user as string of chars, checks if its a 32 bit integer, converts to string to int, stores it in array
; Once the array is full, go through array and convert each digit in number to a char and display as string, display the sum, and avg too

INCLUDE Irvine32.inc

; (insert constant definitions here)

.data

intro		BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures",13,10,"Written by: Joshua Strozzi",13,10,13,10, "Please provide 10 unsigned decimal integers.",13,10, "Each number needs to be small enough to fit inside a 32 bit register.",13,10, "After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.",13,10,0
promptuser	BYTE	"Please enter an unsigned number: ",0
numsstring	BYTE	"You entered the following numbers: ",13,10,0
sumstring	BYTE	"The sum of these numbers is: ",0
avgstring	BYTE	"The average is: ",0
failure		BYTE	"ERROR: You did not enter an unsigned number or your number was too big.",13,10,0
goodbye		BYTE	"Thanks for playing, Goodbye!",0

array		DWORD	11 DUP(?)
temp		BYTE	12 DUP(?)
nums		DWORD	0					;counts how many numbers are in the array at any given point
sum			DWORD	0

stringlen	DWORD	?


;=========================================================
getString	MACRO	stringaddress, prmpt
;description: takes input by user and saves it into temp string
;parameters: temp string address, prompt message
;pre-conditions: none
;post-conditions: the temp string has the input from the user
;=========================================================	
	mov		edx, prmpt
	call	writestring

	mov		esi, stringaddress
	mov		edx, esi				;set up char array to be written to
	mov		ecx, 11					;set up char limit
	call	readstring				;get users input
	mov		edx, esi				;mov string @ to edx
	;call	writestring				;print string addressed in edx
	;call	crlf					;newline

ENDM



;===================================================
displayString	MACRO	arraypos, tempstring
;description: takes number at array position, divs by 10 til quotient is 0 while save remainder into temp string,
;this stores the number backwards, so once the number is saved as a string, we read it out backwards to display it normally
;parameters: the curr position in the array, the temp string
;pre-conditions: there's a number at arraypos
;post-conditions: a number has been output, but all registers are restored
;===================================================		

	pushad

	xor		ecx, ecx
	mov		esi, arraypos					;esi gets the address of the beginning of the array
	mov		edi, tempstring 				;move the start address of the temp char array into edi
	mov		eax, [esi]						;get value at array postition into eax
	cld										;clear direction flag so edi increments when stosb is called

	mov		ebx, 10							;used to divide eax
disLoopTop:
	inc		ecx
	xor		edx, edx
	div		ebx								;eax holds quotient, edx holds remainder 
	xchg	eax, edx						;eax now holds the remainder, edx holds quotient
	add		eax, 48							;eax now holds character corresponding to the remainder
	stosb									;stores character in al into edi, and increments edi
	xchg	eax, edx						;move quotient back into eax to be divided again
	cmp		eax, 0							;if quotient is 0, then it can't be divided anymore
	jne		disLoopTop						;
	xchg	esi, edi						;exchange arrays so we can increment backwards through which ever string is being printed
	std
	dec		esi
disLoopTwoTop:
	lodsb

	call	writechar
	loop	disLoopTwoTop
	;mov		edx, tempstring
	;call	writestring

enddisblock:
	popad
ENDM




.code

main PROC

	mov		edx, offset intro
	call	writestring
	call	crlf

	push	offset nums
	push	offset failure
	push	offset stringlen		;address of temp string length
	push	offset promptuser		;address of user prompt
	push	offset array			;address of array of numbers
	push	offset temp				;address of temporary string
	call	ReadVal

	call	crlf

	push	offset avgstring
	push	offset sumstring
	push	offset numsstring
	push	offset sum
	push	offset temp
	push	offset array
	call	WriteVal
	call	crlf
	call	crlf

	mov		edx, offset goodbye
	call	writestring
	call	crlf

	exit	; exit to operating system
main ENDP



;======================================================
ReadVal	PROC
;Description: function to get string from user, get length of each string to then convert the strings to ints and put them in an array
;Parameters: The @ of the array of 32-bit ints, temporary string, string length, and output strings
;Pre-conditions: parameters are pushed onto the stack and none of the registers have anything necessary
;Post-conditions: The array is full of 32-bit integers
;======================================================
	push	ebp
	mov		ebp, esp
	mov		ecx, 10
	jmp		L1
readfailblock:
	mov		edx, [ebp+24]
	call	writestring
	call	crlf
L1:
	push	ecx							;save counter
	GetString	[ebp+8], [ebp+16]
	
	pop		ecx							;save counter just incase it jumps
	cmp		eax, 9						;compare string length
	jg		readfailblock				;if its very long then don't continue through loop
	push	ecx
				
	push	[ebp+8]						;string address
	push	[ebp+20]					;string length
	call	GetLength					;get length, check each character, if within 32-bit size

	mov		esi, [ebp+20]				;get address of last string length
	mov		eax, [esi]					;get number of last strings digits
	cmp		eax, 0						;if it's 0, then that means it didn't pass
	pop		ecx							;restore counter here because if I do jumpt to top, then things get messed up
	je		readfailblock				;if it doesn't pass, then go to the top and try again
	

	push	ecx

	push	[ebp+8]						;temp string address
	push	[ebp+20]					;temp string length address
	push	[ebp+12]					;array position address
	call	ConvertToDec
	;call	writedec
	;call	crlf
	

	push	[ebp+28]					;address of number of nums in array
	push	[ebp+12]					;array start address
	push	eax							;value that passed all requirements
	call	AddtoArray


	pop		ecx


							
	loop	L1




;endblock:
	pop		ebp
	ret		24
ReadVal	EndP


;==============================================
ConvertToDec PROC
;Parameters: temp string, it's length, and the array position are passed as parameters
;Description: Takes in a string of numbers, convert it into a Dec, puts it in array
;Pre-conditions: A string is at the temp string mem address, the length is also stored in mem
;Post-conditions: eax holds the integer value, ebx, ecx, edi, and esi have all also been changed, but they weren't necessary
;=============================================
	push	ebp
	mov		ebp, esp

	xor		edi, edi
	mov		esi, [ebp+12]		;temp length address
	mov		ecx, [esi]			;set loop counter to string len
	dec		ecx					;string len minus one because that's how navigating a string works
	mov		esi, [ebp+16]		;temp string address
	add		esi, ecx			;set pointer to last letter in array
	mov		ebx, 1				;initialize multiplier
	mov		edx, 10				;set the multiplier's multiplier
	std							;set direction flag so we can increment backwards through the string
	inc		ecx					;set loop counter back to string length
convertLoop:
	lodsb						;load char into al and dec esi
	sub		eax, 48
	mul		ebx					;multiply eax by multiplier
	add		edi, eax			;add sum to edi
	mov		eax, ebx			;mov multiplier into eax
	mov		ebx, 10
	mul		ebx					;increment multipler by another power of ten	
	mov		ebx, eax			;move updated multiplier into ebx
	xor		eax, eax			;make sure eax is clear before starting over loop
	loop	convertLoop

	mov		eax, edi


	pop		ebp
	ret	12
ConvertToDec ENDP


;==============================================
getLength	PROC
;Description: checks each character to get size of string, and determines whather or not they are all numbers and not any letter
;Parameters: temporary string address, temp string length address
;pre-conditions: A number was input by the user
;post-conditions: the stringlength variable is set
;==============================================
	push	ebp
	mov		ebp, esp

	mov		esi, [ebp+12]			;temp char array address
	push	esi						;save position at start of char array
	xor		eax,eax
	xor		edx,edx
loop_len:
	mov		dl,[esi]				;get character
	cmp		dl,0					;check character
	jz		done					;quit if cmp set the zero flag
	cmp		dl, 48					;is it the character for zero or higher?
	jl		asciifailblock
	cmp		dl, 57					;is it the character for 9 or lower?
	jg		asciifailblock			;if not then it failed

	inc		esi						;move to next character
	inc		eax						;increment string size counter
	jmp		loop_len				;repeat

done:
	pop		esi						;restore postion of esi at beginning of the string

	mov		esi, [ebp+8]			;get address of temp string length
	mov		[esi], eax			    ;set it to to size of string
	jmp		endlenblock				

asciifailblock:
	pop		esi						;restore position of esi at beginning of the string
	
	mov		esi, [ebp+8]			;set esi to address of stringlen memory
	mov		eax, 0					;
	mov		[esi], eax				;if string is not a number, then set length of string to 0
endlenblock:	

	pop		ebp
	ret		8
GetLength ENDP


;========================================
AddtoArray	PROC
;Description: Populates array one integer at a time
;Parameters: The value of the integer input by the user, and the start address of the array (12), address of the number of numbers in array
;Pre-Conditions: String input by the user passed all requirements and is ready to be in array
;Post-Conditions: Array has one more number in array (up to 15 nums), nums variable is incremented
;========================================
	push	ebp
	mov		ebp, esp
	
	mov		esi, [ebp+16]				;address of number of numbers in array (I can delete this)
	mov		ecx, [esi]					;number of values in array currently into ecx
	mov		esi, [ebp+12]				;address of start of the array
	mov		eax, [ebp+8]				;literal value of users input


	mov		[esi+(ecx*4)], eax			;move value into next empty space in the array
	
	mov		esi, [ebp+16]				;address of number of nums in array into edi
	inc		ecx
	mov		[esi], ecx					;update number of nums in array
	
	pop		ebp
	ret		12
AddtoArray	ENDP

;==================================================
WriteVal	PROC
;Description: 
;Parameters: Array address, @tempstring, sum address, @numsstring, @sumstring, @avgstring
;pre-conditions: array is full of number
;Post-conditions:
;==================================================
	push	ebp
	mov		ebp, esp
	xor		ecx,ecx						;make sure counter is 0		
	mov		esi,[ebp+8]					;esi gets the address of the beginning of the array
	mov		edx, [ebp+20]				;edx gets address of numsstring string
	call	writestring
	xor		edx, edx
topDisplay:

	displayString		esi , [ebp+12]	;displays number at [esi] as a string
		
	add		esi, 4						;increment esi to the next positon in the array
			
	xor		eax, eax
	mov		al, 44						;comma character
	call	writechar
	xor		eax, eax
	mov		al, 9						;tab character
	call	writechar

	inc		ecx							;increment position in array
	cmp		ecx, 10					    ;if at position 11
	jl		topDisplay					;exit loop
	
	push	[ebp+12]
	push	[ebp+28]					;address of avgstring
	push	[ebp+24]					;address of sumstring
	push	[ebp+16]					;address of sum holder
	push	[ebp+8]						;address of array 
	call	calcSum

	pop		ebp
	ret	24
WriteVal	EndP


;================================================
calcSum		PROC
;Parameters: address of sum, address of array, sumstring address, avg string address, address of temp string
;description: increments through array and takes their sum, displays it as a string, then gets avg and displays the avg
;Pre-conditions: array is full 
;post-condtions: nothing that matters is changed, just displays sum and saves avg into @sum
;================================================
	push	ebp
	mov		ebp, esp
	mov		esi, [ebp+8]				;address of sum
	xor		ebx, ebx
	xor		ecx, ecx
	mov		edx, [ebp+16]				;edx gets the sumstring address
	call	crlf
	call	writestring
	xor		edx, edx
calcSumLoop:
	mov		eax, [esi+ecx*4]			;add into eax array[ecx]
	add		ebx, eax					;save sum into ebx

	inc		ecx							;for loop
	cmp		ecx, 10						;if less than 10, then we gucci
	jl		calcSumLoop

	mov		[esi], ebx					;move sum into address of sums
	displayString	esi, [ebp+24]		;display the sum as a string
	
	;call	writedec
	call	crlf						
	mov		eax, [esi]					;move sum into eax
	div		ecx							;divide sum by total numbers
	mov		[esi], eax					;mov avg into address of the sum
	xor		edx, edx					
	mov		edx, [ebp+20]				;string
	call	writestring					;can't call display string twice in one procedure, could make another whole procedure, but the point is if I can do this, and as you can see from my earlier use in this and other procedures, I can indeed write number as strings whenever I want
	xor		edx, edx

	mov		eax, [esi]					;mov avg into eax
	call	writedec					


	pop		ebp
	ret		20
calcSum		EndP



END main
