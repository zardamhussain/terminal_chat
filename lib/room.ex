defmodule Room do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{rooms: %{}}, name: __MODULE__)
  end

  def init(state), do: {:ok, state}

  def create_room(room_name) do
    GenServer.cast(__MODULE__, {:create_room, room_name})
  end

  def list_rooms() do
    GenServer.call(__MODULE__, :list_rooms)
  end

  def join_room(room_name, player, socket) do
    GenServer.cast(__MODULE__, {:join_room, room_name, player, socket})
  end

  def get_room_players(room_name) do
    GenServer.call(__MODULE__, {:get_room_players, room_name})
  end

  def broadcast_room_message(room_name, message, sender_id, sender_socket) do
    GenServer.cast(__MODULE__, {:broadcast_room, room_name, message, sender_id, sender_socket})
  end

  def remove_player(room_name, player) do
    GenServer.cast(__MODULE__, {:remove_player, room_name, player})
  end

  def handle_call(:list_rooms, _from, state) do
    rooms = Map.keys(state.rooms)
    {:reply, rooms, state}
  end

  def handle_call({:get_room_players, room_name}, _from, state) do
    players = Map.get(state.rooms, room_name, %{})
    {:reply, players, state}
  end

  def handle_cast({:create_room, room_name}, state) do
    new_rooms =
      if Map.has_key?(state.rooms, room_name) do
        state.rooms
      else
        Map.put(state.rooms, room_name, %{})
      end

    {:noreply, %{state | rooms: new_rooms}}
  end

  def handle_cast({:join_room, room_name, player, socket}, state) do
    room = Map.get(state.rooms, room_name, %{})
    new_room = Map.put(room, player, socket)
    new_rooms = Map.put(state.rooms, room_name, new_room)
    {:noreply, %{state | rooms: new_rooms}}
  end

  def handle_cast({:remove_player, room_name, player}, state) do
    room = Map.get(state.rooms, room_name, %{})
    new_room = Map.delete(room, player)
    new_rooms = Map.put(state.rooms, room_name, new_room)
    {:noreply, %{state | rooms: new_rooms}}
  end

  def handle_cast({:broadcast_room, room_name, message, sender_id, sender_socket}, state) do
    room = Map.get(state.rooms, room_name, %{})
    Enum.each(room, fn {_player, socket} ->
      if socket != sender_socket do
        :gen_tcp.send(socket, "[#{room_name}] from #{sender_id}: " <> message <> "\n")
      end
    end)
    {:noreply, state}
  end
end
