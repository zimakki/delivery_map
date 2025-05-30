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
    raw_address = GooglePlaces.get_address(place_id)
    icon = raw_address["icon"] || icons |> List.first() |> elem(0)
    svg = DeliveryMapWeb.Icons.svg_for(icon)

    address = %DeliveryMap.Address{
      name: raw_address[:name],
      address: raw_address[:address],
      lat: raw_address[:lat],
      lng: raw_address[:lng],
      icon: icon,
      icon_svg: svg,
      place_id: raw_address[:place_id],
      postcode: raw_address[:postcode],
      country: raw_address[:country],
      locality: raw_address[:locality],
      neighborhood: raw_address[:neighborhood],
      administrative_area_level_1: raw_address[:administrative_area_level_1],
      administrative_area_level_2: raw_address[:administrative_area_level_2],
      sublocality: raw_address[:sublocality],
      sublocality_level_1: raw_address[:sublocality_level_1],
      political: raw_address[:political]
    }

    {:noreply,
     assign(socket,
       preview_address: address,
       selected_address: address,
       suggestions: [],
       query: address.address
     )}
  end

  def handle_event("save_preview_address", _params, socket) do
    preview_address = socket.assigns.preview_address
    # Already a struct, but ensure icon is set to "red-pin" if needed
    address = %{
      preview_address
      | icon: "red-pin",
        icon_svg: DeliveryMapWeb.Icons.svg_for("red-pin")
    }

    addresses = (socket.assigns.addresses || []) ++ [address]

    {:noreply,
     assign(socket,
       addresses: addresses,
       preview_address: nil
     )}
  end

  @impl true
  def handle_event("change_icon", %{"idx" => idx_str, "icon" => icon}, socket) do
    idx = String.to_integer(idx_str)
    addresses = socket.assigns.addresses

    new_addresses =
      List.update_at(addresses, idx, fn addr ->
        %{addr | icon: icon, icon_svg: DeliveryMapWeb.Icons.svg_for(icon)}
      end)

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
    icons = socket.assigns.icons || DeliveryMapWeb.Icons.all()
    icon = (address && address.icon) || icons |> List.first() |> elem(0)
    svg = DeliveryMapWeb.Icons.svg_for(icon)
    address = %{(address || %{}) | icon: icon, icon_svg: svg}
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
    icons = socket.assigns.icons || DeliveryMapWeb.Icons.all()

    selected_icon_key =
      case socket.assigns.selected_address do
        %{icon: icon} when not is_nil(icon) -> icon
        _ -> icons |> List.first() |> elem(0)
      end

    selected_icon_svg = DeliveryMapWeb.Icons.svg_for(selected_icon_key)

    address = %DeliveryMap.Address{
      name: address_map["name"],
      address: address_map["address"],
      lat: address_map["lat"] || lat,
      lng: address_map["lng"] || lng,
      icon: selected_icon_key,
      icon_svg: selected_icon_svg,
      place_id: address_map["place_id"],
      postcode: address_map["postcode"],
      country: address_map["country"],
      locality: address_map["locality"],
      neighborhood: address_map["neighborhood"],
      administrative_area_level_1: address_map["administrative_area_level_1"],
      administrative_area_level_2: address_map["administrative_area_level_2"],
      sublocality: address_map["sublocality"],
      sublocality_level_1: address_map["sublocality_level_1"],
      political: address_map["political"]
    }

    addresses = (socket.assigns.addresses || []) ++ [address]
    {:noreply, assign(socket, addresses: addresses)}
  end
end
