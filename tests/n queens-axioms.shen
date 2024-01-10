(all V13514 : number
 (
  (n-queens V13514) =
  (n-queens.n-queens-loop V13514
   (n-queens.initialise V13514))))

(
 (n-queens.initialise 0) =
 ())

(all V13516 : number
 (
  (~
   (0 = V13516)) =>
  (
   (n-queens.initialise V13516) =
   (cons 1
    (n-queens.initialise
     (- V13516 1))))))

(all V13523 : number
 (all V13524 :
  (list number)
  (
   (n-queens.all_Ns? V13523 V13524) =>
   (
    (n-queens.n-queens-loop V13523 V13524) =
    ()))))

(all V13523 : number
 (all V13524 :
  (list number)
  (
   (
    (~
     (n-queens.all_Ns? V13523 V13524)) &
    (
     (n-queens.ok_row? V13524) &
     (n-queens.ok_diag? V13524))) =>
   (
    (n-queens.n-queens-loop V13523 V13524) =
    (cons V13524
     (n-queens.n-queens-loop V13523
      (n-queens.next_n V13523 V13524)))))))

(all V13523 : number
 (all V13524 :
  (list number)
  (
   (
    (~
     (n-queens.all_Ns? V13523 V13524)) &
    (
     (~
      (n-queens.ok_row? V13524)) v
     (~
      (n-queens.ok_diag? V13524)))) =>
   (
    (n-queens.n-queens-loop V13523 V13524) =
    (n-queens.n-queens-loop V13523
     (n-queens.next_n V13523 V13524))))))

(all V13559 : number
 (
  (n-queens.all_Ns? V13559
   ()) = true))

(all V13560 :
 (list number)
 (
  (
   (~
    (
     () = V13560)) &
   (cons? V13560)) =>
  (
   (n-queens.all_Ns?
    (hd V13560) V13560) =
   (n-queens.all_Ns?
    (hd V13560)
    (tl V13560)))))

(all V13559 : number
 (all V13560 :
  (list number)
  (
   (
    (~
     (
      () = V13560)) &
    (
     (~
      (cons? V13560)) v
     (~
      (V13559 =
       (hd V13560))))) =>
   (
    (n-queens.all_Ns? V13559 V13560) = false))))

(all V13580 :
 (list number)
 (
  (cons? V13580) =>
  (
   (n-queens.next_n
    (hd V13580) V13580) =
   (cons 1
    (n-queens.next_n
     (hd V13580)
     (tl V13580))))))

(all V13579 : number
 (all V13580 :
  (list number)
  (
   (
    (
     (~
      (cons? V13580)) v
     (~
      (V13579 =
       (hd V13580)))) &
    (cons? V13580)) =>
   (
    (n-queens.next_n V13579 V13580) =
    (cons
     (+ 1
      (hd V13580))
     (tl V13580))))))

(all V13579 : number
 (all V13580 :
  (list number)
  (
   (
    (
     (~
      (cons? V13580)) v
     (~
      (V13579 =
       (hd V13580)))) &
    (~
     (cons? V13580))) =>
   (
    (n-queens.next_n V13579 V13580) =
    (shen.f-error n-queens.next_n)))))

(
 (n-queens.ok_row?
  ()) = true)

(all V13595 :
 (list number)
 (
  (
   (~
    (
     () = V13595)) &
   (
    (cons? V13595) &
    (element?
     (hd V13595)
     (tl V13595)))) =>
  (
   (n-queens.ok_row? V13595) = false)))

(all V13595 :
 (list number)
 (
  (
   (~
    (
     () = V13595)) &
   (
    (
     (~
      (cons? V13595)) v
     (~
      (element?
       (hd V13595)
       (tl V13595)))) &
    (cons? V13595))) =>
  (
   (n-queens.ok_row? V13595) =
   (n-queens.ok_row?
    (tl V13595)))))

(all V13595 :
 (list number)
 (
  (
   (~
    (
     () = V13595)) &
   (
    (
     (~
      (cons? V13595)) v
     (~
      (element?
       (hd V13595)
       (tl V13595)))) &
    (~
     (cons? V13595)))) =>
  (
   (n-queens.ok_row? V13595) =
   (shen.f-error n-queens.ok_row?))))

(
 (n-queens.ok_diag?
  ()) = true)

(all V13598 :
 (list number)
 (
  (
   (~
    (
     () = V13598)) &
   (cons? V13598)) =>
  (
   (n-queens.ok_diag? V13598) =
   (and
    (n-queens.ok_diag_N?
     (+
      (hd V13598) 1)
     (-
      (hd V13598) 1)
     (tl V13598))
    (n-queens.ok_diag?
     (tl V13598))))))

(all V13598 :
 (list number)
 (
  (
   (~
    (
     () = V13598)) &
   (~
    (cons? V13598))) =>
  (
   (n-queens.ok_diag? V13598) =
   (shen.f-error n-queens.ok_diag?))))

(all V13651 : number
 (all V13652 : number
  (
   (n-queens.ok_diag_N? V13651 V13652
    ()) = true)))

(all V13652 : number
 (all V13653 :
  (list number)
  (
   (
    (~
     (
      () = V13653)) &
    (cons? V13653)) =>
   (
    (n-queens.ok_diag_N?
     (hd V13653) V13652 V13653) = false))))

(all V13651 : number
 (all V13653 :
  (list number)
  (
   (
    (~
     (
      () = V13653)) &
    (
     (
      (~
       (cons? V13653)) v
      (~
       (V13651 =
        (hd V13653)))) &
     (cons? V13653))) =>
   (
    (n-queens.ok_diag_N? V13651
     (hd V13653) V13653) = false))))

(all V13651 : number
 (all V13652 : number
  (all V13653 :
   (list number)
   (
    (
     (~
      (
       () = V13653)) &
     (
      (
       (~
        (cons? V13653)) v
       (~
        (V13651 =
         (hd V13653)))) &
      (
       (
        (~
         (cons? V13653)) v
        (~
         (V13652 =
          (hd V13653)))) &
       (cons? V13653)))) =>
    (
     (n-queens.ok_diag_N? V13651 V13652 V13653) =
     (n-queens.ok_diag_N?
      (+ 1 V13651)
      (- V13652 1)
      (tl V13653)))))))

(all V13651 : number
 (all V13652 : number
  (all V13653 :
   (list number)
   (
    (
     (~
      (
       () = V13653)) &
     (
      (
       (~
        (cons? V13653)) v
       (~
        (V13651 =
         (hd V13653)))) &
      (
       (
        (~
         (cons? V13653)) v
        (~
         (V13652 =
          (hd V13653)))) &
       (~
        (cons? V13653))))) =>
    (
     (n-queens.ok_diag_N? V13651 V13652 V13653) =
     (shen.f-error n-queens.ok_diag_N?))))))

