open Eliom_content.Html5.D
open Eliom_parameter

(* Services *)
let main_service = Eliom_service.Http.service ~path:[""] ~get_params:unit ()
let oauth_service uri = Eliom_service.Http.external_service 
                            ~prefix:"http://" ~path:uri ~get_params:unit () 
(*
let user_service =
  Eliom_service.Http.service
    ~path:["subscriptions"] ~get_params:unit ()

let oauth2_connection_service =
  Eliom_service.Http.post_service
    ~fallback:main_service
    ~post_params:(string "name" ** string "password")
    ()

let disconnection_service = Eliom_service.Http.post_coservice' ~post_params:unit ()

*)

(* Eliom references *)
let userid = Eliom_reference.eref ~scope:Eliom_common.default_session_scope None

let subscription_options () =
  lwt u = Eliom_reference.get userid in
  Lwt.return
    (match u with
      | Some s -> div [p [pcdata "You are connected as "; pcdata s; ]]
      | None ->


        let get_auth_div heading uri =
          (*
            Client side code doesn't work yet !!

          let client_uri = (make_string_uri ~service:(oauth_service uri) () ) in
          let onclick = {{ fun ev -> 
            Dom_html.window##location##href <- (Js.string %client_uri) }} in
          *)

          (div ~a:[a_class (["span4"])]
          [
            table ~a:[a_class (["table";"table-bordered"])]
            (tr
              [(td 
                [
                  (a ~service:(oauth_service uri) ~a:[a_style "text-decoration:none;"]
                    [(string_input ~a:[a_class ["btn";"btn-block";"btn-success"];
                                      (* a_onclick onclick; *) ]
                      ~input_type:`Submit ~value:("Login using "^heading) ();)] ())


                ]
              )]
            )
            [];
          ]) in

        let l =
          [(get_auth_div "Facebook" ["facebook.com"])]
        in
        div ~a:[a_class (["container"])] l
    )

let make_page body' = 
(html
     (head (title (pcdata "{Hive}"))
        [css_link ~uri:(make_uri (Eliom_service.static_dir ())
                  ["css";"main.css"]) ();
         css_link ~uri:(make_uri (Eliom_service.static_dir ())
                  ["css";"bootstrap";"css";"bootstrap.min.css"]) ();
         css_link ~uri:(make_uri (Eliom_service.static_dir ())
                  ["css";"bootstrap";"css";"bootstrap-responsive.min.css"]) ();
    ])
     (body ~a:[a_style "background-color:#F1ECDE"]
       ((div ~a:[a_class ["navbar";"navbar-inverse";"navbar-fixed-top"]]
         [div ~a:[a_class ["navbar-inner"]]
          [div ~a:[a_class ["container"]]
           [
            (p ~a:[a_style "padding-right:1cm"; a_class ["brand"]]
           [(b [pcdata "{Hive}"]); (i [pcdata " : Your social hub!"]);]);
            (div [p ~a:[a_class ["brand";"navbar-form";"right"]] 
                    [pcdata "Subscriptions"]]);
            (div [p [pcdata "Submit"]])
               ]
          ]]) ::
        (js_script ~uri:(make_uri (Eliom_service.static_dir ())
                  ["css";"bootstrap";"js";"bootstrap.min.js"]) ())
        ::body')))

(* Registration of services *)
let _ =
  Eliom_registration.Html5.register
    ~service:main_service
    (fun () () ->
      lwt cf = subscription_options () in
      Lwt.return (make_page [cf]))
