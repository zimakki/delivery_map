defmodule DeliveryMapWeb.Icons do
  @moduledoc """
  Central module for all SVG icons used in the DeliveryMap web app.
  Provides a canonical list of icon keys and their SVG markup.
  """

  @icons [
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
  ]

  @doc """
  Returns the list of {icon_key, svg} tuples.
  """
  def all, do: @icons

  @doc """
  Get SVG for a given icon key. Returns nil if not found.
  """
  def svg_for(key) do
    Enum.find_value(@icons, fn {k, svg} -> if k == key, do: svg end)
  end
end
