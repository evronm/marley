
(load 'test/data.l)
(symbols 'entities 'pico)

#deletion permission tests
(setq uid (get (db 'nm '+User "user20") 'eid))
(test '(403 ((error) (NIL "Forbidden"))) (process "post" '("user") NIL (list "del" uid) ))
(test '(204 ("mesg" "Success" "deleted successfully")) (process "post" '("user") NIL (list "del" uid) '("user20@eml.com" "asdf")))
(test 19 (length (lsearch Nil '((nm +User)))))

#anon requests new user form
(test (200 ("instance" ("user" "new" ("new") ((eml "text" (req)) (pw "password" (req)) (addr "text" NIL) (nm "text" (req)))))) (process "get" '("user" "new")))

#anon requests new venue form
(test (200 ("instance" ("venue" "new" ("new") ((eml "text" (req)) (pw "password" (req)) (addr "text" NIL) (nm "text" (req)) (desc "text" (req))))))
  (process "get" '("venue" "new")))

#anon requests new provider form
(test (200 ("instance" ("provider" "new" ("new") ((eml "text" (req)) (pw "password" (req)) (addr "text" NIL) (nm "text" (req)) (desc "text" (req))))))
  (process "get" '("provider" "new")))

#anon attempts to create empty user
(test (422 ((error) (nm "Input required") (pw "Input required") (eml "Input required"))) (process "post" '("user")))

#anon attempts to create user with missing data
(test (422 ((error) (nm "Input required") (pw "Input required"))) (process "post" '("user") NIL '((eml . "adasdf@eml.com"))))

#anon creates new user
(test (201 @N) (process "post" '("user") NIL '((eml . "adasdf@eml.com") (nm . "asdfa") (pw . "asdf"))))

#duplicate email
(test (422 ((error) (eml "Not unique"))) (process "post" '("user") NIL '((eml . "adasdf@eml.com") (nm . "asdfa") (pw . "asdf"))))


#anon searches for venues whose name starts with "ven1"
(test  (200 ("instances" ("venue" "new" ("ro") ((nm "text" (ro req)) (desc "text" (ro req)) (providers "instances" (ro)) (services "instances" (ro)))) ((26 "ven1" "venue desc 1" NIL (("url" "/service/38" "serv13" "serv13 desc") ("url" "/service/37" "serv12" "serv12 desc") ("url" "/service/36" "serv11" "serv11 desc"))) (35 "ven10" "venue desc 10" NIL NIL)))) (process "get" '("venue") '((nm . ven1))))

#anon browses all providers
(test (200 ("instances" ("provider" "new" ("ro") ((nm "text" (ro req)) (desc "text" (ro req)) (venues "instances" (ro)))) ((21 "prov1" "prov desc 1" NIL) (22 "prov2" "prov desc 2" NIL) (23 "prov3" "prov desc 3" NIL) (24 "prov4" "prov desc 4" NIL) (25 "prov5" "prov desc 5" NIL)))) (process "get" '("provider")))

#anon browses services from ven2
(test (200 ("instances" ("service" "new" ("ro") ((nm "text" (ro req)) (duration "number" (ro req)) (price "number" (ro req)) (capacity "number" (ro req)) (max_grp "number" (ro)) (venue "text" (ro req)) (itins "instances" (ro)))) ((39 "serv21" 4 15 12 4 ("url" "/venue/27" "ven2" "venue desc 2") NIL) (40 "serv22" 5 16 13 5 ("url" "/venue/27" "ven2" "venue desc 2") NIL)))) (process "get" '("service") (list (cons "venue"  (get (db 'nm '+Venue "ven2") 'eid)))))

#anon requests new itinerary form
(test (401) (process "get" '("Itinerary" "new")))

#user requests new itinerary form
(test (200 ("instance" ("itinerary" "new" ("new") ((start_addr "text" (req)) (dt "date" (req)) (tm "time" (req)) (ppl "number" (req)))))) (process "get" '("Itinerary" "new") NIL NIL '("user1@eml.com" "asdf")))

#user tries to create an itenerary with no data
(test (422 ((error) (ppl "Input required") (tm "Input required") (dt "Input required") (start_addr "Input required"))) (process "post" '("itinerary" "new") NIL NIL '("user1@eml.com" . "asdf")))

#user tries to create itinerary with incomplete data
(test (422 ((error) (tm "Input required") (dt "Input required"))) (process "post" '("itinerary" "new") NIL '((ppl . 2) (start_addr . "asdf asdf")) '("user1@eml.com" . "asdf")))

#user creates itinerary successfully; grab ID to add services in next test
(match '(@Code ("instance" ("itinerary" @Itin1 @Rest))) (process "post" '("itinerary" "new") NIL '((ppl . 2) (start_addr . "asdf asdf") (dt . "2024-01-03") (tm . "11:30")) '("user1@eml.com" . "asdf")))
(test 201 @Code)

#user adds service to existing itinerary
(test (201 @N) (process "post" (list "itinerary" (car @Itin1)) NIL (list (list "services" (get (db 'nm '+Service "serv11") 'eid))) '("user1@eml.com" . "asdf")))
(test '(@N) (get (db 'eid '+Itinerary (car @Itin1)) 'services))

#user adds 2 more services
(test (201 @N) (process "post" (list "itinerary" (car @Itin1)) NIL (list (list "services" (get (db 'nm '+Service "serv22") 'eid) (get (db 'nm '+Service "serv31") 'eid))) '("user1@eml.com" . "asdf")))
(test '(@N @N @N) (get (db 'eid '+Itinerary (car @Itin1)) 'services))

#user creates another itinerary
(match '(@Code ("instance" ("itinerary" @Itin2 @Rest))) (process "post" '("itinerary" "new") NIL '((ppl . 4) (start_addr . "xxxxxx") (dt . "2024-02-08") (tm . "12:20")) '("user1@eml.com" . "asdf")))
(test 201 @Code)

#user adds 2 services to new itinerary
(test (201 @N) (process "post" (list "itinerary" (car @Itin2)) NIL (list (list "services" (get (db 'nm '+Service "serv13") 'eid) (get (db 'nm '+Service "serv21") 'eid))) '("user1@eml.com" . "asdf")))
(test '(@N @N) (get (db 'eid '+Itinerary (car @Itin2)) 'services))

#user lists itineraries
(test (200 ("instances" ("itinerary" "new" ("ro") ((start_addr "text" (ro req)) (dt "date" (ro req)) (tm "time" (ro req)) (ppl "number" (ro req)) (services "instances" (ro)) (provider "text" (ro)))) ((50 "xxxxxx" 739230 44400 4 (("url" "/service/39" "serv21" "serv21 desc") ("url" "/service/38" "serv13" "serv13 desc")) NIL) (49 "asdf asdf" 739194 41400 2 (("url" "/service/41" "serv31" "serv31 desc") ("url" "/service/40" "serv22" "serv22 desc") ("url" "/service/36" "serv11" "serv11 desc")) NIL)))) (process "get" '("itins") NIL NIL '("user1@eml.com" "asdf") ))

#user3 creates itinerary
(match '(@Code ("instance" ("itinerary" @Itin3 @Rest))) (process "post" '("itinerary" "new") NIL '((ppl . 2) (start_addr . "asdf asdf") (dt . "2024-01-03") (tm . "11:30")) '("user3@eml.com" . "asdf")))
(test 201 @Code)

#User 1 attempts to add services to user 3's itinerary
(test (403) (process "post" (list "itinerary" (car @Itin3)) NIL (list (list "services" (get (db 'nm '+Service "serv13") 'eid) (get (db 'nm '+Service "serv21") 'eid))) '("user1@eml.com" . "asdf")))

#user3 adds 3 services to itinerary just created
(test (201 @N) (process "post" (list "itinerary" (car @Itin3)) NIL (list (list "services" (get (db 'nm '+Service "serv53") 'eid) (get (db 'nm '+Service "serv21") 'eid) (get (db 'nm '+Service "serv31") 'eid))) '("user3@eml.com" . "asdf")))
(test '(@N @N @N) (get (db 'eid '+Itinerary (car @Itin3)) 'services))


#user views second itinerary
(test (200 ("instance" ("itinerary" 50 ("del" "ro") ((start_addr "text" (req)) (dt "date" (req)) (tm "time" (req)) (ppl "number" (req)) (services "instances" NIL) (provider "text" NIL))) (50 "xxxxxx" 739230 44400 4 (("url" "/service/39" "serv21" "serv21 desc") ("url" "/service/38" "serv13" "serv13 desc")) NIL))) (process "get" (list "itinerary" (car @Itin2)) NIL NIL '("user1@eml.com" "asdf")))

#user views first itinerary
(test (200 ("instance" ("itinerary" 49 ("del" "ro") ((start_addr "text" (req)) (dt "date" (req)) (tm "time" (req)) (ppl "number" (req)) (services "instances" NIL) (provider "text" NIL))) (49 "asdf asdf" 739194 41400 2 (("url" "/service/41" "serv31" "serv31 desc") ("url" "/service/40" "serv22" "serv22 desc") ("url" "/service/36" "serv11" "serv11 desc")) NIL))) (process "get" (list "itinerary" (car @Itin1)) NIL NIL '("user1@eml.com" "asdf")))

#user 2 tries to look at user1's itinerary
(test (403) (process "get" (list "itinerary" (car @Itin2)) NIL NIL '("user2@eml.com" "asdf")))


