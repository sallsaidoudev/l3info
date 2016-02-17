import java.io.*;
import java.net.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class HTTPBetterServer {

    public static void main(String[] args) throws IOException {
        ServerSocket socket = new ServerSocket(8080);
        System.out.println("HTTP server running on 8080...");
        // Boucle d'écoute
        while (true) {
            // Lecture d'une requête
            Socket client = socket.accept();
            String request = new BufferedReader(new InputStreamReader(client.getInputStream())).readLine();
            String reqs[] = request.split(" ");
            if (!reqs[0].equals("GET")) {
                System.out.println("Can't accept non-GET requests");
                continue;
            }
            // Réponse HTTP
            OutputStream output = client.getOutputStream();
            BufferedReader file = null;
            try { // On tente de récupérer le fichier demandé
                System.out.println("Fetching file "+reqs[1]);
                file = new BufferedReader(new FileReader("www"+reqs[1]));
            } catch (Exception e) { // S'il n'existe pas, 404
                output.write("HTTP/1.0 404 Not Found\n\n<html><h1>404 Not Found</h1></html>".getBytes());
                client.close();
                continue;
            }
            // Le fichier a été récupéré, on le sert
            SimpleDateFormat dateFormat = new SimpleDateFormat("EEE, d MMM yyyy HH:mm:ss Z", Locale.ENGLISH);
            String response = "HTTP/1.0 200 OK \n"
                    + "Date: "+dateFormat.format(new Date())+"\n"
                    + "Server: TPsyr1.0\n\n";
            String line = "";
            while ((line = file.readLine()) != null)
                response += line + "\n";
            output.write(response.getBytes());
            client.close();
        }
    }

}
