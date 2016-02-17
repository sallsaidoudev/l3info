import java.io.*;
import java.net.*;
import java.util.Date;

public class PingClient {

    private static byte[] buffer = new byte[1024];

    public static void main(String[] args) throws IOException {
        DatagramSocket socket = new DatagramSocket(); // Socket client
        socket.setSoTimeout(1000); // Timeout d'une seconde
        InetAddress ip = InetAddress.getByName("localhost"); // Adresse à atteindre
        int cpt = 0; // Nombre de pings reçus
        int tt = 0; // Temps de voyage total
        for (int i=0; i<10; i++) {
            // Envoi d'un ping
            Date then = new Date();
            buffer = ("PING "+i+" "+(then.getTime())+" \n").getBytes();
            socket.send(new DatagramPacket(buffer, buffer.length, ip, 8080));
            // Réception de la réponse
            DatagramPacket answer = new DatagramPacket(buffer, buffer.length);
            try {
                socket.receive(answer);
            } catch (SocketTimeoutException e) {
                System.out.println("Timeout");
                continue;
            }
            // Analyse de la réponse
            String[] infos = (new String(answer.getData())).split(" ");
            int seq = Integer.parseInt(infos[1]);
            int rtt = (int) ((new Date()).getTime() - Long.parseLong(infos[2]));
            System.out.println("Server at "+ip+" answered for request "+seq+" in "+rtt+"ms");
            cpt++;
            tt += rtt;
        }
        socket.close();
        System.out.println("10 packets transmitted, "+cpt+" received, "+((10-cpt)*10)+"% lost");
        System.out.println("RTT average: "+((float) tt/cpt));
    }

}
