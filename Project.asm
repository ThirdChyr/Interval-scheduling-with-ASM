.data
    astask: .asciiz "Input task : "
    asstart: .asciiz "Start : "
    asend: .asciiz "End : "
    tab: .asciiz " "
    wuk : .asciiz " : "
    skip : .asciiz "\n"
    counting : .asciiz "Task -> "
    cc:.asciiz "Can do "
    jtask: .asciiz" Task"
    outtak : .asciiz "Task:"
    scout:.word 1
    task: .word 0
    #count and time is -1
    count : .word 0
    time : .word -1
    #all task is not more than 1k task
    start: .space 4000
    finish: .space 4000
    taskst : .space 4000
    tastend : .space 40000
.text
main: 
   
    li $v0, 4
    la $a0, astask
    syscall
   
    li $v0, 5
    syscall
    sw $v0, task

    la $s0, start 
    la $s1, finish            
    addi $t1,$t1,0 # new i =0
    lw $t2,scout  #number in loops 
    lw $t3, task  
    
insert:      
 # Ask to add new task and  add start // end
    li $v0,4
    la $a0,counting
    syscall
    
    li $v0,1
    move $a0,$t2
    syscall
    
    li $v0, 4
    la $a0, skip
    syscall
    
    li $v0,4
    la $a0,asstart
    syscall
    
#input start
    li $v0, 5
    syscall
    sw $v0, 0($s0)         
    addiu $s0, $s0, 4      
    
    li $v0,4
    la $a0,asend
    syscall
#input end
    li $v0,5
    syscall
    sw $v0,0($s1)
    addiu $s1,$s1,4
    
#end from input
    li $v0, 4
    la $a0, skip
    syscall
   
    
    addiu $t1, $t1, 1  #i++
    addi $t2,$t2,1     #scout++
     blt $t1, $t3, insert  #if $t1 < $t3 //i < task
#### End insert####
######################################## Start Counting ######################################################################

    la $s0, start  
    la $s1, finish  
    lw $s2, task  
    
    move $t0,$zero # set k
    move $t1, $zero # set i
    move $t2, $zero # set j
    move $t3,$zero # set t
    
##### Porlor $t5-$t9 can use all but after counts cannot use $t8-$t9
mainloop:
    bge $t1, $s2, print_count 
    move $t3, $t1  
    addi $t2, $t1, 1  

select_sort:
    bge $t2, $s2, switch_arr  
    
    #find finished[j]
    sll $t4, $t2, 2
    add $t4, $s1, $t4 
    lw $t5, 0($t4)  
    
    #find finished[t]
    sll $t6, $t3, 2
    add $t6, $s1, $t6 
    lw $t7, 0($t6)  

    # if finished[j] < finished[t], t = j
    blt $t5, $t7, update_t  
 
    addi $t2, $t2, 1  # j++
    j select_sort

update_t:
 
    move $t3, $t2  # t = j
    addi $t2, $t2, 1
    j select_sort

switch_arr:

    #get finish[i]
    sll $t4, $t1, 2
    add $t4, $s1, $t4  
    lw $t5, 0($t4)  

    #get finish[i]
    sll $t6, $t3, 2
    add $t6, $s1, $t6  
    lw $t7, 0($t6)  

    sw $t7, 0($t4)  # finish[i] = finish[t]
    sw $t5, 0($t6)  # finish[t] = finish[i]

     #get start[i]
    sll $t4, $t1, 2
    add $t4, $s0, $t4 
    lw $t5, 0($t4)  

    #get start[t]
    sll $t6, $t3, 2
    add $t6, $s0, $t6  
    lw $t7, 0($t6)  
    
    # start[i] = start[t]
    sw $t7, 0($t4) 
    # start[t] = start[i]
    sw $t5, 0($t6) 

    lw $t5, 0($t4)  # start[i]
    lw $t6, time  #call time to $t6

    bge $t5, $t6,counts # start[i] < time
    #else
    addi $t1, $t1, 1  # i++
    j mainloop

counts:
    la $t8, taskst  
    la $t9, tastend  
    
    lw $t4, count  
    addi $t4, $t4, 1 
    sw $t4, count  

    # update time
    sll $t4, $t1, 2
    add $t4, $s1, $t4 
    lw $t5, 0($t4)  
    sw $t5, time
   
   #call start[i]
    sll $t4, $t1, 2
    add $t4, $s0, $t4  
    lw $t5, 0($t4)  
    
    #call taskst[k]
    sll $t6, $t0, 2  
    add $t6, $t6, $t8
    sw $t5, 0($t6) #taskst[k] = start[i] 
 
    #call finish[k]
    sll $t4, $t1, 2
    add $t4, $s1, $t4  
    lw $t5, 0($t4)  
    
    #call taskend[k]
    sll $t6, $t0, 2  
    add $t6, $t9, $t6  
    sw $t5, 0($t6) #taskend[k] = finish[i] 
    
        
    addi $t0, $t0, 1  # k++
    addi $t1, $t1, 1  # i++
    j mainloop
   
############################### Prepare to print arr in ####################################
print_count:
    
    li $v0, 4
    la $a0,cc
    syscall
    
    lw $a0, count
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0,jtask
    syscall
      
    li $v0,4
    la $a0,skip
    syscall

    #load $s2 = count
    move $t0, $zero
    lw $s2, count 
    
print_arr:
  #if k > t
    addi $t1,$t0,1
    bge $t0, $s2, end_print
    sll $t4, $t0, 2
    
     li $v0,4
     la $a0,outtak
     syscall
     
      li $v0,1
      move $a0,$t1
      syscall
      
      li $v0,4
      la $a0,tab
      syscall 
    
    li $v0,4
    la $a0,asstart
    syscall
    
    #taskst[k]
    add $t6, $t8, $t4  
    lw $t5, 0($t6)  
    
    ############ print Start :
    li $v0, 1
    move $a0, $t5
    syscall  
  
    li $v0,4
    la $a0,tab
    syscall
    
    li $v0,4
    la $a0,asend
    syscall
    
    add $t6, $t9, $t4  # address of tastend[k]
    lw $t5, 0($t6)  # tastend[k]
    
    
    ##########  print end: 
    li $v0, 1
    move $a0, $t5
    syscall  
    
    li $v0,4
    la $a0,skip
    syscall
     
    addi $t0, $t0, 1  # k++
    j print_arr
    
end_print:
    li $v0, 10
    syscall
