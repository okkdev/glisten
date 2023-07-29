import gleam/bit_builder.{BitBuilder}
import gleam/dynamic.{Dynamic}
import gleam/erlang/atom.{Atom}
import gleam/erlang/process.{Pid}
import gleam/list
import gleam/map
import glisten/socket.{ListenSocket, Socket, SocketReason}
import glisten/socket/options

@external(erlang, "ssl_ffi", "controlling_process")
pub fn controlling_process(socket: Socket, pid: Pid) -> Result(Nil, Atom)

@external(erlang, "ssl", "listen")
fn do_listen(
  port: Int,
  options: List(options.TcpOption),
) -> Result(ListenSocket, SocketReason)

@external(erlang, "ssl", "transport_accept")
pub fn accept_timeout(
  socket: ListenSocket,
  timeout: Int,
) -> Result(Socket, SocketReason)

@external(erlang, "ssl", "transport_accept")
pub fn accept(socket: ListenSocket) -> Result(Socket, SocketReason)

@external(erlang, "ssl", "recv")
pub fn receive_timeout(
  socket: Socket,
  length: Int,
  timeout: Int,
) -> Result(BitString, SocketReason)

@external(erlang, "ssl", "recv")
pub fn receive(socket: Socket, length: Int) -> Result(BitString, SocketReason)

@external(erlang, "ssl_ffi", "send")
pub fn send(socket: Socket, packet: BitBuilder) -> Result(Nil, SocketReason)

@external(erlang, "ssl_ffi", "close")
pub fn close(socket: Socket) -> Result(Nil, SocketReason)

@external(erlang, "ssl_ffi", "shutdown")
pub fn do_shutdown(socket: Socket, write: Atom) -> Result(Nil, SocketReason)

pub fn shutdown(socket: Socket) -> Result(Nil, SocketReason) {
  let assert Ok(write) = atom.from_string("write")
  do_shutdown(socket, write)
}

@external(erlang, "ssl_ffi", "set_opts")
fn do_set_opts(socket: Socket, opts: List(Dynamic)) -> Result(Nil, Nil)

/// Update the optons for a socket (mutates the socket)
pub fn set_opts(
  socket: Socket,
  opts: List(options.TcpOption),
) -> Result(Nil, Nil) {
  opts
  |> options.to_map
  |> map.to_list
  |> list.map(dynamic.from)
  |> do_set_opts(socket, _)
}

@external(erlang, "ssl", "handshake")
pub fn handshake(socket: Socket) -> Result(Socket, Nil)

/// Start listening over SSL on a port with the given options
pub fn listen(
  port: Int,
  options: List(options.TcpOption),
) -> Result(ListenSocket, SocketReason) {
  options
  |> options.merge_with_defaults
  |> do_listen(port, _)
}

@external(erlang, "ssl_ffi", "negotiated_protocol")
pub fn negotiated_protocol(socket: Socket) -> Result(String, String)
