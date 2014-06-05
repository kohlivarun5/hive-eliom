val make_page :
  [< Html5_types.body_content_fun > `Div `Script ] Eliom_content.Html5.D.elt
  list ->
  (string list, unit, [< Eliom_service.get_service_kind ],
   [< Eliom_service.suff ], 'a, unit, [< Eliom_service.registrable ], 'b)
  Eliom_service.service -> [> `Html ] Eliom_content.Html5.D.elt
