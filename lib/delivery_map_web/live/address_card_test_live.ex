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
       index: 0
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.address_card address={@test_address} index={@index} icon_picker_open={@icon_picker_open} />
    <.address_card address={@test_address} index={@index} icon_picker_open={@icon_picker_open} />
    """
  end

  @impl true
  def handle_event("toggle_icon_picker", %{"idx" => idx_str}, socket) do
    idx = String.to_integer(idx_str)
    current = socket.assigns[:icon_picker_open]
    new_val = if current == idx, do: nil, else: idx
    {:noreply, assign(socket, icon_picker_open: new_val)}
  end

  @impl true
  def handle_event("change_icon", %{"idx" => _idx_str, "icon" => icon}, socket) do
    # For demo, just update the test_address icon
    {:noreply, assign(socket, test_address: Map.put(socket.assigns.test_address, :icon, icon))}
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
