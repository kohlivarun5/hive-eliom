open Lwt
open Facebook
open Endpoints

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
          Lwt.return (
          let access_token = 
            if (Str.string_match (Str.regexp "access_token=\\(.*\\)&") str 0 )
            then Str.matched_group 1 str 
            else ""
          in
          let _ = Db.save_to_db name access_token in
          access_token
        ))


let make_large_picture_uri uri = 
  match uri with 
  | None -> None
  | Some uri -> Some (
  let string_url = (Uri.to_string uri) in
  let big_url = Str.global_replace (Str.regexp "_s.") "_n." string_url in
  Uri.of_string big_url)

module API = Api.S(Request_cohttp.S)
module R = Core.Result

let get_latest_items access_token = 
  let open Endpoints.User.Home.ReadResponse in
  let open Endpoints.User.Home.Post in
  let open Endpoints.User.Home.Profile in
  let request = access_token |> Auth.Token.of_string |> Request_cohttp.S.create in

  let rec format_response items response =
    match response with
    | R.Ok paged -> 
        (let response_items = 
           List.map 
             (fun post -> 
             {
              Core_types.poster=post.from.name;
              text=post.message;
              image=(make_large_picture_uri post.picture)
             })
             (API.(paged.response.data)) in
         let items = List.rev_append items response_items in
         match ((List.length items) > 10 ), (API.(paged.next)) with
         | true,_ | _, None -> Lwt.return items
         | _,Some more -> Lwt.bind (more ()) (format_response items)
        )

    | _ -> Lwt.return items
  in
  ((API.User.Home.read request) >>= (format_response []))
    (*
    | R.Error (`Conversion_error e) -> Lwt.return []
      let buf = Buffer.create 0 in
      Meta_conv.Error.format Tiny_json.Json.format (Format.formatter_of_buffer buf) e; 
      Printf.printf "Error parsing response:\n%s\n" (Buffer.contents buf);
      Buffer.reset buf;
      Lwt.return []
    | R.Error _ -> 
      print_endline "An unspecified error occurred.";
      Lwt.return_unit
      *)
