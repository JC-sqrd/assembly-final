; EmployeeMenu.asm
.386
.model flat, stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

Employee STRUCT
        empID db 32 dup(?)
        empName db 64 dup(?)
        empPosition db 64 dup(?)
        empSalary db 32 dup(?)
        empDateHired db 32 dup(?)
Employee ENDS

.data
    MAX_EMPLOYEES equ 100
    employeeArray Employee MAX_EMPLOYEES dup(<>)
    employeeCount DWORD 0

    employee1 Employee <>

    promptMessage      db "Enter a number (1-4): ", 0
    inputBuffer        db 16 dup(0)
    createMsg          db "Create a new employee profile", 13, 10, 0
    addMsg             db "Add new employee profile", 13, 10, 0
    exitMsg            db "Exit", 13, 10, 0
    invalidMsg         db "Invalid input!", 13, 10, 0

    ; Employee prompts
    empIdPrompt       db "Enter Employee ID: ",0
    empNamePrompt     db "Enter Employee Name: ",0
    empPositionPrompt db "Enter Position: ",0
    empSalaryPrompt   db "Enter Salary: ",0
    empDatePrompt     db "Enter Date Hired: ",0

    ; Employee data buffers
    empID             db 32 dup(0)
    empName           db 64 dup(0)
    empPosition       db 64 dup(0)
    empSalary         db 32 dup(0)
    empDateHired      db 32 dup(0)

.code
start:
    ; Prompt the user
    invoke StdOut, addr promptMessage

    ; Get input from console
    invoke StdIn, addr inputBuffer, sizeof inputBuffer

    ; Convert input to integer
    invoke atodw, addr inputBuffer
    mov eax, eax  ; result is in EAX

    ; Check and compare input
    cmp eax, 1
    je CreateProfile
    cmp eax, 2
    je AddProfile
    cmp eax, 3
    je ExitProgram

InvalidInput:
    invoke StdOut, addr invalidMsg
    jmp Done

CreateProfile:
    ; Check if we have space
    mov eax, employeeCount
    cmp eax, MAX_EMPLOYEES
    jge ArrayFull

    ; Get pointer to next free employee
    mov ecx, SIZEOF Employee
    mul ecx                        ; eax = employeeCount * SIZEOF Employee
    lea esi, employeeArray
    add esi, eax                   ; ESI = &employeeArray[employeeCount]

    invoke StdOut, addr createMsg

    ; Employee ID
    invoke StdOut, addr empIdPrompt
    invoke StdIn, addr employee1.empID, sizeof employee1.empID

    ; Employee Name
    invoke StdOut, addr empNamePrompt
    invoke StdIn, addr employee1.empName, sizeof employee1.empName

    ; Position
    invoke StdOut, addr empPositionPrompt
    invoke StdIn, addr employee1.empPosition, sizeof employee1.empPosition

    ; Salary
    invoke StdOut, addr empSalaryPrompt
    invoke StdIn, addr employee1.empSalary, sizeof employee1.empSalary

    ; Date Hired
    invoke StdOut, addr empDatePrompt
    invoke StdIn, addr employee1.empDateHired, sizeof employee1.empDateHired

    jmp Done

ArrayFull:
    invoke StdOut, addr invalidMsg ; Or a "list full" message
    jmp Done

AddProfile:
    invoke StdOut, addr addMsg
    jmp Done

ExitProgram:
    invoke StdOut, addr exitMsg
    jmp Done

Done:
    invoke ExitProcess, 0
end start
