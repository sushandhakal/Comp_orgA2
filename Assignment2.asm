.data
	input: .space 10001
	invalid_number: .asciiz "NaN"
	large_number: .asciiz "too large"
.text
	main:
			# Input the hexadecimal numbers from the user
			la $a0, input
			li $a1, 1001
			li $v0, 8
			syscall
			
			la $s0, input	# Saving the userInput
			li $s1, 0		# Saving the starting pointer
			li $s2, 0		# Saving the ending pointer
		find_words:
			la $s1, ($s2)
		find_single_word:
			add $t1, $s0, $s2	# $t1 pointing to the required character
			lb $t2, 0($t1)		# $t2 storing the current character
			# Setting the conditions for exiting the loop
			beq $t2, 0, end_fsw
			beq $t2, 10, end_fsw
			beq $t2, 44, end_fsw
			# Adding the value of the end pointer
			addi $s2, $s2, 1
			j find_single_word
		end_fsw:
			# loading the arguments to call subprogram_2
			la $a0, ($s1)
			la $a1, ($s2)
			jal subprogram_2	# Calling subprogram 2
			# The return value of subprogram_2 are in the stack which is used again by the subprogram_3
			jal subprogram_3	# Calling subprogram 3
			# Setting condition to exit the loop to find words
			beq $t2, 0, end_fw
			beq $t2, 10, end_fw
			addi $s2, $s2, 1	# Increasing the value of s2
			# Printing the coma
			li $v0, 11
			li $a0, 44
			syscall
			j find_words
		end_fw:
			# Exiting the program
			li $v0, 10
			syscall
	subprogram_2:	
			la $s7, ($ra)		# Saving the value of $ra in $s7
			la $t9, ($a0)		# Stores the starting address
			addi $t8, $a1, 0	# Stores the ending address
			la $t7, input		# Stores the first address of input in $t7
		delete_front:
		# Deletes space from the front of the string
			beq $t9, $t8, end_de	# Exit the loop
			add $t6, $t7, $t9	# $t6 points to current character
			lb  $t5, ($t6)		
			# If space is found repeat the loop
			beq $t5, 32, found
			beq $t5, 9, found
			j delete_end		# Start deleting space from the end if the current char is not space
		found:
			addi $t9, $t9, 1
			j delete_front
		delete_end:
		# Deletes the spaces at the end of the string
			beq $t9, $t8, end_de
			add $t6, $t7, $t8
			addi $t6, $t6, -1
			lb $t5, ($t6)
			beq $t5, 32, found1
			beq $t5, 9, found1
			j end_de
		found1:
			addi $t8, $t8, -1
			j delete_end
		end_de:
			beq $t9, $t8, not_number	# If there is not a single character in the string then it is not a number
			li $t4, 0			# Initial decimal value
			li $s6, 0			# Length of the string
		convert:
		# check if the char is valid by calling the function
		# the function will return value in $v0 and $v1
			beq $t9, $t8, end_convert
			add $t6, $t7, $t9
			lb $t5, ($t6)
			#calling the subprogram-1
			la $a0, ($t5)
			jal subprogram_1
			bne $v0, 0, continue
			j not_number
		continue:
			# Operations to convert hexadecimal into decimal
			# SHifting to the left by 4 bits to raise the power of 16
			sll $t4, $t4, 4
			sub $t6, $t5, $v1
			add $t4, $t4, $t6
			addi $s6, $s6, 1
			addi $t9, $t9, 1
			j convert
		end_convert:
			bgt $s6, 8, too_large  # If the string of valid numbers is greater than 8, then the string is toolarge to display
			li $v0, 1
			j end_s2
		too_large:
		# Operations if the numbers are too large
			li $v0, 0
			la $t4, large_number
			j end_s2
		not_number:
		# Operations of the string contains invalid characters
			li $v0, 0
			la $t4, invalid_number
		end_s2:
		# Loading the stack with return values and returning to the main function
			addi $sp, $sp, -4
			sw $t4, ($sp)
			addi $sp, $sp, -4
			sw $v0, ($sp)
			la $ra, ($s7)
			jr $ra
	
	subprogram_1:
			blt $a0, 48, invalid		#branch to if_invalid label if value in $t1 is less than 48 (ASCII dec for number 0)		
			addi $v1, $0, 48		# store the ASCII dec to be subtracted in $s1
			blt $a0, 58, valid		#branch to if_invalid label if value in $t1 is less than 58 (next ASCII dec for number 9)		
			blt $a0, 65, invalid		# 65 = ASCII dec for 'A'
			addi $v1, $0, 55
			blt $a0, 71, valid		# if $t1 ascii value is less than 97, branch to invalid label
			blt $a0, 97, invalid		#if $t1 is holding a character with ascii value less than 97 , branch to invalid label
			addi $v1, $0, 87
			blt $a0, 103, valid	
			bgt $a0, 102, invalid		#branch to if_invalid if value in $t1 is greater than 102 (ASCII dec for 'f')
		valid:
			li $v0, 1
			jr $ra
		invalid:
			li $v0, 0
			jr $ra
	subprogram_3:
			# loading the arguments from the stack
			lw $t8, ($sp)			
			addi $sp, $sp, 4		
			lw $t7, ($sp)			
			beq $t8, 0, invalid0	# If the value of $t8 is 0, the string is invalid	
			
			# Dividing the number by 10, to prevent overflow
			li $t6, 10
			divu $t7, $t6			
			li $v0, 1
			mflo $a0
			beq $a0, 0, dont_print	# If the number is 0, we don't print it		
			syscall				
		dont_print:
			mfhi $a0
			syscall				
			j exitS3
		invalid0:
		# Operations for invalid string
			li $v0, 4
			la $a0, ($t7)
			syscall
		exitS3:
		# Returning control to the main function
			jr $ra
