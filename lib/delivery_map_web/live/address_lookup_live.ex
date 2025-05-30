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
    suggestions = GooglePlaces.autocomplete(query)
    {:noreply, assign(socket, query: query, suggestions: suggestions)}
  end

  @impl true
  def handle_event("submit", %{"query" => query}, socket) do
    suggestions = GooglePlaces.autocomplete(query)
    {:noreply, assign(socket, query: query, suggestions: suggestions)}
  end

  @impl true
  def handle_event("select_address", %{"place_id" => place_id} = _params, socket) do
    raw_address = GooglePlaces.get_address(place_id)
    icon = socket.assigns.icons |> List.first() |> elem(0)

    address =
      DeliveryMap.Address.from_map(
        Map.merge(
          raw_address,
          %{icon: icon, icon_svg: DeliveryMapWeb.Icons.svg_for(icon)}
        )
      )

    {:noreply,
     assign(socket,
       preview_address: address,
       selected_address: address,
       suggestions: [],
       query: address.address
     )}
  end

  def handle_event("save_preview_address", _params, socket) do
    # Already a struct, but ensure icon is set to "red-pin" if needed
    address = %{
      socket.assigns.preview_address
      | icon: "red-pin",
        icon_svg: DeliveryMapWeb.Icons.svg_for("red-pin")
    }

    addresses = [address | socket.assigns.addresses]

    {:noreply, assign(socket, addresses: addresses, preview_address: nil)}
  end

  @impl true
  def handle_event("change_icon", %{"idx" => idx_str, "icon" => icon}, socket) do
    idx = String.to_integer(idx_str)

    new_addresses =
      List.update_at(socket.assigns.addresses, idx, fn addr ->
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

    address = Enum.at(socket.assigns.addresses, idx)
    {:noreply, assign(socket, selected_address: address)}
  end

  @impl true
  def handle_event("clear_query", _params, socket) do
    {:noreply, assign(socket, query: "", suggestions: [])}
  end
end
