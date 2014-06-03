open Eliom_content.Html5.D
open Eliom_parameter

(* Services *)
let main_service = Eliom_service.Http.service ~path:[""] ~get_params:unit ()

let user_service =
  Eliom_service.Http.service
    ~path:["subscriptions"] ~get_params:unit ()

let oauth2_connection_service =
  Eliom_service.Http.post_service
    ~fallback:main_service
    ~post_params:(string "name" ** string "password")
    ()

let disconnection_service = Eliom_service.Http.post_coservice' ~post_params:unit ()


(* Eliom references *)
let userid = Eliom_reference.eref ~scope:Eliom_common.default_session_scope None

let subscription_options () =
  lwt u = Eliom_reference.get userid in
  Lwt.return
    (match u with
      | Some s -> div [p [pcdata "You are connected as "; pcdata s; ]]
      | None ->

        let get_auth_div heading uri = 
            div ([
                h2 heading;
                table ~a:[a_width (`Percent 100); 
                          a_class (["table";"table-bordered"])]

                (tr
                  (td [
                   string_input 
                    ~a:[a_onclick ("window.location.href='"^uri^"'")]
                    ~input_type:`Submit ~value:"Facebook" ()
                  ])
                )
                ])

        let l =
          [get_auth_div "Facebook" "www.facebook.com";]
        in
        else div ~a:[a_class (["container"])] l
    )

(* Registration of services *)
let _ =
  Eliom_registration.Html5.register
    ~service:main_service
    (fun () () ->
      lwt cf = connection_box () in
      Lwt.return
        (html (head (title (pcdata "")) [])
              (body [h1 [pcdata "Hello"];
                     cf;
                     user_links ()])));

  (*
  Eliom_registration.Any.register
    ~service:user_service
    (fun name () ->
      if List.exists (fun (n, _) -> n = name) !users
      then begin
        lwt cf = connection_box () in
        Eliom_registration.Html5.send
          (html (head (title (pcdata name)) [])
             (body [h1 [pcdata name];
                    cf;
                    p [a ~service:main_service [pcdata "Home"] ()]]))
      end
      else
        Eliom_registration.Html5.send
          ~code:404
          (html (head (title (pcdata "404")) [])
             (body [h1 [pcdata "404"];
                    p [pcdata "That page does not exist"]]))
    );

  Eliom_registration.Action.register
    ~service:connection_service
    (fun () (name, password) ->
      if check_pwd name password
      then Eliom_reference.set username (Some name)
      else Eliom_reference.set wrong_pwd true);

  Eliom_registration.Action.register
    ~service:disconnection_service
    (fun () () -> Eliom_state.discard ~scope:Eliom_common.default_session_scope ());

  Eliom_registration.Html5.register
    ~service:new_user_form_service
    (fun () () ->
      Lwt.return
        (html (head (title (pcdata "")) [])
              (body [h1 [pcdata "Create an account"];
                     create_account_form ();
                    ])));

  Eliom_registration.Html5.register
    ~service:account_confirmation_service
    (fun () (name, pwd) ->
      let create_account_service =
        Eliom_registration.Action.register_coservice
          ~fallback:main_service
          ~get_params:Eliom_parameter.unit
          ~timeout:60.
          (fun () () ->
            users := (name, pwd)::!users;
            Lwt.return ())
      in
      Lwt.return
        (html (head (title (pcdata "")) [])
              (body [h1 [pcdata "Confirm account creation for "; pcdata name];
                     p [a ~service:create_account_service [pcdata "Yes"] ();
                        pcdata " ";
                        a ~service:main_service [pcdata "No"] ()]
                    ])))

                    *)
