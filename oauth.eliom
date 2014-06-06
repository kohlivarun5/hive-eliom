open Lwt

let (&) f x = f x

let implode ?sep:(sep="") l = 
  List.tl l |> List.fold_left (fun acc e -> acc ^ sep ^ e) (List.hd l)

let authorize_uri
  ?scopes
  ~auth_url
  ~client_id
  ~callback_url
  =
  let oauth_uri = Uri.of_string auth_url in
  let response_type = "code" in
  let uri_str = 
    Uri.to_string (((Uri.add_query_param' oauth_uri ("client_id", client_id)
    |> Uri.add_query_param' & ("response_type", response_type)) 
    |> Uri.add_query_param' & ("redirect_uri", callback_url))
    |> Uri.add_query_param' & ("scope", match scopes with
      | Some ps -> ps |> implode ~sep:","
      | None -> "")) in 
  uri_str

type access_token_result =  {
  access_token : string * string
}

(* a simple function to access the content of the response *)
let content http_result = 
  (match http_result with
    | { Ocsigen_http_frame.frame_content = Some v } ->
        Ocsigen_stream.string_of_stream 100000 (Ocsigen_stream.get v)
    | _ -> Lwt.return ""
  )
  (*>>= 
   (fun str -> Lwt.return 
      (match (Ocsigen_lib.Url.decode_arguments str) with
      | [] -> ""
      | ("access_token",access_token)::_ ->  access_token))
*)

let get_access_token
  ~endpoint
  ~client_id
  ~client_secret
  ~callback_url
  ~code
  =

  let oauth_uri = Uri.of_string endpoint in
  let uri_str = 
    Uri.to_string (((Uri.add_query_param' oauth_uri ("client_id", client_id)
    |> Uri.add_query_param' & ("client_secret", client_secret)) 
    |> Uri.add_query_param' & ("redirect_uri", callback_url))
    |> Uri.add_query_param' & ("code", code)) in
  let t = Ocsigen_http_client.get_url uri_str in
  t >>= content
