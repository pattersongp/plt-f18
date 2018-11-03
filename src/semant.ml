open Ast

let check (vdec,fdec) = 

  let check_binds (kind : string) (binds : bind list) =
    List.iter (function
	(Void, b, c) -> raise (Failure ("illegal void " ^ kind ^ " " ^ b))
      | _ -> ()) binds; 
    let rec dups = function
        [] -> ()
      |	((_,n1,_) :: (_,n2,_) :: _) when n1 = n2 ->
	  raise (Failure ("duplicate " ^ kind ^ " " ^ n1))
      | _ :: t -> dups t
    in dups (List.sort (fun (_,a,_) (_,b,_) -> compare a b) binds)
in

(* check variable declarations *)
check_binds "variable declarations" vdec;