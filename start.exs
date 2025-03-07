defmodule RoomServer do
  @port 8080

  def start() do
    {:ok, _pid} = Room.start_link([])

    # Start the ETS table for storing client state
    :ets.new(:client_state, [:named_table, :public, read_concurrency: true])

    {:ok, socket} = :gen_tcp.listen(@port, [:binary, active: false, reuseaddr: true])
    IO.puts("Server listening on port #{@port}")
    accept(socket)
  end

  defp accept(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    spawn(fn -> handle_client(client) end)
    accept(socket)
  end

  defp handle_client(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        data = String.trim(data)
        response =
          case data do
            "rooms" ->
              "Rooms: #{Room.list_rooms() |> inspect()}"
            <<"create ", room::binary>> ->
              room = String.trim(room)
              Room.create_room(room)
              "Room created: #{room}"
            <<"join ", room::binary>> ->
                room = String.trim(room)
                player_id = System.unique_integer([:positive])
                Room.join_room(room, player_id, socket)
                :ets.insert(:client_state, {socket, %{current_room: room, current_player: player_id}})
                "Joined room #{room} as player #{player_id}"
            "leave" ->
                case :ets.lookup(:client_state, socket) do
                    [{_, %{current_room: current_room, current_player: current_player}}] ->
                        Room.remove_player(current_room, current_player)
                        :ets.delete(:client_state, socket)
                        "Left room #{current_room}"
                    _ ->
                        "You are not in any room"
                end
            <<"room_players ", room::binary>> ->
              room = String.trim(room)
              "Players in room #{room}: #{Room.get_room_players(room) |> inspect()}"
            <<"msg ", message::binary>> ->
                message = String.trim(message)
                case :ets.lookup(:client_state, socket) do
                    [{_, %{current_room: room, current_player: current_player}}] ->
                        Room.broadcast_room_message(room, message, current_player, socket)
                        "Message sent to room #{room}: #{message}"
                    _ ->
                        "You must join a room first"
                end
            "help" ->
                """
                Available commands:
                rooms                      - List all available rooms.
                create <room>         - Create a new room.
                join <room>           - Join a room.
                leave                 - Leave the currently joined room.
                room_players <room>        - List players in a room.
                msg <message>              - Send a message to the joined room.
                """

            _ ->
              "Unknown command. Type 'help' for available commands."
        end

        :gen_tcp.send(socket, response <> "\n")
        handle_client(socket)
      {:error, :closed} ->
        :ets.delete(:client_state, socket)
        :ok
      _ ->
        :ok
    end
  end
end

RoomServer.start()
