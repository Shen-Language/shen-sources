(thorn.defaults)
(thorn.wipe-kb)

(<-kb [[p => q] <=> [[~ q] => [~ p]]])  

(<-kb [[~ [~ p]] => p])  

(<-kb [[~ [p => q]] => [q => p]])  

(<-kb [[[~ p] => q] <=> [[~ q] => p]])   

(<-kb [[[p v q] => [p v r]] => [p v [q => r]]])

(<-kb [p v [~ p]])

(<-kb [p v [~ [~ [~ p]]]])

(<-kb [[[p => q] => p] => p] )

(<-kb [[[p v q] & [[[~ p] v q] & [p v [~ q]]]] => [~ [[~ p] v [~ q]]]])  

(<-kb [[[q => r] & [[r => [p & q]] & [p => [q v r]]]] => [p <=> q]])      

\\ (<-kb [[[p <=> q] <=> r] <=> [p <=> [q <=> r]]])  blows SBCL stack

(<-kb [[p v [q & r]] <=> [[p v q] & [p v r]]])   

(<-kb [[p <=> q] <=> [[q v [~ p]] & [[~ q] v p]]])

(<-kb [[p => q] => [q v [~ q]]])

(<-kb [[p => q] v [q => p]])

(<-kb [[[p & [q => r]] => s] <=> [[[~ p] v [q v s]] & [[~ p] v [[~ r] v s]]]])


   
    
            