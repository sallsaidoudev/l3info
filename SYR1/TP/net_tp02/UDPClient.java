import java.io.*;
import java.net.*;

public class UDPClient {

	private static byte[] buffer = new byte[1024];

	public static void main(String args[]) throws IOException {
		// Création du socket client
		DatagramSocket client = new DatagramSocket();
		// Consitution du paquet UDP et envoi
		InetAddress ip = InetAddress.getByName("localhost");
		System.out.print("Message (enter to send): ");
		String message = new BufferedReader(new InputStreamReader(System.in)).readLine();
		buffer = message.getBytes();
		client.send(new DatagramPacket(buffer, buffer.length, ip, 8080));
		// Réception de la réponse
		DatagramPacket answer = new DatagramPacket(buffer, buffer.length);
		client.receive(answer);
		System.out.println("From server: " + new String(answer.getData()));
		client.close();
	}

}
