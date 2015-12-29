use Mix.Config

# Configure your database
config :auction_server, AuctionServer.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "auctioneer_dev",
  hostname: "localhost",
  pool_size: 10
