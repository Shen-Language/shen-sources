(defprolog lived
   "Adam" 930 <--;
   "Seth" 912 <--;
   "Enos" 905 <--;
   "Ca-i'nan" 910 <--;
   "Mahal'aleel" 895 <--;
   "Jared" 962 <--;
   "Enoch" 365 <--;
   "Methu'selah" 969 <--;
   "Lamech" 777 <--;)

(defprolog begat
   "Adam" "Seth"  <--;
   "Seth" "Enos" <--;
   "Enos" "Ca-i'nan" <--;
   "Ca-i'nan" "Mahal'aleel" <--;
   "Mahal'aleel" "Jared" <--;
   "Jared" "Enoch" <--;
   "Enoch" "Methu'selah" <--;
   "Methu'selah" "Lamech" <--;)

(prolog? (findall Age (lived Person Age) Ages)
         (return (sum Ages)))

(defprolog total
           [] 0 <--;
           [X | Y] N <-- (total Y M) (is N (+ M X));)

