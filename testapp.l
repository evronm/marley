
(load "lib/marley.l")

(symbols 'entities 'pico)

(local) (+User +Venue +Provider +Service +Itinerary)


#Jamaica is the only client to date.  It is, however settable in config.l
#`process looks in the ns (from config.l) namespace (default 'enitities as above) for classes with (isa '+Rest) for "entity"
(class +Client +Jamaica +Rest)
  (dm home> (User)
    (cond 
      ((not User))
      ((isa '+Venue User))
      ((isa '+Provider User))
      ((isa '+User User))
      ()))
  (dm nav> (User)
    (cond 
      ((not User) ($div '((id . nav)) (list ($a '((href . "/venue/list")) "Browse Venues") ($a '((href . "/provider/list")) "Browse providers") )))
      ((isa '+Venue User) ($div '((id . nav)) (list ($a '((href . "/service/new")) "New Service") ($a '((href . "/service/mine")) "Browse Services") ($a '((href . "/itineraries/")) "Browse Upcoming visitors") )))
      ((isa '+Provider User))
      ((isa '+User User)($div '((id . nav)) (list ($a '((href . "/itins")) "My Itineraries") ($a '((href . "/venue/list")) "Browse Venues") ($a '((href . "/provider/list")) "Browse providers") ($a '((href . "/itinerary/new")) "New Itinerary") )))
      ()))

#+REntity inherits from +Entity, adding rest methods and overriding a couple.  URL syntax is /entity/[new|search|eid] .
#eid is unique for all addressable entitities in the DB.
#additional required parameter for rel's is permissions:  create/read/update/detlete/select/multiselect for user, group, other. Implemented in lib/relations.l
#default class perms can be set in config.l
#Each class should define a 'nm and a 'desc relation or method.  This needn't be unique, but will be used in link text for individual instances.

#This default app is an abstraction of a bespoke wine tour app.  The vendors corresond to tasting rooms, the providers to drivers, and the users to tasters.
#The framework, and the test app, should be sufficiently abstract that customisation required should be minimal for most gig/service oriented apps.

(class +Nd +Entity)
  (rel lt (+UB +Aux +Ref +Number) (ln) NIL 6 NIL)
  (rel ln (+Number) 6 NIL)                       
  (rel w (+List +Joint +Ref) nd (+Way) NIL)         

(class +Way +Entity)
  (rel nm (+Fold +Ref +String) NIL) 
  (rel nd (+List +Joint +Ref) w (+Nd) NIL)

(class +User +user +Rest)
  (rel addr (+Idx +String) (crud r c))
  (rel nm (+Need +Sn +Idx +String) (crud r c))
  (rel itins (+List +Joint) cust (+Itinerary) (rud r NIL))

(class +Venue +User)
  (var perms crud r cr)
  (rel nm (+Need +Sn +Idx +String) (crud r rc))
  (rel desc (+Need +Idx +String) (crud r rc))
  (rel providers (+List +Joint) venues (+Provider) (crd crd r))
  (rel services (+List +Joint) venue (+Service) (rud r r))
  (rel loc (+Ref +Link) NIL (+Nd) NIL)

(class +Provider +User)
  (var perms crud r cr)
  (rel nm (+Need +Sn +Idx +String) (crud r rc))
  (rel desc (+Need +Idx +String) (crud r rc))
  (rel venues (+List +Joint) providers (+Venue) (rd crd r))
  (rel itins (+List +Joint) provider (+Itinerary) (rd crd NIL))

(class +Service +taggable +Rest)
  (var owner_rel venue)
  (var grp +Venue)
  (var perms crud rc rm)

  (rel nm (+Need +Sn +Aux +Key +String) (venue) (crud cr r))
  (rel desc (+Need +Idx +String) (crud rc cm))
  (rel duration (+Need +Number) (crud cr rm))
  (rel price (+Need +Number) (crud cr rm))
  (rel capacity (+Need +Number) (crud cr rm))
  (rel max_grp (+Number) (crud cr rm))
  (rel venue (+Need +Ref +Joint) NIL services (+Venue) (d cr r))
  (rel itins (+List +Ref +Joint) NIL services (+Itinerary) (r))


(class +Itinerary +REntity +Rest)
  (var owner_rel cust)
  (var perms crud r c NIL)
  (var list_rels (dt start_addr))
  #(dm grp_mem> (User) (= User (get This 'provider)))

  (rel start_addr (+Need +String) (crud r cr NIL))
  (rel dt (+Need +Idx +FDate) (crud r cr NIL))
  (rel tm (+Need +FTime) (crud r cr NIL))
  (rel cust (+Joint) itins (+User) (c r NIL))
  (rel ppl (+Need +Number) (crud r rc NIL))
  (rel services (+List +Joint) itins (+Service) (rud r r NIL))
  (rel provider (+Joint) itins (+Venue) (rud r r NIL))

(load T)
#(bye)
