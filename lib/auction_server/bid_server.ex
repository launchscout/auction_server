defmodule AuctionServer.BidServer do
  use GenServer

  alias AuctionServer.Repo
  alias AuctionServer.Bid

  import Ecto.Query, only: [from: 2]

  # Client API

  def start_link(opts \\ []) do
    {:ok, pid} = GenServer.start_link(__MODULE__, [], opts)
  end

  def new_bid(bid_params) do
    GenServer.call(:bid_server, {:new_bid, bid_params})
  end

  def max_bid do
    GenServer.call(:bid_server, {:max_bid, []})
  end

  # Server implementation

  def init([]) do
    bids = Repo.all(Bid)
    {:ok, bids}
  end

  def handle_call({:new_bid, bid_params}, _from, bids) do
    changeset = Bid.changeset(%Bid{}, bid_params)
    case Repo.insert(changeset) do
      {:ok, bid} ->
        Auctioneer.Endpoint.broadcast! "bids:max", "change", Auctioneer.BidView.render("show.json", %{bid: bid})
        {:reply, {:ok, bid}, [bid | bids]}
      {:error, changeset} ->
        {:reply, {:error, changeset}, bids}
    end
  end

  def handle_call({:max_bid, _}, _from, bids) do
    max_amount = Repo.one(from b in Bid, select: max(b.amount))
    max_bid = Repo.one(from b in Bid, where: b.amount == ^max_amount)
    {:reply, {:ok, max_bid}, bids}
  end

end
