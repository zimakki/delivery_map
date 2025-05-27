defmodule DeliveryMapWeb.AddressLookupLive.Components do
  @moduledoc false
  use Phoenix.Component
  use Gettext, backend: DeliveryMapWeb.Gettext

  attr :address, :map, required: true, doc: "The address data to display"
  attr :index, :integer, default: 0, doc: "Index of the address in the list"
  attr :icon_picker_open, :boolean, default: false

  def address_card(assigns) do
    assigns = Map.new(assigns)
    assigns = Map.put_new(assigns, :icon_picker_open, Map.get(assigns, :icon_picker_open, nil))

    assigns =
      Map.put_new(assigns, :icons, [
        {"red-pin", "<svg width='24' height='24' viewBox='0 0 24 24' fill='red'><circle cx='12' cy='12' r='10'/></svg>"},
        {"blue-pin",
         "<svg width='24' height='24' viewBox='0 0 24 24' fill='blue'><circle cx='12' cy='12' r='10'/></svg>"},
        {"green-pin",
         "<svg width='24' height='24' viewBox='0 0 24 24' fill='green'><circle cx='12' cy='12' r='10'/></svg>"},
        {"star",
         "<svg width='24' height='24' viewBox='0 0 24 24' fill='gold'><polygon points='12,2 15,10 23,10 17,15 19,23 12,18 5,23 7,15 1,10 9,10'/></svg>"},
        {"flag",
         "<svg width='24' height='24' viewBox='0 0 24 24'><rect x='4' y='4' width='4' height='16' fill='gray'/><rect x='8' y='4' width='12' height='8' fill='red'/></svg>"}
      ])

    ~H"""
    <div class="bg-white shadow-xl rounded-xl p-4 w-full relative">
      <button
        aria-label="Delete item"
        phx-click="delete_address"
        phx-value-idx={@index}
        class="absolute top-2.5 right-2.5 text-gray-400 hover:text-red-600 p-1.5 rounded-full hover:bg-red-50 transition-colors duration-150 ease-in-out z-10"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="2"
          stroke="currentColor"
          class="w-5 h-5"
        >
          <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
        </svg>
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

      <div class="mt-3 pt-3 border-t border-gray-200 flex items-center justify-start space-x-2.5">
        <button
          aria-label="Select"
          phx-click="center_address"
          phx-value-idx={@index}
          class="text-blue-600 hover:text-blue-700 bg-blue-50 hover:bg-blue-100 p-2 rounded-lg shadow-sm border border-blue-200 transition-all duration-150 ease-in-out focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
            class="w-5 h-5"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
        </button>
        <a
          aria-label="Navigate"
          href={"https://www.google.com/maps/dir/?api=1&destination=" <> (to_string(Map.get(@address, :lat) || Map.get(@address, "lat") || "") <> "," <> to_string(Map.get(@address, :lng) || Map.get(@address, "lng") || ""))}
          target="_blank"
          rel="noopener noreferrer"
          class="text-gray-600 hover:text-gray-800 bg-gray-50 hover:bg-gray-100 p-2 rounded-lg shadow-sm border border-gray-200 transition-all duration-150 ease-in-out focus:outline-none focus:ring-2 focus:ring-gray-400"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
            class="w-5 h-5 transform -rotate-45"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M6 12L3.269 3.126A59.768 59.768 0 0121.485 12 59.77 59.77 0 013.27 20.876L5.999 12zm0 0h7.5"
            />
          </svg>
        </a>
        <button
          aria-label="Change Icon"
          phx-click="toggle_icon_picker"
          phx-value-idx={@index}
          class="text-gray-600 hover:text-gray-800 bg-gray-50 hover:bg-gray-100 p-2 rounded-lg shadow-sm border border-gray-200 transition-all duration-150 ease-in-out focus:outline-none focus:ring-2 focus:ring-gray-400"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
            class="w-5 h-5"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M2.25 15.75l5.159-5.159a2.25 2.25 0 013.182 0l5.159 5.159m-1.5-1.5l1.409-1.409a2.25 2.25 0 013.182 0l2.909 2.909m-18 3.75h16.5a1.5 1.5 0 001.5-1.5V6a1.5 1.5 0 00-1.5-1.5H3.75A1.5 1.5 0 002.25 6v12a1.5 1.5 0 001.5 1.5zm10.5-11.25h.008v.008h-.008V8.25zm.375 0a.375.375 0 11-.75 0 .375.375 0 01.75 0z"
            />
          </svg>
        </button>
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
end
