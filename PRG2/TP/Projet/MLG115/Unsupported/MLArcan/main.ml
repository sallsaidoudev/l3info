




let rec main() =

	Info.wait2 "mainmenu.png" ();
	let wynik = Gra.run() in
	Info.scores wynik;
	main();	
;;


main();;