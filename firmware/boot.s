        # Simple bootstrap.
        
        # Round robin, listen to incoming data and forwarding to opposite link
        #
        # Numbering is N:0x00, E:0x10, S:0x20, W: 0x30
        EQU     LINK_BASE,       0x00
        EQU     DATA_OFFSET,     0x00        
        EQU     STATUS_OFFSET,   0x01
        EQU     DOR_MASK,        0x02
        EQU     DIR_MASK,        0x01        

        ORG   0x0000

        # r0 has source link base
        # r1 will be destination link base = (source + 0x20) MOD 0x40
        mov     r0, r0, LINK_BASE
        mov     r1, r0, LINK_BASE
        add     r1, r0, 0x20
        and     r1, r0, 0x3F        
LOOP:        
        in      r2, r0, STATUS_OFFSET
        and     r2, r0, DIR_MASK
        z.mov   pc, r0, NEXT_PAIR
        in      r2, r1, STATUS_OFFSET
        and     r2, r0, DOR_MASK
        z.mov   pc, r0, NEXT_PAIR
        in      r2, r0, DATA_OFFSET 
        out     r2, r1, DATA_OFFSET

NEXT_PAIR:      
        # Next pair modulus
        add     r1, r0, 0x10
        and     r1, r0, 0x3F
        add     r2, r0, 0x10
        and     r2, r0, 0x3F
        
        mov     pc, r0, LOOP
DONE:
        halt       r0,r0,0x321
