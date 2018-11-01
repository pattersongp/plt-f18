(* Top-level of the Fire compiler: scan & parse the input,
   check the resulting AST, generate LLVM IR, and dump the module *)

(*     ("-s", Arg.Unit (set_action Sast), "Print the SAST"); *)

type action = Ast | Sast | LLVM_IR | Compile

let _ =
  let action = ref Compile in
  let set_action a () = action := a in
  let speclist = [
    ("-a", Arg.Unit (set_action Ast), "Print the AST");
    ("-s", Arg.Unit (set_action Sast), "Print semantically-checked AST");
    ("-l", Arg.Unit (set_action LLVM_IR), "Print the generated LLVM IR");
    ("-c", Arg.Unit (set_action Compile),
      "Check and print the generated LLVM IR (default)");
  ] in
  let usage_msg = "usage: ./fire.native [-a|-s|-l|-c] [file.fire]" in
  let channel = ref stdin in
  Arg.parse speclist (fun filename -> channel := open_in filename) usage_msg;

  let lexbuf = Lexing.from_channel stdin in

  let ast = Parser.program Scanner.token lexbuf in
  match !action with
    Ast -> print_string (Ast.string_of_program ast)
    (*goal -> to eventually support the following logic: | _ -> let sast = Semant.check ast in *)
    | Sast -> print_string "SAST Code is no complete \n"
    | LLVM_IR -> print_string (Llvm.string_of_llmodule (Codegen.translate ast))

