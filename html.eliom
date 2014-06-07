open Eliom_content.Html5.D

let to_xml_url uri = 
  (Uri.to_string uri) |> Raw.uri_of_string

let alert message = 
  (div ~a:[a_class ["alert";"alert-info"]] [pcdata (""^message)])

let make_page ?message body' root_url  = 
  (html
    (head (title (pcdata "{Hive}"))
        [css_link ~uri:(make_uri root_url ["css";"main.css"]) ();
         css_link ~uri:(make_uri root_url 
                        ["css";"bootstrap";"css";"bootstrap.min.css"]) ();
         css_link ~uri:(make_uri root_url
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
       (js_script ~uri:(make_uri root_url
                 ["css";"bootstrap";"js";"bootstrap.min.js"]) ())
       ::[(div ~a:[a_class ["container"];]
          (match message with | None -> body' | Some m -> (alert m)::body'))])
    )
  )


 (*
            Client side code doesn't work yet !!

          let client_uri = (make_string_uri ~service:(oauth_uri uri) () ) in
          let onclick = {{ fun ev -> 
            Dom_html.window##location##href <- (Js.string %client_uri) }} in
          *)

let create_subscriptions modules = 

  let get_auth_div (heading,access_token,oauth_uri) =
    (div ~a:[a_class (["span4"])]
    [
      table ~a:[a_class (["table";"table-bordered"])]
      (tr
        [(td 
          [
            (Raw.a ~a:[a_href (Raw.uri_of_string oauth_uri);
                       a_style "text-decoration:none;"]
              [(string_input ~a:[a_class ["btn";"btn-block";"btn-success"];]
                ~input_type:`Submit 
                ~value:((if access_token = None 
                         then "Login using "^heading
                         else "Logged in using "^heading)) ();)]
            )
          ]
        )]
      )
      [];
    ]) 
  in
  let l = List.map get_auth_div modules in
  div l

let create_item_td item = 
  (td [(
  match item.Core_types.image with
  | Some uri -> 
    (Raw.a ~a:[a_href (to_xml_url uri)]
    [(img ~src:(to_xml_url uri) ~alt:("Image not found :( ") ()); ])

  | None -> 
  (pcdata (match item.Core_types.text with | None -> "No text" | Some x -> x))
  )])

let create_items items =

  let create_item item  =
    (div ~a:[a_class ["span4"]]
     [ table ~a:[a_style "background-color:#F5F5F9"; a_class ["table";"table-bordered"]]
       (tr [create_item_td item])
       [];

    ]) in

   let l = List.map create_item items in
   (div ~a:[a_class ["row"]] [(div ~a:[a_style "margin-top:5px;"] l) ])
