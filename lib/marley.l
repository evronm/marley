
(load "lib/util.l")
(load "lib/server.l")
(load "config.l")
#(load "lib/rentity.l")
(load "lib/er_mods.l")


(de authn (Creds)
  (let (Cls (intern "+User" (intern (confv '(ns)))))
    (setq User (db 'eml Cls (car Creds))))
    (and User (= (pw_hash (cdr Creds) (get User 'salt)) (get User 'pw)) User)) #User needs to show up twice to prevent error and return User.

(de req_action (Verb Eid) 
  (if (and (= "get" Verb) (or (num? (any Eid)) (member Eid '("list" "show" NIL))))
    'r
    (if (or (= "new" Eid ) (nil? Eid))
      'c
      (if (and (= "post" Verb) (num? (any Eid))) 
        'u 
        (if (= "del" Eid 'd NIL))))))


(de process (Verb Path QS Post Creds) 
  (default Path (confv '(default_path))) 
  (let (
    RR (++ Path)  #RR = Requested Resource
    Cls (or (isa '+Rest (intern (to_cls_nm RR) (intern (confv '(ns))))) NIL)
    Eid (any (++ Path))
    User (authn Creds))
      (ifn Cls  #This is kind of syntactic sugar, but it really makes URL's a lot cleaner.
        (if (or (not User) (not (= "get" Verb)))
          (403)
          (rest_get> User RR QS Post User))
        (if (need_auth> Cls Verb Eid)
          (ifn User
            (401)
            (if (num? Eid)
              (let (Obj (db 'eid '+REntity Eid))
                (ifn Obj
                  (404)
                  (ifn (may (req_action Verb Path) User Obj)
                    (403)
                    (send (any (pack "rest_" Verb ">")) Obj Path QS Post User))))
              (ifn (may (req_action Verb Eid) User Cls)
                (403)
                (send (any (pack "rest_" Verb ">")) Cls Path QS Post User))))
          (if (num? Eid)
            (let (Obj (db 'eid '+REntity Eid))
                (ifn Obj
                  (404)
                  (ifn (may (req_action Verb Path) User Obj)
                    (403)
                    (send (any (pack "rest_" Verb ">")) Obj Path QS Post User))))
            (send (any (pack "rest_" Verb ">")) Cls Path QS Post User))))))


(de may (Act User E R) 
  (ifn R 
    (member Act (perms> E User))
    (member Act  
      (perms> 
        (if 
          (and (type (get E R)) (not (ext? (get E R))))  #make sure perms are for the relation, not the target entity.
          (get E R) 
          (meta E R)) 
        User E)))) 

(de go ()
  (start process) )

(pool (confv '(pool)))


