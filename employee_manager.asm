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

    promptMessage      db "Enter a number (1-4): ", 10,13,0
    inputBuffer        db 16 dup(0)
    createMsg          db "Create a new employee profile", 10, 13, 0
    addMsg             db "Add new employee profile", 10, 13, 0
    exitMsg            db "Exit", 10, 13, 0
    invalidMsg         db "Invalid input!", 10, 13, 0

    searchMsg db "Enter employee ID:", 10, 13, 0
    empFoundMsg db "Employee found!", 10, 13, 0
    empNotFoundMsg db "Employee not found", 10, 13, 0

    ; Employee prompts
    empIdPrompt       db "Enter Employee ID: ",10,13,0
    empNamePrompt     db "Enter Employee Name: ",10,13,0
    empPositionPrompt db "Enter Position: ",10,13,0
    empSalaryPrompt   db "Enter Salary: ",10,13,0
    empDatePrompt     db "Enter Date Hired: ",10,13,0

    ; Employee data buffers
    empID             db 32 dup(0)
    empName           db 64 dup(0)
    empPosition       db 64 dup(0)
    empSalary         db 32 dup(0)
    empDateHired      db 32 dup(0)

.code
start:

MainMenu:
    invoke StdOut, addr promptMessage
    invoke StdOut, addr createMsg
    invoke StdOut, addr addMsg
    invoke StdOut, addr exitMsg
    invoke StdIn, addr inputBuffer, sizeof inputBuffer
    invoke atodw, addr inputBuffer
    mov eax, eax  ; EAX = choice

    cmp eax, 1
    je CreateProfile
    cmp eax, 2
    je SearchProfile
    cmp eax, 3
    je ExitProgram
    jmp InvalidInput

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

    jmp MainMenu

ArrayFull:
    invoke StdOut, addr invalidMsg ; Or a "list full" message
    jmp Done

SearchProfile:
    ; Ask for employee ID
    invoke StdOut, addr searchMsg
    invoke StdOut, addr empIdPrompt
    invoke StdIn, addr inputBuffer, sizeof inputBuffer
    invoke atodw, addr inputBuffer  ; Convert input to number
    mov ebx, eax  ; EBX = employee ID to search for

    ; Start searching for the employee in the array
    lea esi, employeeArray
    mov ecx, employeeCount  ; How many employees to search through

    ; Search loop
    xor eax, eax  ; EAX = index
SearchLoop:
    cmp eax, ecx
    jge EmployeeNotFound  ; If we've searched through all employees, exit

    ;Calculate the address of the current employee
    lea edi, [employeeArray]     ; EDI points to the start of the employee array
    mov ebx, eax                 ; EBX = index (employee number)
    mov ecx, SIZEOF Employee     ; Load the size of Employee structure into ECX
    mul ecx                      ; Multiply index by the size of the Employee structure (result in EAX)
    add edi, eax                 ; EDI now points to the correct employee (employeeArray[index])

    ;Access empID field using correct offset
    lea edx, [edi + offset Employee.empID]   ; EDx = address of empID in the current employee
    mov esi, [edx]                           ; Copy empID to ESI for comparison

    ; Compare IDs
    cmp esi, ebx
    je EmployeeFound

    inc eax  ; Move to next employee
    jmp SearchLoop

EmployeeFound:
    ; Display the employee details
    invoke StdOut, addr empFoundMsg

    ;invoke StdOut, addr edi.empID
    lea eax, [edi]
    add eax, offset Employee.empID
    invoke StdOut, eax

    ;invoke StdOut, addr edi.empName
    lea eax, [edi]
    add eax, offset Employee.empName
    invoke StdOut, eax
    
    ;invoke StdOut, addr edi.empPosition
    lea eax, [edi]
    add eax, offset Employee.empPosition
    invoke StdOut, eax

    ;invoke StdOut, addr edi.empSalary
    lea eax, [edi]
    add eax, offset Employee.empSalary
    invoke StdOut, eax

    ;invoke StdOut, addr edi.empDateHired
    lea eax, [edi]
    add eax, offset Employee.empDateHired
    invoke StdOut, eax

    ; Go back to the main menu
    jmp MainMenu

EmployeeNotFound:
    ; No employee found
    invoke StdOut, addr empNotFoundMsg
    jmp MainMenu


ExitProgram:
    invoke StdOut, addr exitMsg
    jmp Done

Done:
    invoke ExitProcess, 0
end start
