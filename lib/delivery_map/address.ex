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
end
