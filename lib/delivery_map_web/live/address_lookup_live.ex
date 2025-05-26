defmodule DeliveryMapWeb.AddressLookupLive do
  @moduledoc """
  LiveView for server-side address lookup using Google Places API.
  """
  use DeliveryMapWeb, :live_view

  alias DeliveryMap.GooglePlaces

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", suggestions: [], addresses: [], selected_address: nil, icon_picker_open: nil)}
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
    # Add a default icon to new addresses
    address = Map.put(address, :icon, "red-pin")
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
  def handle_event("change_icon", %{"idx" => idx_str, "icon" => icon}, socket) do
    idx = String.to_integer(idx_str)
    addresses = socket.assigns.addresses || []
    new_addresses = List.update_at(addresses, idx, fn addr -> Map.put(addr, :icon, icon) end)
    {:noreply, assign(socket, addresses: new_addresses, icon_picker_open: nil)}
  end

  @impl true
  def handle_event("toggle_icon_picker", %{"idx" => idx_str}, socket) do
    idx = String.to_integer(idx_str)
    current = socket.assigns[:icon_picker_open]
    new_val = if current == idx, do: nil, else: idx
    {:noreply, assign(socket, icon_picker_open: new_val)}
  end

  @impl true
  def handle_event("delete_address", %{"idx" => idx_str}, socket) do
    idx = String.to_integer(idx_str)
    addresses = socket.assigns.addresses || []
    new_addresses = List.delete_at(addresses, idx)
    {:noreply, assign(socket, addresses: new_addresses)}
  end

  @impl true
  def handle_event("center_address", %{"idx" => idx_str}, socket) do
    idx = String.to_integer(idx_str)
    addresses = socket.assigns.addresses || []
    address = Enum.at(addresses, idx)
    {:noreply, assign(socket, selected_address: address)}
  end

  @impl true
  def handle_event("clear_query", _params, socket) do
    {:noreply, assign(socket, query: "", suggestions: [])}
  end

  @impl true
  def handle_event("map_add_address", %{"lat" => lat, "lng" => lng}, socket) do
    # Use reverse geocoding to get the address string
    address_str = DeliveryMap.GooglePlaces.reverse_geocode(lat, lng) || "(Unknown address)"
    address = %{
      address: address_str,
      lat: lat,
      lng: lng,
      icon: "red-pin"
    }
    addresses = (socket.assigns.addresses || []) ++ [address]
    {:noreply, assign(socket, addresses: addresses)}
  end

  defp address_card(assigns) do
    icon_picker_open = Map.get(assigns, :icon_picker_open, nil)
    icons = [
      {"red-pin", "<svg width='24' height='24' viewBox='0 0 24 24' fill='red'><circle cx='12' cy='12' r='10'/></svg>"},
      {"blue-pin", "<svg width='24' height='24' viewBox='0 0 24 24' fill='blue'><circle cx='12' cy='12' r='10'/></svg>"},
      {"green-pin", "<svg width='24' height='24' viewBox='0 0 24 24' fill='green'><circle cx='12' cy='12' r='10'/></svg>"},
      {"star", "<svg width='24' height='24' viewBox='0 0 24 24' fill='gold'><polygon points='12,2 15,10 23,10 17,15 19,23 12,18 5,23 7,15 1,10 9,10'/></svg>"},
      {"flag", "<svg width='24' height='24' viewBox='0 0 24 24'><rect x='4' y='4' width='4' height='16' fill='gray'/><rect x='8' y='4' width='12' height='8' fill='red'/></svg>"}
    ]

    ~H"""
    <div class="flex items-start justify-between bg-white border border-gray-200 rounded-lg shadow-sm p-5 hover:shadow-md transition-shadow">
      <div class="flex-1 space-y-1 text-base">
        <%= for {key, value} <- Map.to_list(@address) do %>
          <div><span class="font-bold"><%= key %>:</span> <%= value %></div>
        <% end %>
      </div>
      <div class="flex flex-col gap-2 ml-6">
        <button
          type="button"
          phx-click="center_address"
          phx-value-idx={@index}
          title="Center map on this address"
          class="px-3 py-1 rounded bg-blue-500 hover:bg-blue-600 text-white font-medium text-sm mb-1"
        >
          Select
        </button>
        <div class="relative">
          <button
            type="button"
            class="px-3 py-1 rounded bg-gray-200 hover:bg-gray-300 text-gray-800 font-medium text-sm mb-1"
            phx-click="toggle_icon_picker"
            phx-value-idx={@index}
          >
            Icon
          </button>
          <%= if icon_picker_open == @index do %>
            <div class="absolute z-10 bg-white border border-gray-300 rounded shadow-md mt-1 p-2 flex gap-2">
              <%= for {icon_key, svg} <- icons do %>
                <button
                  type="button"
                  phx-click="change_icon"
                  phx-value-idx={@index}
                  phx-value-icon={icon_key}
                  class={"p-1 border-2 rounded " <> if @address.icon == icon_key, do: "border-blue-500", else: "border-transparent"}
                  title={icon_key}
                  style="background: none;"
                >
                  {Phoenix.HTML.raw(svg)}
                </button>
              <% end %>
            </div>
          <% end %>
        </div>
        <button
          type="button"
          phx-click="delete_address"
          phx-value-idx={@index}
          title="Remove address"
          class="text-red-600 hover:text-red-800 text-2xl font-bold leading-none focus:outline-none"
        >
          ✕
        </button>
      </div>
    </div>
    """
  end
end
