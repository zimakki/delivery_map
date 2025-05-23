defmodule DeliveryMapWeb.AddressLookupLive do
  @moduledoc """
  LiveView for server-side address lookup using Google Places API.
  """
  use DeliveryMapWeb, :live_view

  alias DeliveryMapWeb.AddressLookupLive.GooglePlaces

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       query: "",
       suggestions: [],
       selected_address: nil,
       loading: false
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
  def handle_event("noop", %{"query" => query}, socket) do
    suggestions =
      if String.length(query) > 2 do
        GooglePlaces.autocomplete(query)
      else
        []
      end

    {:noreply, assign(socket, query: query, suggestions: suggestions)}
  end

  @impl true
  def handle_event("select_address", %{"place_id" => place_id}, socket) do
    address = GooglePlaces.get_address(place_id)
    {:noreply, assign(socket, selected_address: address, suggestions: [], query: address)}
  end
end

# Helper module for Google Places API integration
# Place your Google API key in config :delivery_map, :google_maps_api_key
# Example: config :delivery_map, :google_maps_api_key, "YOUR_API_KEY"
defmodule DeliveryMapWeb.AddressLookupLive.GooglePlaces do
  @moduledoc """
  Helper module for Google Places API integration.
  """
  @autocomplete_url "https://maps.googleapis.com/maps/api/place/autocomplete/json"
  @details_url "https://maps.googleapis.com/maps/api/place/details/json"

  def autocomplete(query) do
    key = Application.get_env(:delivery_map, :google_maps_api_key) || "YOUR_API_KEY"

    params =
      URI.encode_query(%{
        input: query,
        key: key
      })

    url = "#{@autocomplete_url}?#{params}"

    case Req.get(url) do
      {:ok, %{body: %{"predictions" => preds}}} ->
        Enum.map(preds, fn pred ->
          %{description: pred["description"], place_id: pred["place_id"]}
        end)

      _ ->
        []
    end
  end

  def get_address(place_id) do
    key = Application.get_env(:delivery_map, :google_maps_api_key) || "YOUR_API_KEY"

    params =
      URI.encode_query(%{
        place_id: place_id,
        key: key,
        fields: "formatted_address"
      })

    url = "#{@details_url}?#{params}"

    case Req.get(url) do
      {:ok, %{body: %{"result" => %{"formatted_address" => addr}}}} -> addr
      _ -> nil
    end
  end
end
