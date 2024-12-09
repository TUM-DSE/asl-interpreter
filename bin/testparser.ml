(* dune exec bin/testparser.exe prelude.asl ../mra_tools/arch/regs.asl ../mra_tools/types.asl ../mra_tools/arch/arch.asl ../mra_tools/arch/arch_instrs.asl *)

open LibASL

let opt_filenames : string list ref = ref []
let opt_output : string ref = ref "ast.json"

let options = Arg.align ([
    ( "-o", Arg.Set_string opt_output, "<file> Set output file" );
] )

let version = "ASL Parser 0.0"
let usage_msg =
    ( version
    ^ "\nusage: testparser <file1.asl> ... <fileN.asl>\n"
    )
    
let _ =
  Arg.parse options
    (fun s -> opt_filenames := (!opt_filenames) @ [s])
    usage_msg

let _ =
    let r: Asl_ast.declaration list list ref = ref [] in
    List.iter (fun filename ->
        let isPrelude = Filename.basename filename = "prelude.asl" in
        let t = LoadASL.read_file filename isPrelude false in
        r := t :: !r
    ) !opt_filenames;
    let ast = List.concat (List.rev !r) in
    let oc = open_out !opt_output in
    let doc = Asl_parser_pp.pp_declarations ast in
    PPrint.ToChannel.pretty 1.0 80 oc doc
