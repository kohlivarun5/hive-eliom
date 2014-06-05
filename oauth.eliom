open Eliom_content

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
  let redirect_uri_str =  callback_url in
  let uri_str = 
    Uri.to_string (((Uri.add_query_param' oauth_uri ("client_id", client_id)
    |> Uri.add_query_param' & ("response_type", response_type)) 
    |> Uri.add_query_param' & ("redirect_uri", redirect_uri_str))
    |> Uri.add_query_param' & ("scope", match scopes with
      | Some ps -> ps |> implode ~sep:","
      | None -> "")) in 
  uri_str
