
type user_access_tokens = (string, string option) Hashtbl.t


let open_db_rw name   = Dbm.opendbm name [Dbm.Dbm_create;Dbm.Dbm_rdwr;] 777

let userid = "1"

let save_to_db tablename access_token = ()
(*
  let db = open_db_rw tablename in
  Dbm.replace db userid access_token
*)

let get_from_db tablename = Some ""
(*
  let db = open_db_rw tablename in
  (try (Some (Dbm.find db userid)) with | _ -> None )
*)

let get_all_tokens tables = 
  let hash_table = Hashtbl.create 5 in 
  let _ = List.map (
    fun table -> Hashtbl.add hash_table table (get_from_db table)) in
  hash_table
