
(load "lib/util.l")
(load "lib/server.l")
(load "config.l")
(load "lib/rentity.l")
(load "lib/er_mods.l")
(load (pack (confv '(client)) "/client.l"))


(de req_action (Verb Meth) 
  (if (= "new" Meth ) 
    'c
    (if (= "get" Verb) 
      'r
      (if (= "post" Verb)  
        'u 
        (if (= "del" Verb 'd 'x))))))  # x should never show up in permissions.


(de process (Verb Path QS Post Creds)
  (default Path (confv '(default_path))) 
  (when (not (lst? Path)) (setq Path (list Path)))

  (let (
    RR (any (++ Path)) #RR = Requested Resource
    User (authn> '+user Creds)
    Meth (++ Path)
    Action (req_action Verb Meth)
    Targ (if (num? RR) (db 'eid '+REntity RR) (or (isa '+Rest (intern (to_cls_nm RR) (intern (confv '(ns))))) NIL)))
    (if (and (car Creds) (not User)) #Creds is a list, so never false
      (403)
      (when (and (= Verb "post") (= "del" (assov "_method" Post ))) #I hate this, but browsers don't implement REST verbs, goddammit!!
        (setq Verb "del")
        (setq Post (filter '((KV)(not (= "_method" (car KV)))) Post))
        (setq Action 'd))

      (if (and (sym? RR) (not Targ)) 
        (if (or (not User) (not (= "get" Verb)))
          (403)
          (rest_get> User RR Meth QS Post User))
        (ifn Targ
            (404)
            (ifn (may Action User Targ)
              (if User (403) (401))
              (send (any (pack "rest_" Verb #{(when (and Meth (= "get" Verb)) (list "_" Meth ))}# ">")) Targ Meth Path QS Post User)))))))

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

(class +user +REntity)
  (var perms cud r c)
  (dm owner> () This)
  (dm authn> (Creds)
    (let User(db 'eml '+user (car Creds))
    (and User (= (pw_hash (cdr Creds) (get User 'salt)) (get User 'pw)) User)))



  (rel eml (+Need +Key +Email) (crud r c))
  (rel pw (+Need +Key +Password) (cu NIL c))
  (rel salt (+String) NIL)
  
(class +Tag +REntity +Rest)
  (var perms crud rc r)
  (var list_rels (nm))

  (rel nm (+Key +String) (crud cr r))
  (rel ent (+List +Ref +Joint) NIL tags (+taggable) (crud crud r))

(class +taggable +REntity)
  (dm rels> (User Act) 
    (let (Rels (super User Act)) 
      (append (delete 'tags Rels) '(tags))))
  
  (rel tags (+List +Ref +Joint) NIL ent (+Tag) (crud cr r))

  (dm rest_post> (Meth Path QS Post User) 
    (super Meth Path QS 
      (mapcar '((KV)
        (ifn (= (car KV) 'tags) 
          KV 
          (cons 'tags (mapcar '((Tag)
            (get (request! '(+Tag) 'nm Tag) 'eid)) 
            (or (pair (cdr KV)) (list (cdr KV))))) ))
        Post) 
      User))
