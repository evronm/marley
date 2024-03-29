
(load 'test/user.l)
(symbols 'entities 'pico)

#(post 'service '(  ("nm" . "serv11") ("desc" . "serv11 desc") ("duration" . "1") ("price" . "10") ("capacity" . "12") ("max_grp" . "4") ) '("ven1@eml.com" . "asdf"))

#anon tries to tag service
(test (401) (process  "post" (list (get (db 'nm '+Service "serv11") 'eid) NIL '((tags . tag1)))))

#user tries to tag service
(test (403) (process  "post" (get (db 'nm '+Service "serv11") 'eid) NIL '((tags . tag1)) '(user1@eml.com . asdf)))

#venue sets tag on service
(test (201 ("instance" ("service" 36 ("del") ((nm "text" (req)) (desc "text" (req)) (duration "number" (req)) (price "number" (req)) (capacity "number" (req)) (max_grp "number" NIL) (tags "instances" (("options" ((nm "text")) ((52 tag1))))))) (36 "serv11" "serv11 desc" 1 10 12 4 (52)))) (process  "post" (get (db 'nm '+Service "serv11") 'eid) NIL '((tags . tag1)) '(ven1@eml.com . asdf)))

#venue replaces first tag with 2 new tags
(test (201 ("instance" ("service" 36 ("del") ((nm "text" (req)) (desc "text" (req)) (duration "number" (req)) (price "number" (req)) (capacity "number" (req)) (max_grp "number" NIL) (tags "instances" (("options" ((nm "text")) ((52 tag1) (53 tag2) (54 tag3))))))) (36 "serv11" "serv11 desc" 1 10 12 4 (54 53)))) (process  "post" (get (db 'nm '+Service "serv11") 'eid) NIL '((tags tag2 tag3)) '(ven1@eml.com . asdf)))


#total tag count is still 3
(test 3 (length (lsearch NIL '((nm +Tag)))))

#venue attempts to tag wine with different owner
(test (403) (process  "post" (get (db 'nm '+Service "serv11") 'eid) NIL '((tags tag1 tag2 tag3)) '(ven2@eml.com . asdf)))

#second venue reuses tag 
(test  (201 ("instance" ("service" 39 ("del") ((nm "text" (req)) (desc "text" (req)) (duration "number" (req)) (price "number" (req)) (capacity "number" (req)) (max_grp "number" NIL) (tags "instances" (("options" ((nm "text")) ((52 tag1) (53 tag2) (54 tag3))))))) (39 "serv21" "serv21 desc" 4 15 12 4 (54 53 52)))) (process  "post" (get (db 'nm '+Service "serv21") 'eid) NIL '((tags tag1 tag2 tag3)) '(ven2@eml.com . asdf)))

#tag count is still 3
(test 3 (length (lsearch NIL '((nm +Tag)))))

#venue 1 adds original tag back to service
( test (201 ("instance" ("service" 36 ("del") ((nm "text" (req)) (desc "text" (req)) (duration "number" (req)) (price "number" (req)) (capacity "number" (req)) (max_grp "number" NIL) (tags "instances" (("options" ((nm "text")) ((52 tag1) (53 tag2) (54 tag3))))))) (36 "serv11" "serv11 desc" 1 10 12 4 (52 54 53)))) (process  "post" (list (get (db 'nm '+Service "serv11") 'eid) 'tags 'add) NIL '((tags . tag1)) '(ven1@eml.com . asdf)))

#vendor creates new service with 2 tags
(test (201 ("instance" ("service" 56 ("del") ((nm "text" (req)) (desc "text" (req)) (duration "number" (req)) (price "number" (req)) (capacity "number" (req)) (max_grp "number" NIL) (tags "instances" (("options" ((nm "text")) ((52 tag1) (53 tag2) (54 tag3) (55 tag4))))))) (56 "tagtest" "tag test" 1 10 12 4 (55 52)))) (process "post" '("service" "new") NIL '(("nm" . "tagtest") ("desc" . "tag test") ("duration" . "1") ("price" . "10") ("capacity" . "12") ("max_grp" . "4") (tags tag1 tag4)) '(ven3@eml.com . asdf)) )

#we reused one tag, so tag count should now be 4
(test 4 (length (lsearch NIL '((nm +Tag)))))

