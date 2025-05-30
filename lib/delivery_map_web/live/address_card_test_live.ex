defmodule DeliveryMapWeb.AddressCardTestLive do
  @moduledoc false
  use DeliveryMapWeb, :live_view

  import DeliveryMapWeb.AddressLookupLive.Components

  # Example address for testing
  @test_address %{
    name: "Test Cafe",
    address: "123 Test St, Test City, 12345, Testland",
    lat: 41.3898957,
    lng: 2.1792499,
    postcode: "12345",
    icon: "red-pin",
    country: "Testland",
    locality: "Test City"
  }

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       test_address: @test_address,
       icon_picker_open: nil,
       index: 0,
       selected_icon: nil,
       icons: DeliveryMapWeb.Icons.all()
     )}
  end

  @impl true
  def render(assigns) do
    selected_icon = assigns[:selected_icon]
    assigns = Map.put(assigns, :selected_icon, selected_icon)

    ~H"""
    <.address_card
      address={@test_address}
      index={@index}
      icon_picker_open={@icon_picker_open}
      selected_icon={@selected_icon}
    />
    <.address_card
      address={@test_address}
      index={@index}
      icon_picker_open={@icon_picker_open}
      selected_icon={@selected_icon}
    />
    """
  end

  @impl true
  def handle_event("toggle_icon_picker", %{"idx" => idx_str}, socket) do
    idx = String.to_integer(idx_str)
    current = socket.assigns[:icon_picker_open]
    new_val = if current == idx, do: nil, else: idx

    # Find current icon SVG for the address
    address = socket.assigns.test_address
    icon_key = Map.get(address, :icon) || Map.get(address, "icon")

    selected_icon =
      Enum.find_value(socket.assigns.icons, fn {k, svg} -> if k == icon_key, do: svg end)

    {:noreply, assign(socket, icon_picker_open: new_val, selected_icon: selected_icon)}
  end

  @impl true
  def handle_event("change_icon", %{"idx" => _idx_str, "icon" => icon}, socket) do
    # For demo, update the test_address icon and selected_icon
    selected_icon =
      Enum.find_value(socket.assigns.icons, fn {k, svg} -> if k == icon, do: svg end)

    {:noreply,
     assign(socket,
       test_address: Map.put(socket.assigns.test_address, :icon, icon),
       selected_icon: selected_icon,
       icon_picker_open: nil
     )}
  end

  @impl true
  def handle_event("delete_address", _params, socket) do
    # For demo, just clear the test address
    {:noreply, assign(socket, test_address: nil)}
  end

  @impl true
  def handle_event("center_address", _params, socket) do
    # No-op for demo
    {:noreply, socket}
  end
end
