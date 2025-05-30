defmodule DeliveryMapWeb.AddressLookupLive do
  @moduledoc """
  LiveView for server-side address lookup using Google Places API.
  """
  use DeliveryMapWeb, :live_view

  import DeliveryMapWeb.AddressLookupLive.Components

  alias DeliveryMap.GooglePlaces

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       query: "",
       suggestions: [],
       addresses: [],
       selected_address: nil,
       icon_picker_open: nil,
       preview_address: nil
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
  def handle_event("select_address", %{"place_id" => place_id} = _params, socket) do
    address = GooglePlaces.get_address(place_id)
    address = Map.put(address, :icon, "blue-pin")

    {:noreply,
     assign(socket,
       preview_address: address,
       selected_address: address,
       suggestions: [],
       query: address && address.address
     )}
  end

  def handle_event("save_preview_address", _params, socket) do
    preview_address = socket.assigns.preview_address
    addresses = (socket.assigns.addresses || []) ++ [Map.put(preview_address, :icon, "red-pin")]

    {:noreply,
     assign(socket,
       addresses: addresses,
       preview_address: nil
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
    # Use reverse geocoding to get the full address map
    address_map = GooglePlaces.reverse_geocode(lat, lng) || %{}
    # Merge in the icon field (and ensure lat/lng are present)
    address = Map.merge(address_map, %{icon: "red-pin", lat: lat, lng: lng})
    addresses = (socket.assigns.addresses || []) ++ [address]
    {:noreply, assign(socket, addresses: addresses)}
  end
end
