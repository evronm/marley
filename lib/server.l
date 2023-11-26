(load "lib/util.l")
#(symbols 'serv 'util 'pico)

(setq *Port 4200)
(setq P (port *Port))
(setq *Char64 `'(chop "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/" ) )
(de decode64 (S)
   (let S (chop S)
      (pack
         (make
            (while S
               (let
                  (A (dec (index (++ S) *Char64))
                     B (dec (index (++ S) *Char64))
                     C (dec (index (++ S) *Char64))
                     D (dec (index (++ S) *Char64)) )
                  (link
                     (char (| (>> -2 A) (>> 4 B))) )
                  (and
                     C
                     (link
                        (char
                           (| (>> -4 (& B 15)) (>> 2 C)) ) )
                     D
                     (link
                        (char (| (>> -6 (& C 3)) D)) ) ) ) ) ) ) ) )
(de spl_comma (Str)
  (if (sub? "," Str) 
    (mapcar '((I)(any (pack I))) (sc Str ","))
    Str))

(de parse_qs (QS)
  (mapcar '((Pr) 
    (let  (Kv (split Pr "="))
      (cons (url_dec (car Kv)) (spl_comma (url_dec (cadr Kv))) )
    ) ) (split QS '&)))

(de url_dec (S) 
  (let (Str (split (replace S "+" " ") '%))
    (pack 
      (cons 
        (car Str)
        (mapcar '((Str)
          (cons (char (hex (pack (head 2 Str)))) (nth Str 3))) (cdr Str))))))


(de respond (Stat Bdy Ty)
  (setq Body (if (atom Bdy) Bdy (reggae Bdy)))
  (default Ty "json")
  (out *Sock
    (case Stat
      (200 (prinl "HTTP/1.1 200 OK\n" "Server: Marley\n" "Content-Type: text/" Ty "; charset=UTF-8\n\n"  Body))
      (201 (prinl "HTTP/1.1 201 CREATED\n" "Server: Marley\n" "Content-Type: text/" Ty "; charset=UTF-8\n\n" Body))
      (204 (prinl "HTTP/1.1 204 NO CONTENT\n" "Server: Marley\n"))
      (422 (prinl "HTTP/1.1 422 Validation Failed\n" "Server: Marley\n" "Content-Type: text/" Ty "; charset=UTF-8\n\n" Body))
      (401 (prinl "HTTP/1.1 401 Unauthorized\n" "WWW-Authenticate: Basic realm=\"Please Log In\"\n"))
      (403 (prinl "HTTP/1.1 403 Forbidden\n" ))
      (404 (prinl "HTTP/1.1 404 Not Found\n" )))))


(de start (Processor)
  (loop
    (setq *Sock (listen P))
    (setq Req (make (while (in *Sock (line T)) (link @))))
    (when Req
      (let (Vp (sc (car Req) " "))
        (setq Verb (lowc (pack (car Vp))))
        (let Pq (split (cadr Vp) "?")
          (setq Path (mapcar 'pack (split (cdar Pq) "/")))
          (setq QS (parse_qs (cdr Pq)))))
      (setq Headers (mapcar '((H) (let (F (sc H ":")) (cons (pack (car F)) (pack (cdr F))))) (cdr Req)))
      (when (setq Len (format (cdr (assoc "Content-Length" Headers))))
        (setq Post (parse_qs (in *Sock (ht:Read Len)))))
      
      (setq Creds (mapcar 'pack (sc (decode64 (pack (tail 1 (sc (cdr (assoc "Authorization" Headers)) " ")))) ":")) )
      (apply 'respond
        (Processor Verb Path QS Post Creds)))

    ( close *Sock) ))
