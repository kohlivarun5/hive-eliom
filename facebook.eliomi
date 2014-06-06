val name : string

val oauth_callback_svc :
  (string, unit,
   [> `Attached of
        ([> `Internal of [> `Service ] ], [> `Get ]) Eliom_service.a_s ],
   [ `WithoutSuffix ], [ `One of string ] Eliom_parameter.param_name, 
   unit, [< Eliom_service.registrable > `Registrable ],
   [> Eliom_service.http_service ])
  Eliom_service.service

val oauth_uri :
  (service:(string, unit,
            [> `Attached of
                 ([> `Internal of [> `Service ] ], [> `Get ])
                 Eliom_service.a_s ],
            [ `WithoutSuffix ],
            [ `One of string ] Eliom_parameter.param_name, unit,
            [< Eliom_service.registrable > `Registrable ],
            [> Eliom_service.http_service ])
           Eliom_service.service ->
   string) ->
  string


val authorize :
   (service:(string, unit,
            [> `Attached of
                 ([> `Internal of [> `Service ] ], [> `Get ])
                 Eliom_service.a_s ],
            [ `WithoutSuffix ],
            [ `One of string ] Eliom_parameter.param_name, unit,
            [< Eliom_service.registrable > `Registrable ],
            [> Eliom_service.http_service ])
           Eliom_service.service ->
   string) ->
   string 
   -> string Lwt.t

