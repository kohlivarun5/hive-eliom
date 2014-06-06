open Lwt

let name                = "Facebook"
let client_id      = "679802582055154"
let client_secret  = "e0d8bc2cc81829bb742311ae23117871"

let callback_path       = ["fb_oauth2callback"]

let oauth_callback_svc =
  Eliom_service.Http.service ~path:callback_path
                             ~get_params:(Eliom_parameter.string "code") ()

let oauth_uri uri_creator = 
      Oauth.authorize_uri
        ~scopes:(["read_stream"])
        ~auth_url:"https://www.facebook.com/dialog/oauth"
        ~client_id:client_id
        ~callback_url:(uri_creator ~service:oauth_callback_svc)

let authorize uri_creator code = 
  (Oauth.get_access_token
    ~endpoint:"https://graph.facebook.com/oauth/access_token"
    ~client_id
    ~client_secret
    ~callback_url:(uri_creator ~service:oauth_callback_svc)
    ~code)
    >>= (fun str -> 
          Lwt.return (if (Str.string_match (Str.regexp "access_token=\\(.*\\)&") str 0 )
          then Str.matched_group 1 str 
          else ""))


