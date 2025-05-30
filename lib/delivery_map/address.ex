defmodule DeliveryMap.Address do
  @moduledoc """
  Struct for a normalized address used throughout the DeliveryMap app.
  This struct is based on the fields returned by Google Places and reverse geocoding,
  plus our application-specific fields (icon, icon_svg).
  """

  @enforce_keys [
    :name,
    :address,
    :lat,
    :lng,
    :icon,
    :icon_svg
  ]

  @derive Jason.Encoder
  defstruct [
    # e.g. business or place name
    :name,
    # formatted address string
    :address,
    # latitude (float)
    :lat,
    # longitude (float)
    :lng,
    # icon key (string)
    :icon,
    # SVG markup string for marker
    :icon_svg,
    # Google place_id (string)
    :place_id,
    # postal code (string)
    :postcode,
    # country (string)
    :country,
    # locality/city (string)
    :locality,
    # neighborhood (string)
    :neighborhood,
    # e.g. state/province
    :administrative_area_level_1,
    # e.g. county/district
    :administrative_area_level_2,
    # sublocality (string)
    :sublocality,
    # sublocality level 1 (string)
    :sublocality_level_1,
    # political area (string)
    :political
  ]
  @doc """
  Safely constructs an Address struct from a map with mixed atom/string keys.
  """
  def from_map(map) do
    %__MODULE__{
      name: map[:name] || map["name"],
      address: map[:address] || map["address"],
      lat: map[:lat] || map["lat"],
      lng: map[:lng] || map["lng"],
      icon: map[:icon] || map["icon"],
      icon_svg: map[:icon_svg] || map["icon_svg"],
      place_id: map[:place_id] || map["place_id"],
      postcode: map[:postcode] || map["postcode"],
      country: map[:country] || map["country"],
      locality: map[:locality] || map["locality"],
      neighborhood: map[:neighborhood] || map["neighborhood"],
      administrative_area_level_1: map[:administrative_area_level_1] || map["administrative_area_level_1"],
      administrative_area_level_2: map[:administrative_area_level_2] || map["administrative_area_level_2"],
      sublocality: map[:sublocality] || map["sublocality"],
      sublocality_level_1: map[:sublocality_level_1] || map["sublocality_level_1"],
      political: map[:political] || map["political"]
    }
  end
end
