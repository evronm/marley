
(load 'test/data.l)
(symbols 'entities 'pico)

#deletion permission tests
(setq uid (get (db 'nm '+User "user20") 'eid))
(test '(401) (process "post" (list uid) NIL (list (cons "_method" "del") )))
(test '(204 ("mesg" "Success" "deleted successfully")) (process "post" (list uid) NIL (list (cons "_method" "del")) '("user20@eml.com" "asdf")))
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
(test (422 ((error) (nm "Input required") (pw "Input required") (eml "Input required"))) (process "post" '("user" "new")))

#anon attempts to create user with missing data
(test (422 ((error) (nm "Input required") (pw "Input required"))) (process "post" '("user" "new") NIL '((eml . "adasdf@eml.com"))))

#anon creates new user
(test (201 @N) (process "post" '("user" "new") NIL '((eml . "adasdf@eml.com") (nm . "asdfa") (pw . "asdf"))))

#duplicate email
(test (422 ((error) (eml "Not unique"))) (process "post" '("user" "new") NIL '((eml . "adasdf@eml.com") (nm . "asdfa") (pw . "asdf"))))


#anon searches for venues whose name starts with "ven1"
(test (200 ("instances" ("venue" "new" NIL ((nm "text" NIL) (desc "text" NIL) (providers "instances" NIL) (services "instances" NIL))) ((26 "ven1" "venue desc 1" NIL (("url" "/38" "serv13" "serv13 desc") ("url" "/37" "serv12" "serv12 desc") ("url" "/36" "serv11" "serv11 desc"))) (35 "ven10" "venue desc 10" NIL NIL))))  (process "get" '("venue") '((nm . ven1))))

#anon browses all providers
(test (200 ("instances" ("provider" "new" NIL ((nm "text" NIL) (desc "text" NIL) (venues "instances" NIL))) ((21 "prov1" "prov desc 1" NIL) (22 "prov2" "prov desc 2" NIL) (23 "prov3" "prov desc 3" NIL) (24 "prov4" "prov desc 4" NIL) (25 "prov5" "prov desc 5" NIL)))) (process "get" '("provider")))

#anon browses services from ven2
(test (200 ("instances" ("service" "new" ("ro") ((nm "text" NIL) (duration "number" NIL) (price "number" NIL) (capacity "number" NIL) (max_grp "number" NIL) (venue "text" NIL) (itins "instances" NIL) (tags "instances" NIL))) ((39 "serv21" 4 15 12 4 ("url" "/27" "ven2" "venue desc 2") NIL NIL) (40 "serv22" 5 16 13 5 ("url" "/27" "ven2" "venue desc 2") NIL NIL)))) (process "get" '("service") (list (cons "venue"  (get (db 'nm '+Venue "ven2") 'eid)))))

#anon requests new itinerary form
(test (401) (process "get" '("Itinerary" "new")))

#user requests new itinerary form
(test (200 ("instance" ("itinerary" "new" ("new") ((start_addr "text" (req)) (dt "date" (req)) (tm "time" (req)) (ppl "number" (req)))))) (process "get" '("Itinerary" "new") NIL NIL '("user1@eml.com" "asdf")))

#user tries to create an itenerary with no data
(test (422 ((error) (ppl "Input required") (tm "Input required") (dt "Input required") (start_addr "Input required"))) (process "post" '("itinerary" "new") NIL NIL '("user1@eml.com" . "asdf")))

#user tries to create itinerary with incomplete data
(test (422 ((error) (tm "Input required") (dt "Input required"))) (process "post" '("itinerary" "new") NIL '((ppl . "2") (start_addr . "asdf asdf")) '("user1@eml.com" . "asdf")))

#user creates itinerary successfully; grab ID to add services in next test
(match '(201 ("instance" ("itinerary" @Itin1 @Rest))) (process "post" '("itinerary" "new") NIL '((ppl . "2") (start_addr . "asdf asdf") (dt . "2024-01-03") (tm . "11:30")) '("user1@eml.com" . "asdf")))

#user adds service to existing itinerary
(test (201 @N) (process "post" (list (car @Itin1) 'services 'add) NIL (list (list "services" (get (db 'nm '+Service "serv11") 'eid))) '("user1@eml.com" . "asdf")))
(test '(@N) (get (db 'eid '+Itinerary (car @Itin1)) 'services))

#user attempts to add non-services to service
(test (422 ((error) (2 " is the wrong type"))) (process "post" (list (car @Itin1) 'services 'add) NIL (list (list "services" (get (db 'nm '+User "user2") 'eid))) '("user1@eml.com" . "asdf")))

#user adds 2 more services
(test (201 @N) (process "post" (list (car @Itin1) 'services 'add) NIL (list (list "services" (get (db 'nm '+Service "serv22") 'eid) (get (db 'nm '+Service "serv31") 'eid))) '("user1@eml.com" . "asdf")))
(test '(@N @N @N) (get (db 'eid '+Itinerary (car @Itin1)) 'services))

#user creates another itinerary
(match '(@Code ("instance" ("itinerary" @Itin2 @Rest))) (process "post" '("itinerary" "new") NIL '((ppl . "4") (start_addr . "xxxxxx") (dt . "2024-02-08") (tm . "12:20")) '("user1@eml.com" . "asdf")))
(test 201 @Code)

#user adds 2 services to new itinerary
(test (201 @N) (process "post" (list (car @Itin2) 'services 'add) NIL (list (list "services" (get (db 'nm '+Service "serv13") 'eid) (get (db 'nm '+Service "serv21") 'eid))) '("user1@eml.com" . "asdf")))
(test '(@N @N) (get (db 'eid '+Itinerary (car @Itin2)) 'services))

#user lists itineraries
(test (200 ("instances" ("itinerary" "new" NIL ((start_addr "text" NIL) (dt "date" NIL) (tm "time" NIL) (ppl "number" NIL) (services "instances" NIL) (provider "text" NIL))) ((50 "xxxxxx" 739230 44400 4 (("url" "/39" "serv21" "serv21 desc") ("url" "/38" "serv13" "serv13 desc")) NIL) (49 "asdf asdf" 739194 41400 2 (("url" "/41" "serv31" "serv31 desc") ("url" "/40" "serv22" "serv22 desc") ("url" "/36" "serv11" "serv11 desc")) NIL)))) (process "get" '("itins") NIL NIL '("user1@eml.com" "asdf") ))

#user3 creates itinerary
(match '(@Code ("instance" ("itinerary" @Itin3 @Rest))) (process "post" '("itinerary" "new") NIL '((ppl . "2") (start_addr . "asdf asdf") (dt . "2024-01-03") (tm . "11:30")) '("user3@eml.com" . "asdf")))
(test 201 @Code)

#User 1 attempts to add services to user 3's itinerary
(test (403) (process "post" (list (car @Itin3) 'services 'add) NIL (list (list "services" (get (db 'nm '+Service "serv13") 'eid) (get (db 'nm '+Service "serv21") 'eid))) '("user1@eml.com" . "asdf")))

#user3 adds 3 services to itinerary just created
(test (201 @N) (process "post" (list (car @Itin3) 'services 'add) NIL (list (list "services" (get (db 'nm '+Service "serv53") 'eid) (get (db 'nm '+Service "serv21") 'eid) (get (db 'nm '+Service "serv31") 'eid))) '("user3@eml.com" . "asdf")))
(test '(@N @N @N) (get (db 'eid '+Itinerary (car @Itin3)) 'services))


#user views second itinerary
(test (200 ("instance" ("itinerary" 50 ("del") ((start_addr "text" (req)) (dt "date" (req)) (tm "time" (req)) (ppl "number" (req)) (services "instances" (("options" ((nm "text") (desc "text")) ((36 "serv11" "serv11 desc") (37 "serv12" "serv12 desc") (38 "serv13" "serv13 desc") (39 "serv21" "serv21 desc") (40 "serv22" "serv22 desc") (41 "serv31" "serv31 desc") (42 "serv41" "serv41 desc") (43 "serv42" "serv42 desc") (44 "serv51" "serv51 desc") (45 "serv52" "serv52 desc") (46 "serv53" "serv53 desc") (47 "serv54" "serv54 desc"))))) (provider "text" NIL))) (50 "xxxxxx" 739230 44400 4 (39 38) NIL))) (process "get" (list (car @Itin2)) NIL NIL '("user1@eml.com" "asdf")))

#user views first itinerary
(test (200 ("instance" ("itinerary" 49 ("del") ((start_addr "text" (req)) (dt "date" (req)) (tm "time" (req)) (ppl "number" (req)) (services "instances" (("options" ((nm "text") (desc "text")) ((36 "serv11" "serv11 desc") (37 "serv12" "serv12 desc") (38 "serv13" "serv13 desc") (39 "serv21" "serv21 desc") (40 "serv22" "serv22 desc") (41 "serv31" "serv31 desc") (42 "serv41" "serv41 desc") (43 "serv42" "serv42 desc") (44 "serv51" "serv51 desc") (45 "serv52" "serv52 desc") (46 "serv53" "serv53 desc") (47 "serv54" "serv54 desc"))))) (provider "text" NIL))) (49 "asdf asdf" 739194 41400 2 (41 40 36) NIL))) (process "get" (list (car @Itin1)) NIL NIL '("user1@eml.com" "asdf")))

#user 2 tries to look at user1's itinerary
(test (403) (process "get" (list "itinerary" (car @Itin2)) NIL NIL '("user2@eml.com" "asdf")))


#user 1 removes service from itinerary
(test (204 ("mesg" "Success" "deleted successfully")) (process "post"(list 49  "services" (get (car (get (db 'eid '+Itinerary 49) 'services))'eid)) NIL (list (cons "_method" "del")) '("user1@eml.com" . "asdf")))
(test 2 (length (get (db 'eid '+Itinerary 49) 'services)))

