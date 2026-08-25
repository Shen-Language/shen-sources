(package lkl (lkl-external-symbols)

(datatype def

  F : proper-symbol; Params : (list proper-symbol); Body : term;
  =============================================================
  [defun F Params Body] : def;) )
