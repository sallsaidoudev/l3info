import java.io.*;
import java.net.*;

public class UDPServer {

	private static byte[] buffer = new byte[1024];

	public static void main(String args[]) throws IOException {
		// Mise en écoute sur le port 8080
		DatagramSocket server = new DatagramSocket(8080);
        System.out.println("UDP server running on 8080...");
		// Boucle d'écoute
		while (true) {
			// Réception d'un paquet UDP
			DatagramPacket request = new DatagramPacket(buffer, buffer.length);
			server.receive(request);
			// Récupération des informations client
			InetAddress ip = request.getAddress();
			int port = request.getPort();
			System.out.println(new String(request.getData()));
			// Renvoi de l'écho
			server.send(new DatagramPacket(buffer, buffer.length, ip, port));
		}
	}

}
