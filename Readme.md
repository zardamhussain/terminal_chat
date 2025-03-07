# Simple Chat Server with ETS

This is a simple chat server built in Elixir that uses TCP connections to allow clients to create, join, leave chat rooms, and exchange messages. The server is built using GenServer to manage room state and uses an ETS table to store each client's current room and player ID.

## Features

- **List Rooms:** View all available chat rooms.
- **Create Room:** Create a new chat room.
- **Join Room:** Join a chat room (binds the client to that room).
- **Send Message:** Send messages to the current room without having to specify the room name each time.
- **Leave Room:** Leave the current chat room.
- **View Room Players:** List players in a specific room.
- **Help:** Display available commands.

## Requirements

- Elixir (version 1.12 or later recommended)
- Erlang/OTP

## Getting Started

### Clone and Compile

1. **Clone the repository:**

   ```bash
   git clone https://github.com/zardamhussain/terminal_chat.git
   cd terminal_chat
   ```

2. **Compile and Run the project:**

   ```bash
   elixirc lib/room.ex start.exs
   ```

### Running the Server


The server will listen on TCP port `8080`.

## Usage

You can use any TCP client (such as `telnet` or `nc`) to connect to the server. For example, using `telnet`:

```bash
telnet localhost 8080
```

Once connected, you can issue the following commands:

- **rooms**  
  Lists all available chat rooms.
  
  ```
  rooms
  ```

- **create <room>**  
  Creates a new chat room.
  
  ```
  create general
  ```

- **join <room>**  
  Joins an existing room and binds the client’s state.  
  (After joining, you no longer need to specify the room with every message.)
  
  ```
  join general
  ```

- **msg <message>**  
  Sends a message to the currently joined room.
  
  ```
  msg Hello everyone!
  ```

- **leave**  
  Leaves the current room and clears the client’s state.
  
  ```
  leave
  ```

- **room_players <room>**  
  Lists all players in the specified room.
  
  ```
  room_players general
  ```

- **help**  
  Displays a list of available commands.
  
  ```
  help
  ```

### Example Session

```
rooms
create general
join general
msg Hello everyone!
room_players general
leave
```

## Project Structure

- **lib/room_server.ex:**  
  Contains the TCP server implementation, command parsing logic, and ETS-based state management.

- **lib/room.ex:**  
  Contains the GenServer logic for managing chat rooms and broadcasting messages.


## ETS State Management

An ETS table named `:client_state` is created at server startup to track each connected client’s state (their current room and player ID). When a client issues the `"join"` command, their state is stored in ETS; when they send a `"msg"` command or `"leave"`, the ETS table is consulted and updated accordingly.
