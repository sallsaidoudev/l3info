import java.io.*;
import java.net.*;

public class TCPServer {

    public static void main(String[] args) throws IOException {
    	// Mise en écoute sur le port 8080
        ServerSocket socket = new ServerSocket(8080);
        System.out.println("TCP server running on 8080...");
        // Boucle d'écoute
        while (true) {
        	// Réception d'un nouveau message
            Socket client = socket.accept();
            String message = new BufferedReader(new InputStreamReader(client.getInputStream())).readLine();
            System.out.println(message);
            // Renvoi de l'écho
            OutputStream output = client.getOutputStream();
            output.write(message.getBytes());
            client.close();
        }
    }

}
