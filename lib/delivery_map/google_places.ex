defmodule DeliveryMap.GooglePlaces do
  @moduledoc """
  Helper module for Google Places API integration.
  """
  @autocomplete_url "https://maps.googleapis.com/maps/api/place/autocomplete/json"
  @details_url "https://maps.googleapis.com/maps/api/place/details/json"

  def autocomplete(query) do
    key = Application.get_env(:delivery_map, :google_maps_api_key) || "YOUR_API_KEY"

    params = URI.encode_query(%{input: query, key: key})

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

    params = URI.encode_query(%{
      place_id: place_id,
      key: key,
      fields: "formatted_address,geometry"
    })

    url = "#{@details_url}?#{params}"

    case Req.get(url) do
      {:ok, %{body: %{"result" => %{"formatted_address" => addr, "geometry" => %{"location" => %{"lat" => lat, "lng" => lng}}}}}} ->
        %{address: addr, lat: lat, lng: lng}
      _ ->
        nil
    end
  end

  def reverse_geocode(lat, lng) do
    key = Application.get_env(:delivery_map, :google_maps_api_key) || "YOUR_API_KEY"
    params = URI.encode_query(%{
      latlng: "#{lat},#{lng}",
      key: key
    })
    url = "https://maps.googleapis.com/maps/api/geocode/json?#{params}"
    case Req.get(url) do
      {:ok, %{body: %{"results" => [%{"formatted_address" => addr} | _]}}} ->
        addr
      _ ->
        nil
    end
  end
end
