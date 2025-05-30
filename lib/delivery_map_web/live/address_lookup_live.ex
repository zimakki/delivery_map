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
       preview_address: nil,
       icons: DeliveryMapWeb.Icons.all()
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
    icons = socket.assigns.icons || DeliveryMapWeb.Icons.all()
    address = GooglePlaces.get_address(place_id)
    icon = Map.get(address, :icon) || Map.get(address, "icon") || (icons |> List.first() |> elem(0))
    svg = DeliveryMapWeb.Icons.svg_for(icon)
    address = address |> Map.put(:icon, icon) |> Map.put(:icon_svg, svg)

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

    # Add icon_svg to each address before assigning
    icons = socket.assigns.icons || []

    addresses_with_svg =
      Enum.map(new_addresses, fn addr ->
        icon_key = Map.get(addr, :icon) || Map.get(addr, "icon")
        svg = Enum.find_value(icons, fn {k, svg} -> if k == icon_key, do: svg end)
        Map.put(addr, :icon_svg, svg)
      end)

    {:noreply, assign(socket, addresses: addresses_with_svg, icon_picker_open: nil)}
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
    # Ensure selected_address always has :icon and :icon_svg
    icons = socket.assigns.icons || DeliveryMapWeb.Icons.all()
    icon = Map.get(address || %{}, :icon) || Map.get(address || %{}, "icon") || (icons |> List.first() |> elem(0))
    svg = DeliveryMapWeb.Icons.svg_for(icon)
    address = (address || %{}) |> Map.put(:icon, icon) |> Map.put(:icon_svg, svg)
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
    # Use the selected icon or default to the first available
    icons = socket.assigns.icons || DeliveryMapWeb.Icons.all()
    selected_icon_key =
      case socket.assigns.selected_address do
        %{icon: icon} when not is_nil(icon) -> icon
        _ -> icons |> List.first() |> elem(0)
      end
    selected_icon_svg = DeliveryMapWeb.Icons.svg_for(selected_icon_key)
    address = Map.merge(address_map, %{icon: selected_icon_key, icon_svg: selected_icon_svg, lat: lat, lng: lng})
    addresses = (socket.assigns.addresses || []) ++ [address]
    {:noreply, assign(socket, addresses: addresses)}
  end
end
