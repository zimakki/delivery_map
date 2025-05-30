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
  def render(assigns) do
    # Ensure selected_icon is always set to the SVG for the test_address's icon if not present
    selected_icon =
      assigns[:selected_icon] ||
        (
          icon_key = Map.get(assigns.test_address, :icon) || Map.get(assigns.test_address, "icon")

          Enum.find_value(assigns.icons, fn {k, svg} -> if k == icon_key, do: svg end)
        )

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
