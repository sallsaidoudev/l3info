import java.io.*;
import java.net.*;

public class HTTPClient {

    public static void main(String[] args) throws Exception {
        // Connexion au serveur
        Socket socket = new Socket("localhost", 8080);
        // Requête HTTP
        OutputStream output = socket.getOutputStream();
        output.write("GET /quelquechose HTTP/1.0 \n\n".getBytes());
        // Réponse du serveur
        BufferedReader input = new BufferedReader(new InputStreamReader(socket.getInputStream()));
        String response = "", line = "";
        while ((line = input.readLine()) != null)
            response += line + "\n";
        System.out.println(response);
    }

}
