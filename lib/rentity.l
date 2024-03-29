#This is a wrapper class for +Entity which adds a bunch of REST methods.
(class +REntity +Entity) 
  (var perms ~(confv '(default_cls_perms))) #kind of ugly; `var` is an f-expression  (crud r c) as of now...

  (dm T @ (put> This 'eid (genKey 'eid '+REntity)) (pass super))  #Every addressable entity has a unique ID.
  (rel eid (+Key +Number) NIL)

  #override this to use more than the default permission slots (owner, group, logged in, and anon)
  (dm role_pos> (User) #usually users and anons get the same perms; and caddr and last happen to be the same.  Need to watch out for this and may want to change it.
    (cond 
      ((and User (= User (owner> This))) 'car)
      ((grp_mem> This User) 'cadr)
      ((bool User) 'caddr)
      (T 'last )))

  (dm perms> (User)
    (setq Perms (or (get This 'perms) (var: perms)))
    (chop ((role_pos> This User) Perms)))

  (dm owner> () (get This (car (or (get This 'owner_rel) (var: owner_rel)))))
  (dm set_owner>(User) (put> This (car (or (get This 'owner_rel) (var: owner_rel))) User))
  (dm grp_mem>(User) (isa (car (or (get This 'grp) (var: grp))) User))
  (dm cls> () (if (ext? This) (car (type This)) (name This)))
  (dm cls_nm> () (lowc (pack (cdr (chop (cls> This)))) ))
  (dm url> () (pack "/" (when (ext? This) (get This 'eid))))
  (dm link> () (list "url" (url> This) (get This 'nm) (get This 'desc)))

  (dm rel> (R) (meta (list This) R))
  (dm rels> (User Act) 
    (filter '((R) (may Act User This R) )
      (uniq (delete NIL (append (try 'rels> (car (type This)) User Act ) ((if (ext? This) meta get) This 'rels)) ))))

  (dm spec> (User Act)
    (list
      (cls_nm> This)
      (if (ext? This) (get This 'eid) "new")
      (flags> This User Act)
      (mapcar '((R) 
        (setq Rel (rel> (if (ext? This) (cls> This) This) R))
        (list R 
          (spec> Rel User Act) 
          (if (= 'r Act) 
            NIL 
            (if (= Act 'r) NIL  (restrict> Rel User Act This) ))) )
        (rels> This User Act))))

  (dm flags> (User Act) 
    (off Flags)
    (when (= 'c Act) (push 'Flags "new"))
    (unless (or (and (not (ext? This)) (may 'c User This)) (and (= 'c Act) (may 'c User This)) (and (= 'u Act) (may 'u User This)) )  (push 'Flags "ro"))
    (when (may 'd User This) (push 'Flags "del"))
    Flags)

  (dm list> (Path QS Post User) 
    (ifn QS
        (lsearch NIL (list (list 'eid This)))
        (apply lsearch (qs2srch This QS))))

  (dm val> (R Act) 
    (let (V (get This R))
      (if2 (atom V) (= Act 'r)
        (if (ext? V ) (link> V) V)
        (if (ext? V ) (get V 'eid) V)
        (mapcar '((E)(link> E)) V)
        (mapcar '((E)(get E 'eid)) V))))

  (dm vals> (User Act Rels) 
    (let Vals (mapcar '((R)(val> This R Act)) (or Rels (rels> This User Act)))
      (if (== 'c Act)
        Vals
        (cons (get This 'eid) Vals))))

  (dm list_vals> (Path QS Post User Rels) (mapcar '((E) (vals> E User 'r Rels)) (list> This Path QS Post User)))
      
  (dm rest_get_new> (Path QS Post User) 
    (ifn Path 
      (list 200 (list "instance" (spec> This User 'c)))
      (send (intern (pack (cadr Path) ">")) (get This (intern (car Path))) QS User )))
  (dm rest_get_list> (Path QS Post User) (list 200 (list "instances" (spec> This User 'r) (list_vals> This Path QS Post User))))
  (dm rest_get_mine> (Path QS Post User) 
    (list 200 (list "instances" (spec> This User 'r) (list_vals> This Path (list (cons (car (get This 'owner_rel)) (get User 'eid))) Post User))))
  
  (dm rest_get> (Meth Path QS Post User) 
    (if (ext? This)
      (ifn Meth
        (list 200 (list "instance" (spec> This User (if (may 'u User This) 'u 'r)) (vals> This User (if (may 'u User This) 'u 'r))))
        (let (Rs (get This (intern Meth)) Kls (intern (get (get (cls> This) (intern Meth)) 'type)))
          (ifn Kls  #The whole mishigas above is just for this test :/
            (or (try (intern (pack "get_" (car Path) ">")) This Path QS Post User) (404))
            (if Path
              (send (intern (pack Path ">")) (meta This (intern Meth)) QS User )
              (list 200 (list "instances" (spec> Kls User 'r "display") (mapcar '((R)(vals> R User 'r)) Rs)))))))
      (default Meth '("list"))
      (or (try (intern (pack "rest_get_" Meth ">")) This Path QS Post User) (404))) )

  (dm rest_post> (Meth Path QS Post User) 
      (if (not (ext? This))
        (prog 
          (setq E (new T (list This)))
          (try 'set_owner> E User))
        (setq E This))
      (if Path
        (let (Rel (meta E Meth))
          (setq Errs (send (intern (pack (car Path) ">")) Rel E Post)))
        (for R (rels> E User (req_action Verb Meth))
          (if (and (isa '+Link (meta E R)) (assoc R Post))
            (if (may (req_action Verb Meth) User This R)
              (prog 
                (put E R NIL)
                (setq Errs (add> (meta E R) E Post)))
              (push 'Errs (list R "Forbidden")))
            (let (V (cadr (assoc R Post)))
              (cond
                ((setq Err (mis> E R (or (or (format V) V) (get E R)))) (push 'Errs (list R Err )))
                ((and V (not (may (req_action Verb Meth) User This R))) (push 'Errs (list R "Forbidden")))
                (V (put> E R (if (num? (any V)) (any V) V))))))))
      (if Errs
        (prog 
          (rollback)
          (prog1 (list 422 (cons '(error) Errs)) (setq Errs NIL)) ) 
        (commit)
        (when (and (isa '+user E) (not User)) (setq User E)) #anon creating a new user
        (list 201 (list "instance" (spec> E User 'u) (vals> E User 'u)))) ) 

   (dm rest_del> (Meth Path QS Post User)
    (ifn Meth
      (lose> This)
      (del> This (intern Meth) (db 'eid '+REntity (car Path))))

     (if Errs
        (prog 
          (rollback)
          (prog1 (list 403 (cons '(error) Errs)) (setq Errs NIL)) ) 
        (commit)
        (list 204 '("mesg" "Success" "deleted successfully"))) ) 

