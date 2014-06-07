open Lwt
open Eliom_content.Html5.D
open Eliom_parameter

(* Services *)
let main_service = Eliom_service.Http.service ~path:[""] ~get_params:unit ()


(* Eliom references *)
let userid = Eliom_reference.eref ~scope:Eliom_common.default_session_scope None

let subscription_options modules =

  lwt u = Eliom_reference.get userid in
  Lwt.return
    (match u with
      | Some s -> div [p [pcdata "You are connected as "; pcdata s; ]]
      | None -> Html.create_subscriptions modules
    )

let subscription_modules = [
  (Fb.name, Fb.oauth_uri, Fb.oauth_callback_svc,Fb.authorize,Fb.get_latest_items);
]

(* Registration of services *)
let _ =
  let _ = List.map 
    (fun (name,_,oauth_callback_svc,authorize,item_getter) -> 
      Eliom_registration.Html5.register
      ~service:oauth_callback_svc
      (fun (code) () ->
      let auth_result = 
            authorize 
            (make_string_uri ~absolute:true ("code"))
            code in
      auth_result >>= (fun auth_result ->
      let items = item_getter auth_result in
      items >>= (fun items ->
      Lwt.return 
      (Html.make_page 
        ~message:("Logged in to "^name^" !")
        [Html.create_items items]
        (Eliom_service.static_dir ())
      )))))
      subscription_modules in

  Eliom_registration.Html5.register
    ~service:main_service
    (fun () () ->

      lwt cf = 
        subscription_options 
        (List.map (fun (name,oauth_uri,_,_,_) -> 
                    (name, 
                     (Db.get_from_db name),
                     (oauth_uri (make_string_uri ~absolute:true ("code")))))
                subscription_modules) in

     Lwt.return (Html.make_page 
                  [cf] 
                  (Eliom_service.static_dir ())))
