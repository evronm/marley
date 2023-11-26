(call 'rm 'DB)
(load 'testapp.l)


(de post @
  (process "post" (list (next) "new") NIL (next) (next)  ))

(symbols 'entities 'pico)
(for N 20
  (process "post" '("user" "new") NIL (list (cons "eml"  (pack "user" N "@eml.com")) (cons "pw" "asdf") (cons "addr"  (pack "user" N "address")) (cons "nm" (pack "user" N) ))))

(for N 5
  (process "post" '("provider" "new") NIL (list (cons "eml"  (pack "prov" N "@eml.com")) (cons "pw" "asdf") (cons "addr"  (pack "prov" N "address")) (cons "nm" (pack "prov" N) ) (cons "desc" (pack "prov desc " N) ))))

(for N 10
  (process "post" '("venue" "new") NIL (list (cons "eml"  (pack "ven" N "@eml.com")) (cons "pw" "asdf") (cons "addr"  (pack "ven" N "address")) (cons "nm" (pack "ven" N) ) (cons "desc" (pack "venue desc " N) ))))



(post 'service '(  ("nm" . "serv11") ("desc" . "serv11 desc") ("duration" . 1) ("price" . 10) ("capacity" . 12) ("max_grp" . 4)) '("ven1@eml.com" . "asdf"))
(post 'service '(  ("nm" . "serv12") ("desc" . "serv12 desc") ("duration" . 2) ("price" . 20) ("capacity" . 13) ("max_grp" . 5)) '("ven1@eml.com" . "asdf"))
(post 'service '(  ("nm" . "serv13") ("desc" . "serv13 desc") ("duration" . 3) ("price" . 30) ("capacity" . 14) ("max_grp" . 6)) '("ven1@eml.com" . "asdf"))

(post 'service '(  ("nm" . "serv21") ("desc" . "serv21 desc") ("duration" . 4) ("price" . 15) ("capacity" . 12) ("max_grp" . 4)) '("ven2@eml.com" . "asdf"))
(post 'service '(  ("nm" . "serv22") ("desc" . "serv22 desc") ("duration" . 5) ("price" . 16) ("capacity" . 13) ("max_grp" . 5)) '("ven2@eml.com" . "asdf"))

(post 'service '(  ("nm" . "serv31") ("desc" . "serv31 desc") ("duration" . 6) ("price" . 17) ("capacity" . 14) ("max_grp" . 6)) '("ven3@eml.com" . "asdf"))


(post 'service '(  ("nm" . "serv41") ("desc" . "serv41 desc") ("duration" . 6) ("price" . 17) ("capacity" . 14) ("max_grp" . 6)) '("ven4@eml.com" . "asdf"))
(post 'service '(  ("nm" . "serv42") ("desc" . "serv42 desc") ("duration" . 6) ("price" . 17) ("capacity" . 14) ("max_grp" . 6)) '("ven4@eml.com" . "asdf"))


(post 'service '(  ("nm" . "serv51") ("desc" . "serv51 desc") ("duration" . 6) ("price" . 17) ("capacity" . 14) ("max_grp" . 6)) '("ven4@eml.com" . "asdf"))
(post 'service '(  ("nm" . "serv52") ("desc" . "serv52 desc") ("duration" . 6) ("price" . 17) ("capacity" . 14) ("max_grp" . 6)) '("ven4@eml.com" . "asdf"))
(post 'service '(  ("nm" . "serv53") ("desc" . "serv53 desc") ("duration" . 6) ("price" . 17) ("capacity" . 14) ("max_grp" . 6)) '("ven4@eml.com" . "asdf"))
(post 'service '(  ("nm" . "serv54") ("desc" . "serv54 desc") ("duration" . 6) ("price" . 17) ("capacity" . 14) ("max_grp" . 6)) '("ven4@eml.com" . "asdf"))

(test 20 (length (lsearch NIL '((nm +User)))))
(test 10 (length (lsearch NIL '((nm +Venue)))))
(test 5 (length (lsearch NIL '((nm +Provider)))))
(test 12 (length (lsearch NIL '((nm +Service)))))
(test 11 (length (list> '+User NIL '((nm . user1)))))
(test 1 (length (list> '+User NIL '((nm . user9)))))






