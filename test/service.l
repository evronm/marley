
(symbols 'entities 'pico)

(load 'test/data.l)
(test '(c) (may  'c (db 'nm '+Venue 'ven1) '+Service)) #A Venue can create a service.
(test NIL (may 'c (db 'nm '+Venue 'user1) '+Service)) #But a User cannot.
(test '(u d) (may 'u (db 'nm '+Venue 'ven1) (db 'nm '+Service 'serv11))) #A venue can update and delete a service
(test NIL (may 'u (db 'nm '+Venue 'ven2) (db 'nm '+Service 'serv11)))
(test '(422 ((error) (desc "Input required") (nm "Not unique"))) (post 'service '(  ("nm" . "serv11") ("duration" . 1) ("price" . 10) ("capacity" . 12) ("max_grp" . 4)) '("ven1@eml.com" . "asdf")))
