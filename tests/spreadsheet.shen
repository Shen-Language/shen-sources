(define assess-spreadsheet
  Spreadsheet -> (map (/. Row (assign-fixed-values Row Spreadsheet))
                      Spreadsheet))

(define assign-fixed-values
  [Index | Cells] Spreadsheet
  -> [Index | (map (/. Cell (assign-cell-value Cell Spreadsheet)) Cells)])

(define assign-cell-value
  [Attribute Value]  _ -> [Attribute Value] where (fixed-value? Value)
  [Attribute Value] Spreadsheet -> [Attribute (Value Spreadsheet)])

(define fixed-value?
  \* number?, symbol? and string? are system functions - see appendix A *\
  Value -> (or (number? Value) (or (symbol? Value) (string? Value))))

(define get'
  \* spreads the spreadsheet! *\
  Index Attribute Spreadsheet
  -> (get-row Index Attribute Spreadsheet Spreadsheet))

(define get-row
  \* looks for the right row using the index *\
  Index Attribute [[Index | Cells] | _] Spreadsheet
  -> (get-cell Attribute Cells Spreadsheet)
  Index Attribute [_ | Rows] Spreadsheet
  -> (get-row Index Attribute Rows Spreadsheet)
  Index _ _ _ -> (error "Index ~A not found" Index))

(define get-cell
  Attribute [[Attribute Value] | _] Spreadsheet
  -> (if (fixed-value? Value) Value (Value Spreadsheet))
  Attribute [_ | Cells] Spreadsheet
  -> (get-cell Attribute Cells Spreadsheet)
  Attribute _ _ -> (error "Attribute ~A not found" Attribute))
