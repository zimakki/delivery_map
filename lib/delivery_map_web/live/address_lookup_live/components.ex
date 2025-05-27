defmodule DeliveryMapWeb.AddressLookupLive.Components do
  @moduledoc false
  use Phoenix.Component
  use Gettext, backend: DeliveryMapWeb.Gettext

  import DeliveryMapWeb.CoreComponents, only: [icon: 1]

  attr :address, :map, required: true, doc: "The address data to display"
  attr :index, :integer, default: 0, doc: "Index of the address in the list"
  attr :icon_picker_open, :boolean, default: false

  def address_card(assigns) do
    assigns = Map.new(assigns)
    assigns = Map.put_new(assigns, :icon_picker_open, Map.get(assigns, :icon_picker_open, nil))

    assigns =
      Map.put_new(assigns, :icons, [
        {"red-pin",
         ~s|<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6 text-red-500"><path stroke-linecap="round" stroke-linejoin="round" d="M15 10.5a3 3 0 11-6 0 3 3 0 016 0z" /><path stroke-linecap="round" stroke-linejoin="round" d="M19.5 10.5c0 7.5-7.5 11.25-7.5 11.25S4.5 18 4.5 10.5a7.5 7.5 0 1115 0z" /></svg>|},
        {"blue-pin",
         ~s|<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6 text-blue-500"><path stroke-linecap="round" stroke-linejoin="round" d="M15 10.5a3 3 0 11-6 0 3 3 0 016 0z" /><path stroke-linecap="round" stroke-linejoin="round" d="M19.5 10.5c0 7.5-7.5 11.25-7.5 11.25S4.5 18 4.5 10.5a7.5 7.5 0 1115 0z" /></svg>|},
        {"green-pin",
         ~s|<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6 text-green-500"><path stroke-linecap="round" stroke-linejoin="round" d="M15 10.5a3 3 0 11-6 0 3 3 0 016 0z" /><path stroke-linecap="round" stroke-linejoin="round" d="M19.5 10.5c0 7.5-7.5 11.25-7.5 11.25S4.5 18 4.5 10.5a7.5 7.5 0 1115 0z" /></svg>|},
        {"star",
         ~s|<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6 text-yellow-400"><path stroke-linecap="round" stroke-linejoin="round" d="M11.48 3.499a.75.75 0 011.04 0l2.348 4.756 5.254.764a.75.75 0 01.416 1.279l-3.8 3.703.897 5.233a.75.75 0 01-1.088.791L12 17.347l-4.703 2.478a.75.75 0 01-1.088-.79l.897-5.234-3.8-3.703a.75.75 0 01.416-1.28l5.254-.763 2.348-4.756z" /></svg>|},
        {"flag",
         ~s|<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6 text-gray-600"><path stroke-linecap="round" stroke-linejoin="round" d="M3 21V5a1 1 0 011-1h13.382a1 1 0 01.894 1.447l-1.382 2.764a1 1 0 000 .894l1.382 2.764A1 1 0 0117.382 13H5a1 1 0 00-1 1v7z" /></svg>|}
      ])

    ~H"""
    <div class="bg-white shadow-xl rounded-xl p-3 w-full relative">
      <button
        aria-label="Delete item"
        phx-click="delete_address"
        phx-value-idx={@index}
        class="absolute top-0 right-0 text-gray-400 hover:text-red-600 p-1.5 rounded-full hover:bg-red-50 transition-colors duration-150 ease-in-out z-10"
      >
        <.icon name="hero-x-mark-solid" class="h-5 w-5" />
      </button>

      <div class="flex items-start space-x-3 mb-3">
        <div class="flex-shrink-0 pt-1">
          <span class="w-3 h-3 bg-red-500 rounded-full block" aria-hidden="true"></span>
        </div>
        <div class="flex-1 min-w-0 pr-8">
          <p
            class="text-sm font-semibold text-gray-900 truncate"
            title={
              to_string(
                Map.get(@address, :name) || Map.get(@address, "name") || Map.get(@address, :address) ||
                  Map.get(@address, "address") || ""
              )
            }
          >
            {Map.get(@address, :name) || Map.get(@address, "name") || Map.get(@address, :address) ||
              Map.get(@address, "address")}
          </p>
          <p
            class="text-xs text-gray-500 truncate"
            title={
              to_string(
                (Map.get(@address, :postcode) || Map.get(@address, "postcode") || "") <>
                  " " <>
                  (Map.get(@address, :locality) || Map.get(@address, "locality") || "") <>
                  ", " <> (Map.get(@address, :country) || Map.get(@address, "country") || "")
              )
            }
          >
            {Map.get(@address, :postcode) || Map.get(@address, "postcode") || ""} {Map.get(
              @address,
              :locality
            ) || Map.get(@address, "locality") || ""}, {Map.get(@address, :country) ||
              Map.get(@address, "country") || ""}
          </p>
          <p
            class="text-xs text-gray-400 truncate"
            title={to_string(Map.get(@address, :address) || Map.get(@address, "address") || "")}
          >
            {Map.get(@address, :address) || Map.get(@address, "address")}
          </p>
        </div>
      </div>

      <div class="border-gray-200 flex items-center justify-start space-x-2.5">
        <.address_card_action_button
          type="button"
          aria_label="Select"
          phx_click="center_address"
          phx_value_idx={@index}
          icon_name="hero-check-circle-solid"
          icon_class="h-5 w-5"
          class="text-blue-600 hover:text-blue-700 bg-blue-50 hover:bg-blue-100 border border-blue-200 focus:ring-blue-500"
        />
        <.address_card_action_button
          type="a"
          aria_label="Navigate"
          href={"https://www.google.com/maps/dir/?api=1&destination=" <> (to_string(Map.get(@address, :lat) || Map.get(@address, "lat") || "") <> "," <> to_string(Map.get(@address, :lng) || Map.get(@address, "lng") || ""))}
          target="_blank"
          rel="noopener noreferrer"
          icon_name="hero-arrow-top-right-on-square-solid"
          icon_class="h-5 w-5 transform -rotate-45"
          class="text-gray-600 hover:text-gray-800 bg-gray-50 hover:bg-gray-100 border border-gray-200 focus:ring-gray-400"
        />
        <.address_card_action_button
          type="button"
          aria_label="Change Icon"
          phx_click="toggle_icon_picker"
          phx_value_idx={@index}
          icon_name="hero-photo-solid"
          icon_class="h-5 w-5"
          class="text-gray-600 hover:text-gray-800 bg-gray-50 hover:bg-gray-100 border border-gray-200 focus:ring-gray-400"
        />
        <%= if @icon_picker_open == @index do %>
          <div class="absolute z-10 bg-white border border-gray-300 rounded shadow-md mt-1 p-2 flex gap-2">
            <%= for {icon_key, svg} <- @icons do %>
              <button
                type="button"
                phx-click="change_icon"
                phx-value-idx={@index}
                phx-value-icon={icon_key}
                class={"p-1 border-2 rounded " <> if (Map.get(@address, :icon) || Map.get(@address, "icon")) == icon_key, do: "border-blue-500", else: "border-transparent"}
                title={icon_key}
                style="background: none;"
              >
                {Phoenix.HTML.raw(svg)}
              </button>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  attr :type, :string, default: "button"
  attr :aria_label, :string, required: true
  attr :icon_name, :string, required: true
  attr :icon_class, :string, default: "h-5 w-5"
  attr :class, :string, default: nil
  attr :phx_click, :string, default: nil
  attr :phx_value_idx, :any, default: nil
  attr :href, :string, default: nil
  attr :target, :string, default: nil
  attr :rel, :string, default: nil

  def address_card_action_button(assigns) do
    assigns =
      assigns
      |> Phoenix.Component.assign_new(:class, fn -> "" end)
      |> Phoenix.Component.assign_new(:icon_class, fn -> "h-5 w-5" end)

    ~H"""
    <%= if @type == "a" do %>
      <a
        aria-label={@aria_label}
        href={@href}
        target={@target}
        rel={@rel}
        class={"flex items-center justify-center w-9 h-9 rounded-lg shadow-sm transition-all duration-150 ease-in-out focus:outline-none " <> (@class || "")}
      >
        <.icon name={@icon_name} class={@icon_class} />
      </a>
    <% else %>
      <button
        type="button"
        aria-label={@aria_label}
        phx-click={@phx_click}
        phx-value-idx={@phx_value_idx}
        class={"flex items-center justify-center w-9 h-9 rounded-lg shadow-sm transition-all duration-150 ease-in-out focus:outline-none " <> (@class || "")}
      >
        <.icon name={@icon_name} class={@icon_class} />
      </button>
    <% end %>
    """
  end
end
