\*
 Copyright (c) 2011, Justin Grant <justin at imagine27 dot com>
 All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 Redistributions of source code must retain the above copyright notice, this list
 of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this
 list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 Neither the name of the <ORGANIZATION> nor the names of its contributors may be
 used to endorse or promote products derived from this software without specific
 prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*\

(datatype tree-node

  Key : number; Val : B;
  ======================
  [Key Val] : tree-node;)

(datatype color

  if (element? Color [red black])
  _______________________________
  Color : color;)

(datatype tree

  if (empty? Tree)
  ________________
  Tree : tree;

  Color : color; LTree : tree; TreeNode : tree-node; RTree : tree;
  ================================================================
  [Color LTree TreeNode RTree] : tree;)

(define node-key
  {tree-node --> number}
  [Key Val] -> Key)

(define make-tree-black
  {tree --> tree}
  [Color A X B] -> [black A X B])

(define member
  {tree-node --> tree --> boolean}
  X [] -> false
  X [Color A Y B] -> (cases (< (node-key X) (node-key Y)) (member X A)
                            (< (node-key Y) (node-key X)) (member X B)
                            true true))

(define balance
  {tree --> tree}
  [black [red [red A X B] Y C] Z D] -> [red [black A X B] Y [black C Z D]]
  [black [red A X [red B Y C]] Z D] -> [red [black A X B] Y [black C Z D]]
  [black A X [red [red B Y C] Z D]] -> [red [black A X B] Y [black C Z D]]
  [black A X [red B Y [red C Z D]]] -> [red [black A X B] Y [black C Z D]]
  S -> S)

(define insert-
  {tree-node --> tree --> tree}
  X [] -> [red [] X []]
  X [Color A Y B]
  -> (cases (< (node-key X) (node-key Y)) (balance [Color (insert- X A) Y B])
            (< (node-key Y) (node-key X)) (balance [Color A Y (insert- X B)])
            true [Color A Y B]))

(define insert
  {tree-node --> tree --> tree}
  X S -> (make-tree-black (insert- X S)))
