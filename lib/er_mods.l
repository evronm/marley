#add permissions option
(extend +relation)
  (dm perms> (User E) ((role_pos> (if E E (get This 'cls)) User) (mapcar 'chop ( : perms))))
  (dm set_perms> (P)  ( =: perms P) )
  (dm req> () (isa '+Need This))
  (dm ro> (User Act E) (not (may Act User E (get This 'var))))
  (dm spec> () 
    (if (setq typ (lowc (pack (cdr (chop (car (sect '(+Number +Date +Time +Bool +Password) (type This) )))))))
      typ
      "text")) #This is kind of ugly but is unlikely to need changing
  (dm restrict> (User Act E)
    (setq Restr NIL)
    (when (isa '+Need This ) (push 'Restr 'req))
    (when (ro> This User Act E) (push 'Restr 'ro))
    (when (method 'options> This) (push 'Restr (options> This)))
    Restr)

(redef rel Lst
  (eval (cons 'rel (head -1 Lst) )) 
  (put *Class 'rels (append (get *Class 'rels) (list (car Lst)))) #push goes in the wrong order
  (set_perms> (get *Class (car Lst)) (last Lst)))


(extend +List)
  (dm options> (QS User) 
    (let (E (car (get This 'type)) Rs (or (car (get E 'list_rels)) '(nm desc)) )  ### This needs to go in the config file ###
      (list "options" (mapcar '((R)(list R (spec> (get E R)))) Rs) (list_vals> E Path QS Post User Rs))))
  (dm spec> (User Act) "instances")
  (dm add> (E Post) 
    (for Eid (assov (get This 'var) Post ) 
      (ifn (setq Ent (db 'eid '+REntity (any Eid)))
        (push 'Errs (list Eid " does not exist"))
        (ifn (= (type Ent) (get This 'type))
          (push 'Errs (list Eid " is the wrong type"))
          (put> E (get This 'var) Ent))))
    Errs)

(class +Password +String)
  (dm put> (Obj Old Pw)
    (when (nil? (get Obj 'salt))
      (put> Obj 'salt (sym (in "/dev/urandom" (rd 10)))))
    (super Obj Old (sym (pw_hash Pw (get Obj 'salt)))))

(class +Email +String) (dm type> () "email")

(class +FDate +Date)
  (dm put> (Obj Old Dt) (super Obj Old ($dat Dt "-")))
  (dm spec> () "date")
  (dm mis> (Dt E) (super ($dat Dt "-") E))


(class +FTime +Time)
  (dm put> (Obj Old Tm) (super Obj Old ($tim Tm ":")))
  (dm spec> () "time")
  (dm mis> (Tm E) (super ($tim Tm ":") E))
