.section .text,
.globl _start
_start:
    # Perform some simple arithmetic
    movl $2, %ebx
    movl $4, %ecx

    # Store the result in %ebx ready for the sys_exit call
    addl %ecx, %ebx

    movl $1, %eax
    int $0x80
