FROM elixir:latest
WORKDIR /app
COPY . .
EXPOSE 8080
CMD ["elixirc", "lib/room.ex", "start.exs"]
