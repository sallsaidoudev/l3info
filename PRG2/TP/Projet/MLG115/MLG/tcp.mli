(* This file is part of MLGame (OCaml Game System).

   MLGame is free software; you can redistribute it and/or modify it under the
   terms of the GNU General Public License as published by the Free Software
   Foundation; either version 2 of the License, or (at your option) any later
   version.

   MLGame is distributed in the hope that it will be useful, but WITHOUT ANY
   WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
   FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
   details.

   You should have received a copy of the GNU General Public License along
   with MLGame; if not, write to the Free Software Foundation, Inc., 59 Temple
   Place, Suite 330, Boston, MA 02111-1307 USA *)

(** Module with simple TCP interface. 

   {!Tcp.socket}'s should not be compared, since on some systems 
   (eg. Windows) such a comparison may fail. If comparison is 
   required see {!Socket.t}.

   On a client there should be a single socket for every server. On a
   server for every one waiting for new connections (Created by 
   {!Tcp.create_socket}) there are some connected to every client.

   Every TCP socket is full duplex. *)

(** Type reperesenting a single inbound or outbound connection.  *)
type socket;;

(** Exception raised when a connection is lost. It is only raised by
   {!Tcp.read} and {!Tcp.write} operations. *)
exception Lost;;

(** Exception raised when the requested operation cannon be
   currently completed by the operating system *) 
exception Error of string;;

(** [create_socket port client_limit] should be called on the server
   to create a socket waiting for new clients. The clients should
   then connect to the given [port]. [client_limit] is the limit
   for clients that are trying to connect at the same time. This is
   not the limit of connected clients, but the limit for clients trying
   to connect until {!Tcp.check_socket} is called. *)
val create_socket : int -> int -> socket;;

(** [check_socket socket] should be called only on the server on a socket
   created by {!Tcp.create_socket}. It returns a list of new sockets, one for
   every new connected client. *)
val check_socket : socket -> socket list;;

(** [connect hostname port] When called on a client it tries to connect to
   the given server and [port] and returns connected socket or throws
   Not_available *)
val connect : string -> int -> socket;;

(** [write socket str pos len] Just like Unix.write *)
val write : socket -> string -> int -> int -> string;;

(** [read socket] may return an empty list *)
val read : socket -> string list;;

(** [force_read socket] blocking *)
val force_read : socket -> string;;

(** [close socket] when called on the client disconnects from the server,
   when called on the server on a created socket it stops accepting client 
   and when called on the server with a socket from a client it closes the
   connection to the client (to the client it looks like the connection
   has been lost). *)
val close : socket -> unit;;
