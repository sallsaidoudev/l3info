import java.io.*;
import java.net.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class HTTPServer {

    public static void main(String[] args) throws IOException {
        ServerSocket socket = new ServerSocket(8080);
        System.out.println("HTTP server running on 8080...");
        // Boucle d'écoute
        while (true) {
            // Lecture d'une requête
            Socket client = socket.accept();
            String request = new BufferedReader(new InputStreamReader(client.getInputStream())).readLine();
            String reqs[] = request.split(" ");
            if (!reqs[0].equals("GET")) { // On n'accepte que les GET
                System.out.println("Can't accept non-GET requests");
                continue;
            }
            // Réponse HTTP (page unique)
            OutputStream output = client.getOutputStream();
            SimpleDateFormat dateFormat = new SimpleDateFormat("EEE, d MMM yyyy HH:mm:ss Z", Locale.ENGLISH);
            String response = "HTTP/1.0 200 OK \n"
                    + "Date: "+dateFormat.format(new Date())+"\n"
                    + "Server: TPsyr 1.0\n\n"
                    + "<html>h1>Hello world.</h1>I'm a web server, how can I help you?</html>";
            output.write(response.getBytes());
            client.close();
        }
    }

}
