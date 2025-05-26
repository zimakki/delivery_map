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
      fields: "formatted_address,geometry,address_components,name"
    })

    url = "#{@details_url}?#{params}"

    case Req.get(url) do
      {:ok, %{body: %{"result" => %{"name" => name, "formatted_address" => addr, "geometry" => %{"location" => %{"lat" => lat, "lng" => lng}}, "address_components" => comps}}}} ->
        postcode =
          comps
          |> Enum.find(fn comp -> "postal_code" in comp["types"] end)
          |> case do
            nil -> nil
            comp -> comp["long_name"]
          end
        # Flatten all address components into a map
        address_parts =
          for comp <- comps, type <- comp["types"], into: %{} do
            {type, comp["long_name"]}
          end
        %{name: name, address: addr, lat: lat, lng: lng, postcode: postcode}
        |> Map.merge(address_parts)
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
      {:ok, %{body: %{"results" => [%{"formatted_address" => addr, "geometry" => %{"location" => %{"lat" => lat, "lng" => lng}}, "address_components" => comps} | _]}}} ->
        postcode =
          comps
          |> Enum.find(fn comp -> "postal_code" in comp["types"] end)
          |> case do
            nil -> nil
            comp -> comp["long_name"]
          end
        address_parts =
          for comp <- comps, type <- comp["types"], into: %{} do
            {type, comp["long_name"]}
          end
        # Try to find a business or POI name
        name =
          comps
          |> Enum.find_value(fn comp ->
            if "point_of_interest" in comp["types"] or "establishment" in comp["types"] do
              comp["long_name"]
            else
              nil
            end
          end)
        %{name: name, address: addr, lat: lat, lng: lng, postcode: postcode}
        |> Map.merge(address_parts)
      _ ->
        nil
    end
  end
end
