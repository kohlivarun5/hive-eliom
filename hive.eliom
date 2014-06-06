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
      | None ->


        let get_auth_div (heading,oauth_uri) =
          (*
            Client side code doesn't work yet !!

          let client_uri = (make_string_uri ~service:(oauth_uri uri) () ) in
          let onclick = {{ fun ev -> 
            Dom_html.window##location##href <- (Js.string %client_uri) }} in
          *)

          (div ~a:[a_class (["span4"])]
          [
            table ~a:[a_class (["table";"table-bordered"])]
            (tr
              [(td 
                [
                  (Raw.a ~a:[a_href (Raw.uri_of_string oauth_uri);
                             a_style "text-decoration:none;"]
                    [(string_input ~a:[a_class ["btn";"btn-block";"btn-success"];
                                      (* a_onclick onclick; *) ]
                      ~input_type:`Submit ~value:("Login using "^heading) ();)]
                  )
                ]
              )]
            )
            [];
          ]) in

        let l = List.map get_auth_div modules in
        div ~a:[a_class (["container"])] l
    )

let subscription_modules = [
  (Facebook.name, Facebook.oauth_uri, Facebook.oauth_callback_svc,Facebook.authorize);
]

let sum a b = a + b ;;


(* Registration of services *)
let _ =
  let _ = List.map 
    (fun (_,_,oauth_callback_svc,authorize) -> 
      Eliom_registration.Html5.register
      ~service:oauth_callback_svc
      (fun (code) () ->
      let auth_result = 
            authorize 
            (make_string_uri ~absolute:true ("code"))
            code in
      Lwt.bind 
        auth_result 
          (fun auth_result ->
            Lwt.return (Html.make_page 
                  [pcdata auth_result]
                  (Eliom_service.static_dir ())
                 )
          )
      )) subscription_modules in

  Eliom_registration.Html5.register
    ~service:main_service
    (fun () () ->
     lwt cf = 
      subscription_options 
        (List.map (fun (name,oauth_uri,_,_) -> 
                    (name, (oauth_uri (make_string_uri ~absolute:true ("code")))))
                subscription_modules) in
     Lwt.return (Html.make_page 
                  [cf] 
                  (Eliom_service.static_dir ())))
