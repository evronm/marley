
(load "lib/util.l")
(load "lib/server.l")
(load "config.l")
(load "lib/rentity.l")
(load "lib/er_mods.l")
(load (pack (confv '(client)) "/client.l"))

(de authn (Creds)
  (let (Cls (intern "+User" (intern (confv '(ns)))))
    (setq User (db 'eml Cls (car Creds))))
    (and User (= (pw_hash (cdr Creds) (get User 'salt)) (get User 'pw)) User)) #User needs to show up twice to prevent error and return User.

(de req_action (Verb Eid) 
  (if (or (= "new" Eid ) (and (nil? Eid) (= "post" Verb)))
    'c
    (if (= "get" Verb) 
      'r
      (if (and (= "post" Verb) (num? (any Eid))) 
        'u 
        (if (= "del" Eid 'd 'x))))))  # x should never show up in permissions.


(de process (Verb Path QS Post Creds)
  (default Path (confv '(default_path))) 
  (let (
    RR (any (++ Path)) #RR = Requested Resource
    User (authn Creds)
    Meth (++ Path)
    Action (req_action Verb Meth))
    (cond
      ((num? RR)
        (let (Obj (db 'eid '+REntity RR))
          (ifn Obj 
            (404)
            (ifn (may Action User Obj)
              (if User (403) (401))
              (send (any (pack "rest_" Verb ">")) Obj Meth Path QS Post User)))))
      ((sym? RR)
        (let ( Cls (or (isa '+Rest (intern (to_cls_nm RR) (intern (confv '(ns))))) NIL))
          (ifn Cls
            (if (or (not User) (not (= "get" Verb)))
              (403)
              (rest_get> User Meth RR QS Post User))
            (ifn (may Action User Cls)
              (if User (403) (401))
              (send (any (pack "rest_" Verb ">")) Cls Meth Path QS Post User)))))

      (T (404)))))

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


