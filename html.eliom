open Eliom_content.Html5.D

let make_page body' root_url = 
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
       ::body')
    )
  )
