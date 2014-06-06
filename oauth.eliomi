val authorize_uri :
  ?scopes:string list ->
  auth_url:string -> client_id:string -> callback_url:string
  -> string

val get_access_token :
  endpoint:string ->
  client_id:string ->
  client_secret:string ->
  callback_url:string ->
  code:string
  -> string Lwt.t

