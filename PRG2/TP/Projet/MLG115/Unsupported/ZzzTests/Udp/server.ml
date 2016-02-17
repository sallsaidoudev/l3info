let sock = Net.new_socket 1234;;
let str = String.create 3;;

let rec main () =
  if not (Net.select sock 1.0) then print_char '.' else begin
    let (len, addr) = Net.recv sock str 0 3 in
    print_string (Net.describe_connection addr);
    print_endline (" sais: " ^ str)
  end;
  flush stdout;
  main ()
in 
main ();;

