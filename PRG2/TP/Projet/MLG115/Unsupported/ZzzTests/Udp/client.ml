let con = Net.connect "localhost" 1234;;
Net.send con "qwe" 0 3;;
if Net.select con 100.0 then ignore (Net.recv con (String.create 3) 0 3);;



