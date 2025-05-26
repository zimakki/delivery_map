defmodule DeliveryMapWeb.AddressLookupLive do
  @moduledoc """
  LiveView for server-side address lookup using Google Places API.
  """
  use DeliveryMapWeb, :live_view

  alias DeliveryMap.GooglePlaces

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       query: "",
       suggestions: [],
       selected_address: nil,
       addresses: [],
       loading: false
     )}
  end

  @impl true
  def handle_event("suggest", %{"query" => query}, socket) do
    suggestions =
      if String.length(query) > 2 do
        GooglePlaces.autocomplete(query)
      else
        []
      end

    {:noreply, assign(socket, query: query, suggestions: suggestions)}
  end

  @impl true
  def handle_event("submit", %{"query" => query}, socket) do
    suggestions =
      if String.length(query) > 2 do
        GooglePlaces.autocomplete(query)
      else
        []
      end

    {:noreply, assign(socket, query: query, suggestions: suggestions)}
  end

  @impl true
  def handle_event("select_address", %{"place_id" => place_id}, socket) do
    address = GooglePlaces.get_address(place_id)
    addresses = (socket.assigns.addresses || []) ++ [address]

    {:noreply,
     assign(socket,
       selected_address: address,
       addresses: addresses,
       suggestions: [],
       query: address && address.address
     )}
  end

  @impl true
  def handle_event("delete_address", %{"idx" => idx_str}, socket) do
    idx = String.to_integer(idx_str)
    addresses = socket.assigns.addresses || []
    new_addresses = List.delete_at(addresses, idx)
    {:noreply, assign(socket, addresses: new_addresses)}
  end

  defp address_card(assigns) do
    ~H"""
    <div class="flex items-start justify-between bg-white border border-gray-200 rounded-lg shadow-sm p-5 hover:shadow-md transition-shadow">
      <div class="flex-1 space-y-1 text-base">
        <div><span class="font-bold">Address:</span> {@address.address}</div>
        <div><span class="font-bold">Latitude:</span> {@address.lat}</div>
        <div><span class="font-bold">Longitude:</span> {@address.lng}</div>
      </div>
      <button
        type="button"
        phx-click="delete_address"
        phx-value-idx={@index}
        title="Remove address"
        class="ml-6 text-red-600 hover:text-red-800 text-2xl font-bold leading-none focus:outline-none"
      >
        ✕
      </button>
    </div>
    """
  end
end
