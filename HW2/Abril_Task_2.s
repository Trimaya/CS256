.data
# Input Arrays
A: .word 12, -8, 25, 5, -3, 18, 30, 7, -10, 2, 45, -6, 9, 11, -4, 14, -12, 8, 0, 13, -7, 6, 2, -15, 10, -1, 3, 4, -9, 2, 17, -5
B: .word -5, 14, 8, -20, 3, 7, 22, -15, 9, 16, -4, 30, -2, 5, 12, -11, 13, -9, 6, 2, -18, 4, 10, -3, 1, -8, 9, 15, -2, -6, 5, 12
# Output Array
C: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 # Result array

.text
main:
    # Load base addresses of the variables
    la t0, A              # Load the base address of array A into t0
    la t1, B              # Load the base address of array B into t1
    la t2, C              # Load the base address of array C (output) into t2

    # Initialize loop variables
    addi s0, zero, 0      # Initialize the loop counter i (s0) to 0
    addi s1, zero, 16     # Length of array N = 16

for:
    bge s0, s1, done      # If i (s0) >= N (s1), exit the loop and go to "done"

    # Load the real and imaginary parts of the two complex numbers
    lw a0, 0(t0)          # Load the real part of the first complex number (A[i]) into a0
    lw a1, 4(t0)          # Load the imaginary part of the first complex number (A[i]) into a1
    lw a2, 0(t1)          # Load the real part of the second complex number (B[i]) into a2
    lw a3, 4(t1)          # Load the imaginary part of the second complex number (B[i]) into a3

    # Call the complex multiply function
    jal ra, mulcmplx      # Compute the product of the two complex numbers (result in a0 and a1)

    # Store the result in the output array
    sw a0, 0(t2)          # Store the real part in C[i]
    sw a1, 4(t2)          # Store the imaginary part in C[i+1]

    # Move to the next complex number
    addi t0, t0, 8        # Increment the pointer for A by 8 bytes (2 words for the current complex number)
    addi t1, t1, 8        # Increment the pointer for B by 8 bytes
    addi t2, t2, 8        # Increment the pointer for C by 8 bytes
    addi s0, s0, 1        # Increment the loop counter i

    j for                 # Jump back to the start of the loop

done:
    # End the program
    li a7, 10             # Load the exit syscall number
    ecall                 # Terminate the program
    nop                   # No operation (program finish)

mulcmplx:
    mul t5, a0, a2        # Compute ac (real part of num1 * real part of num2), store in t5
    mul t6, a1, a3        # Compute bd (imaginary part of num1 * imaginary part of num2), store in t6
    sub t4, t5, t6        # Compute RealPart = ac - bd, store temporarily in t4

    mul t5, a0, a3        # Compute ad (real part of num1 * imaginary part of num2), store in t5
    mul t6, a1, a2        # Compute bc (imaginary part of num1 * real part of num2), store in t6
    mv a0, t4             # Move RealPart (t4) into a0
    add a1, t5, t6        # Compute ImagPart = ad + bc, store in a1

    jr ra                 # Return to the caller