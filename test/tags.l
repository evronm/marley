
(load 'test/user.l)
(symbols 'entities 'pico)

#(post 'service '(  ("nm" . "serv11") ("desc" . "serv11 desc") ("duration" . "1") ("price" . "10") ("capacity" . "12") ("max_grp" . "4") ) '("ven1@eml.com" . "asdf"))

#anon tries to tag service
(test (403) (process  "post" (db 'nm '+Service "serv11") NIL NIL '((tags . tag1))))
