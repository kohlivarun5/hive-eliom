let name                = "Facebook"
let application_id      = "679802582055154"
let application_secret  = "e0d8bc2cc81829bb742311ae23117871"

let callback_path       = ["fb_oauth2callback"]

let oauth_callback_svc =
  Eliom_service.Http.service ~path:callback_path
                             ~get_params:(Eliom_parameter.string "code") ()

let oauth_uri uri_creator = 
      Oauth.authorize_uri
        ~scopes:(["read_stream"])
        ~auth_url:"https://www.facebook.com/dialog/oauth"
        ~client_id:application_id
        ~callback_url:(uri_creator ~service:oauth_callback_svc)
