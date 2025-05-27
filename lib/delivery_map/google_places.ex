defmodule DeliveryMap.GooglePlaces do
  @moduledoc """
  Helper module for Google Places API integration.
  """
  @autocomplete_url "https://maps.googleapis.com/maps/api/place/autocomplete/json"
  @details_url "https://maps.googleapis.com/maps/api/place/details/json"

  def autocomplete(query) do
    params = URI.encode_query(%{input: query, key: api_key()})
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
    fields = "formatted_address,geometry,address_components,name"
    params = URI.encode_query(%{place_id: place_id, key: api_key(), fields: fields})
    url = "#{@details_url}?#{params}"

    resp = Req.get(url)

    case resp do
      {:ok,
       %{
         body: %{
           "result" => %{
             "name" => name,
             "formatted_address" => addr,
             "geometry" => %{"location" => %{"lat" => lat, "lng" => lng}},
             "address_components" => comps
           }
         }
       }} ->
        postcode = get_postcode(comps)
        address_parts = get_address_parts(comps)

        Map.merge(
          %{name: name, address: addr, lat: lat, lng: lng, postcode: postcode},
          address_parts
        )

      _ ->
        nil
    end
  end

  def reverse_geocode(lat, lng) do
    params = URI.encode_query(%{latlng: "#{lat},#{lng}", key: api_key()})
    url = "https://maps.googleapis.com/maps/api/geocode/json?#{params}"

    case Req.get(url) do
      {:ok,
       %{
         body: %{
           "results" => [
             %{
               "formatted_address" => addr,
               "geometry" => %{"location" => %{"lat" => lat, "lng" => lng}},
               "address_components" => comps
             }
             | _
           ]
         }
       }} ->
        postcode = get_postcode(comps)
        address_parts = get_address_parts(comps)
        name = get_name(comps)

        Map.merge(
          %{name: name, address: addr, lat: lat, lng: lng, postcode: postcode},
          address_parts
        )

      _ ->
        nil
    end
  end

  defp get_postcode(comps) do
    comps
    |> Enum.find(fn comp -> "postal_code" in comp["types"] end)
    |> case do
      nil -> nil
      comp -> comp["long_name"]
    end
  end

  defp get_address_parts(comps) do
    for comp <- comps, type <- comp["types"], into: %{} do
      {type, comp["long_name"]}
    end
  end

  defp get_name(comps) do
    Enum.find_value(comps, fn comp ->
      if "point_of_interest" in comp["types"] or "establishment" in comp["types"] do
        comp["long_name"]
      end
    end)
  end

  defp api_key do
    Application.get_env(:delivery_map, :google_maps_api_key) || "YOUR_API_KEY"
  end
end
