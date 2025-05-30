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
       icons: [
         {"red-pin",
          ~s|<svg xmlns=\"http://www.w3.org/2000/svg\" fill=\"none\" viewBox=\"0 0 24 24\" stroke-width=\"1.5\" stroke=\"currentColor\" class=\"w-6 h-6 text-red-500\"><path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M15 10.5a3 3 0 11-6 0 3 3 0 016 0z\" /><path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M19.5 10.5c0 7.5-7.5 11.25-7.5 11.25S4.5 18 4.5 10.5a7.5 7.5 0 1115 0z\" /></svg>|},
         {"blue-pin",
          ~s|<svg xmlns=\"http://www.w3.org/2000/svg\" fill=\"none\" viewBox=\"0 0 24 24\" stroke-width=\"1.5\" stroke=\"currentColor\" class=\"w-6 h-6 text-blue-500\"><path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M15 10.5a3 3 0 11-6 0 3 3 0 016 0z\" /><path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M19.5 10.5c0 7.5-7.5 11.25-7.5 11.25S4.5 18 4.5 10.5a7.5 7.5 0 1115 0z\" /></svg>|},
         {"green-pin",
          ~s|<svg xmlns=\"http://www.w3.org/2000/svg\" fill=\"none\" viewBox=\"0 0 24 24\" stroke-width=\"1.5\" stroke=\"currentColor\" class=\"w-6 h-6 text-green-500\"><path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M15 10.5a3 3 0 11-6 0 3 3 0 016 0z\" /><path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M19.5 10.5c0 7.5-7.5 11.25-7.5 11.25S4.5 18 4.5 10.5a7.5 7.5 0 1115 0z\" /></svg>|},
         {"star",
          ~s|<svg xmlns=\"http://www.w3.org/2000/svg\" fill=\"none\" viewBox=\"0 0 24 24\" stroke-width=\"1.5\" stroke=\"currentColor\" class=\"w-6 h-6 text-yellow-400\"><path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M11.48 3.499a.75.75 0 011.04 0l2.348 4.756 5.254.764a.75.75 0 01.416 1.279l-3.8 3.703.897 5.233a.75.75 0 01-1.088.791L12 17.347l-4.703 2.478a.75.75 0 01-1.088-.79l.897-5.234-3.8-3.703a.75.75 0 01.416-1.28l5.254-.763 2.348-4.756z\" /></svg>|},
         {"flag",
          ~s|<svg xmlns=\"http://www.w3.org/2000/svg\" fill=\"none\" viewBox=\"0 0 24 24\" stroke-width=\"1.5\" stroke=\"currentColor\" class=\"w-6 h-6 text-gray-600\"><path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M3 21V5a1 1 0 011-1h13.382a1 1 0 01.894 1.447l-1.382 2.764a1 1 0 000 .894l1.382 2.764A1 1 0 0117.382 13H5a1 1 0 00-1 1v7z\" /></svg>|}
       ]
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
