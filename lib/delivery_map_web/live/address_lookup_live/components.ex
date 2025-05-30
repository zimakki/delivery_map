defmodule DeliveryMapWeb.AddressLookupLive.Components do
  @moduledoc false
  use Phoenix.Component
  use Gettext, backend: DeliveryMapWeb.Gettext

  import DeliveryMapWeb.CoreComponents, only: [icon: 1]

  attr :address, :map, required: true, doc: "The address data to display"
  attr :index, :integer, default: 0, doc: "Index of the address in the list"
  attr :icon_picker_open, :boolean, default: false
  attr :icons, :list, default: DeliveryMapWeb.Icons.all(), doc: "List of available icons"

  attr :selected_icon, :string,
    required: true,
    doc: "SVG icon to display as selected icon. If nil, shows default red circle."

  def address_card(assigns) do
    assigns = Map.new(assigns)
    assigns = Map.put_new(assigns, :icon_picker_open, Map.get(assigns, :icon_picker_open, nil))

    ~H"""
    <div class="bg-white rounded-xl p-3 relative mt-3">
      <div class="flex items-start space-x-3 mb-3">
        <div class="flex-shrink-0 pt-1">
          {Phoenix.HTML.raw(@selected_icon)}
        </div>
        <div class="flex-1 min-w-0 pr-8">
          <p
            class="text-sm font-semibold text-gray-900 truncate"
            title={to_string(@address.name || @address.address || "")}
          >
            {@address.name || @address.address}
          </p>
          <p
            class="text-xs text-gray-500 truncate"
            title={
              to_string(
                (@address.postcode || "") <>
                  " " <> (@address.locality || "") <> ", " <> (@address.country || "")
              )
            }
          >
            {@address.postcode || ""} {@address.locality || ""}, {@address.country || ""}
          </p>
          <p class="text-xs text-gray-400 truncate" title={to_string(@address.address || "")}>
            {@address.address}
          </p>
        </div>
      </div>

      <div class="absolute top-2.5 right-3 flex items-end space-x-2 -translate-y-1/2 z-20">
        <.address_card_action_button
          type="button"
          aria_label="Select"
          phx_click="center_address"
          phx_value_idx={@index}
          icon_name="hero-arrows-pointing-in"
          icon_class="h-5 w-5"
          class="text-blue-600 hover:text-blue-700 border border-blue-200 focus:ring-blue-500 hover:bg-blue-50 transition-colors duration-150 ease-in-out z-10"
        />
        <.address_card_action_button
          type="a"
          aria_label="Navigate"
          href={"https://www.google.com/maps/dir/?api=1&destination=" <> (to_string(Map.get(@address, :lat) || Map.get(@address, "lat") || "") <> "," <> to_string(Map.get(@address, :lng) || Map.get(@address, "lng") || ""))}
          target="_blank"
          rel="noopener noreferrer"
          icon_name="hero-arrow-top-right-on-square-solid"
          icon_class="h-5 w-5 transform -rotate-45"
          class="text-green-600 hover:text-gray-800 border border-gray-200 focus:ring-green-500 hover:bg-green-50 transition-colors duration-150 ease-in-out z-10"
        />
        <.address_card_action_button
          type="button"
          aria_label="Change Icon"
          phx_click="toggle_icon_picker"
          phx_value_idx={@index}
          icon_name="hero-pencil-square"
          icon_class="size-6"
          class="text-yellow-700 hover:text-gray-800 border border-gray-200 focus:ring-gray-500 hover:bg-yellow-100 transition-colors duration-150 ease-in-out z-10"
        />
        <.address_card_action_button
          type="button"
          aria_label="Delete item"
          phx_click="delete_address"
          phx_value_idx={@index}
          icon_name="hero-x-mark-solid"
          icon_class="h-5 w-5"
          class="text-gray-400 hover:text-red-600 p-1.5 border border-gray-200 focus:ring-gray-500 rounded-full hover:bg-red-50 transition-colors duration-150 ease-in-out z-10"
        />
        <%= if @icon_picker_open == @index do %>
          <div class="fixed z-50 bg-white border border-gray-300 rounded shadow-md mt-1 p-2 flex gap-2">
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
        class={"flex items-center justify-center w-9 h-9 rounded-lg bg-white shadow-sm transition-all duration-150 ease-in-out focus:outline-none " <> (@class || "")}
      >
        <.icon name={@icon_name} class={@icon_class} />
      </a>
    <% else %>
      <button
        type="button"
        aria-label={@aria_label}
        phx-click={@phx_click}
        phx-value-idx={@phx_value_idx}
        class={"flex items-center justify-center w-9 h-9 rounded-lg bg-white shadow-sm transition-all duration-150 ease-in-out focus:outline-none " <> (@class || "")}
      >
        <.icon name={@icon_name} class={@icon_class} />
      </button>
    <% end %>
    """
  end
end
