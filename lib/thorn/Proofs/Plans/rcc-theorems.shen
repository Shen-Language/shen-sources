
(define rcc-theorems
  {--> (list prop)}
  -> [ \\ DC row
\\1
[all x [all y [all z [[[dc x y] & [ec y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [ntpp x z]]]]]]
\\2
[all x [all y [all z [[[dc x y] & [po y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [ntpp x z]]]]]]
\\3
[all x [all y [all z [[[dc x y] & [tpp y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [ntpp x z]]]]]]
\\4
[all x [all y [all z [[[dc x y] & [ntpp y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [ntpp x z]]]]]]
\\5
[all x [all y [all z [[[dc x y] & [tpp-1 y z]] => [dc x z]]]]] \\ THORN solvable 
\\6
[all x [all y [all z [[[dc x y] & [ntpp-1 y z]] => [dc x z]]]]] \\ THORN solvable 
\\7

[all x [all y [all z [[[dc x y] & [e= y z]] => [dc x z]]]]] \\ THORN solvable 

\\ EC row
\\8
[all x [all y [all z [[[ec x y] & [dc y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp-1 x z]] v [ntpp-1 x z]]]]]]
\\9
[all x [all y [all z [[[ec x y] & [ec y z]] => [[[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [tpp-1 x z]] v [e= x z]]]]]] 
\\10
[all x [all y [all z [[[ec x y] & [po y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [ntpp x z]]]]]]
\\11
[all x [all y [all z [[[ec x y] & [tpp y z]] => [[[[ec x z] v [po x z]] v [tpp x z]] v [ntpp x z]]]]]]
\\12
[all x [all y [all z [[[ec x y] & [ntpp y z]] => [[[po x z] v [tpp x z]] v [ntpp x z]]]]]]
\\13
[all x [all y [all z [[[ec x y] & [tpp-1 y z]] => [[dc x z] v [ec x z]]]]]] \\ THORN solvable
\\14
[all x [all y [all z [[[ec x y] & [ntpp-1 y z]] => [dc x z]]]]]
\\15
[all x [all y [all z [[[ec x y] & [e= y z]] => [ec x z]]]]]

\\ PO row
\\16
[all x [all y [all z [[[po x y] & [dc y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp-1 x z]] v [ntpp-1 x z]]]]]]
\\17
[all x [all y [all z [[[po x y] & [ec y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp-1 x z]] v [ntpp-1 x z]]]]]]
\\18
[all x [all y [all z [[[po x y] & [tpp y z]] => [[[po x z] v [tpp x z]] v [ntpp x z]]]]]]
\\19
[all x [all y [all z [[[po x y] & [ntpp y z]] => [[[po x z] v [tpp x z]] v [ntpp x z]]]]]]
\\20
[all x [all y [all z [[[po x y] & [tpp-1 y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp-1 x z]] v [ntpp-1 x z]]]]]]
\\21
[all x [all y [all z [[[po x y] & [ntpp-1 y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp-1 x z]] v [ntpp-1 x z]]]]]]
\\22
[all x [all y [all z [[[po x y] & [e= y z]] => [po x z]]]]] \\ THORN solvable

\\ TPP row
\\23
[all x [all y [all z [[[tpp x y] & [dc y z]] => [dc x z]]]]] \\ THORN solvable
\\24
[all x [all y [all z [[[tpp x y] & [ec y z]] => [[dc x z] v [ec x z]]]]]] \\ THORN solvable
\\25
[all x [all y [all z [[[tpp x y] & [po y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [ntpp x z]]]]]] \\ solved with scope
\\26
[all x [all y [all z [[[tpp x y] & [tpp y z]] => [[tpp x z] v [ntpp x z]]]]]]
\\27
[all x [all y [all z [[[tpp x y] & [ntpp y z]] => [ntpp x z]]]]] \\  no plan
\\28
[all x [all y [all z [[[tpp x y] & [tpp-1 y z]] => [[[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [tpp-1 x z]] v [e= x z]]]]]] \\ no plan
\\29
[all x [all y [all z [[[tpp x y] & [ntpp-1 y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp-1 x z]] v [ntpp-1 x z]]]]]]  \\ no plan
\\30
[all x [all y [all z [[[tpp x y] & [e= y z]] => [tpp x z]]]]]

\\ NTPP row
[all x [all y [all z [[[ntpp x y] & [dc y z]] => [dc x z]]]]] \\ THORN solvable
[all x [all y [all z [[[ntpp x y] & [ec y z]] => [dc x z]]]]]
[all x [all y [all z [[[ntpp x y] & [po y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [ntpp x z]]]]]]
[all x [all y [all z [[[ntpp x y] & [tpp y z]] => [ntpp x z]]]]]
[all x [all y [all z [[[ntpp x y] & [ntpp y z]] => [ntpp x z]]]]]
[all x [all y [all z [[[ntpp x y] & [tpp-1 y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp x z]] v [ntpp x z]]]]]]
[all x [all y [all z [[[ntpp x y] & [e= y z]] => [ntpp x z]]]]]

\\ TPP-1 row
[all x [all y [all z [[[tpp-1 x y] & [dc y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp-1 x z]] v [ntpp-1 x z]]]]]]
[all x [all y [all z [[[tpp-1 x y] & [ec y z]] => [[[[ec x z] v [po x z]] v [tpp-1 x z]] v [ntpp-1 x z]]]]]]
[all x [all y [all z [[[tpp-1 x y] & [po y z]] => [[[po x z] v [tpp-1 x z]] v [ntpp-1 x z]]]]]]
[all x [all y [all z [[[tpp-1 x y] & [tpp y z]] => [[[[po x z] v [tpp x z]] v [tpp-1 x z]] v [e= x z]]]]]]
[all x [all y [all z [[[tpp-1 x y] & [ntpp y z]] => [[[po x z] v [tpp x z]] v [ntpp x z]]]]]]
[all x [all y [all z [[[tpp-1 x y] & [tpp-1 y z]] => [[tpp-1 x z] v [ntpp-1 x z]]]]]]
[all x [all y [all z [[[tpp-1 x y] & [ntpp-1 y z]] => [ntpp-1 x z]]]]]
[all x [all y [all z [[[tpp-1 x y] & [e= y z]] => [tpp-1 x z]]]]]

\\ NTPPI row
[all x [all y [all z [[[ntpp-1 x y] & [dc y z]] => [[[[[dc x z] v [ec x z]] v [po x z]] v [tpp-1 x z]] v [ntpp-1 x z]]]]]]
[all x [all y [all z [[[ntpp-1 x y] & [ec y z]] => [[[po x z] v [tpp-1 x z]] v [ntpp-1 x z]]]]]]
[all x [all y [all z [[[ntpp-1 x y] & [po y z]] => [[[po x z] v [tpp-1 x z]] v [ntpp-1 x z]]]]]]
[all x [all y [all z [[[ntpp-1 x y] & [tpp y z]] => [[[po x z] v [tpp-1 x z]] v [ntpp-1 x z]]]]]]
[all x [all y [all z [[[ntpp-1 x y] & [ntpp y z]] => [[[[[[po x z] v [tpp x z]] v [ntpp x z]] v [tpp-1 x z]] v [ntpp-1 x z]] v [e= x z]]]]]]
[all x [all y [all z [[[ntpp-1 x y] & [tpp-1 y z]] => [ntpp-1 x z]]]]]
[all x [all y [all z [[[ntpp-1 x y] & [ntpp-1 y z]] => [ntpp-1 x z]]]]]
[all x [all y [all z [[[ntpp-1 x y] & [e= y z]] => [ntpp-1 x z]]]]]

\\ e= row
[all x [all y [all z [[[e= x y] & [dc y z]] => [dc x z]]]]]
[all x [all y [all z [[[e= x y] & [ec y z]] => [ec x z]]]]]
[all x [all y [all z [[[e= x y] & [po y z]] => [po x z]]]]]
[all x [all y [all z [[[e= x y] & [tpp y z]] => [tpp x z]]]]]
[all x [all y [all z [[[e= x y] & [ntpp y z]] => [ntpp x z]]]]]
[all x [all y [all z [[[e= x y] & [tpp-1 y z]] => [tpp-1 x z]]]]]
[all x [all y [all z [[[e= x y] & [ntpp-1 y z]] => [ntpp-1 x z]]]]]
[all x [all y [all z [[[e= x y] & [e= y z]] => [e= x z]]]]] ])