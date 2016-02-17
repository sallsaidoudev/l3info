import java.io.*;
import java.net.*;

public class TCPClient {

    public static void main(String[] args) throws Exception {
        // Connexion au serveur distant
        Socket socket = new Socket("localhost", 8080);
        // Envoi d'un message
        System.out.print("Message (enter to send): ");
        String message = new BufferedReader(new InputStreamReader(System.in)).readLine() + "\n";
        OutputStream output = socket.getOutputStream();
        output.write(message.getBytes());
        // Réception de l'écho
        BufferedReader input = new BufferedReader(new InputStreamReader(socket.getInputStream()));
        System.out.println("From server: " + input.readLine());
    }

}
