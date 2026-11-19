(package stlib (difference (mapcan (fn external)
                                   [list string maths vector symbol tuple file print])
                           [constructor end step])
     void)