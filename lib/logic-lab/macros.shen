(defmacro graphics-wrapper-macro
  [graphics [input+ Type [stinput]]] -> (if (= (arity tk-input) -1)
                                            [tk-input+ Type]   
                                            [input+ Type [stinput]]))
   
