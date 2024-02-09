
(load 'test/user.l)
(symbols 'entities 'pico)

#(post 'service '(  ("nm" . "serv11") ("desc" . "serv11 desc") ("duration" . "1") ("price" . "10") ("capacity" . "12") ("max_grp" . "4") ) '("ven1@eml.com" . "asdf"))

#anon tries to tag service
(test (401) (process  "post" (list (get (db 'nm '+Service "serv11") 'eid) NIL '((tags . tag1)))))

#user tries to tag service
(test (403) (process  "post" (get (db 'nm '+Service "serv11") 'eid) NIL '((tags . tag1)) '(user1@eml.com . asdf)))

#venue adds tag to service
(test (201 ("instance" ("service" 36 ("del") ((nm "text" (req)) (desc "text" (req)) (duration "number" (req)) (price "number" (req)) (capacity "number" (req)) (max_grp "number" NIL) (venue "text" (req)) (tags "instances" NIL))) (36 "serv11" "serv11 desc" 1 10 12 4 ("url" "/venue/26" "ven1" "venue desc 1") (("url" "/tag/52" NIL NIL))))) (process  "post" (get (db 'nm '+Service "serv11") 'eid) NIL '((tags . tag1)) '(ven1@eml.com . asdf)))

