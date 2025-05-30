defmodule DeliveryMapWeb.Icons do
  @moduledoc """
  Central module for all SVG icons used in the DeliveryMap web app.
  Provides a canonical list of icon keys and their SVG markup.
  """

  @icons [
    {"red-pin",
     ~s"""
     <svg width="32" height="40" viewBox="0 0 32 40" xmlns="http://www.w3.org/2000/svg">
       <defs>
         <filter id="shadow" x="-50%" y="-50%" width="200%" height="200%">
           <feDropShadow dx="0" dy="2" stdDeviation="2" flood-color="rgba(0,0,0,0.3)"/>
         </filter>
       </defs>
       <!-- Main pin shape -->
       <path d="M16 0C7.163 0 0 7.163 0 16c0 12 16 24 16 24s16-12 16-24C32 7.163 24.837 0 16 0z" fill="#E53E3E" stroke="#fff" stroke-width="1" filter="url(#shadow)"/>
       <!-- Inner circle/dot -->
       <circle cx="16" cy="16" r="6" fill="#fff"/>
     </svg>
     """},
    {"blue-pin",
     ~s"""
     <svg width="32" height="40" viewBox="0 0 32 40" xmlns="http://www.w3.org/2000/svg">
       <defs>
         <filter id="shadow" x="-50%" y="-50%" width="200%" height="200%">
           <feDropShadow dx="0" dy="2" stdDeviation="2" flood-color="rgba(0,0,0,0.3)"/>
         </filter>
       </defs>
       <!-- Main pin shape -->
       <path d="M16 0C7.163 0 0 7.163 0 16c0 12 16 24 16 24s16-12 16-24C32 7.163 24.837 0 16 0z" fill="#3B82F6" stroke="#fff" stroke-width="1" filter="url(#shadow)"/>
       <!-- Inner circle/dot -->
       <circle cx="16" cy="16" r="6" fill="#fff"/>
     </svg>
     """},
    {"green-pin",
     ~s"""
     <svg width="32" height="40" viewBox="0 0 32 40" xmlns="http://www.w3.org/2000/svg">
       <defs>
         <filter id="shadow" x="-50%" y="-50%" width="200%" height="200%">
           <feDropShadow dx="0" dy="2" stdDeviation="2" flood-color="rgba(0,0,0,0.3)"/>
         </filter>
       </defs>
       <!-- Main pin shape -->
       <path d="M16 0C7.163 0 0 7.163 0 16c0 12 16 24 16 24s16-12 16-24C32 7.163 24.837 0 16 0z" fill="#10B981" stroke="#fff" stroke-width="1" filter="url(#shadow)"/>
       <!-- Inner circle/dot -->
       <circle cx="16" cy="16" r="6" fill="#fff"/>
     </svg>
     """},
    {"indigo-pin",
     ~s"""
     <svg width="32" height="40" viewBox="0 0 32 40" xmlns="http://www.w3.org/2000/svg">
       <defs>
         <filter id="shadow" x="-50%" y="-50%" width="200%" height="200%">
           <feDropShadow dx="0" dy="2" stdDeviation="2" flood-color="rgba(0,0,0,0.3)"/>
         </filter>
       </defs>
       <!-- Main pin shape -->
       <path d="M16 0C7.163 0 0 7.163 0 16c0 12 16 24 16 24s16-12 16-24C32 7.163 24.837 0 16 0z" fill="#6366F1" stroke="#fff" stroke-width="1" filter="url(#shadow)"/>
       <!-- Inner circle/dot -->
       <circle cx="16" cy="16" r="6" fill="#fff"/>
     </svg>
     """},
    {"grey-pin",
     ~s"""
     <svg width="32" height="40" viewBox="0 0 32 40" xmlns="http://www.w3.org/2000/svg">
       <defs>
         <filter id="shadow" x="-50%" y="-50%" width="200%" height="200%">
           <feDropShadow dx="0" dy="2" stdDeviation="2" flood-color="rgba(0,0,0,0.3)"/>
         </filter>
       </defs>
       <!-- Main pin shape -->
       <path d="M16 0C7.163 0 0 7.163 0 16c0 12 16 24 16 24s16-12 16-24C32 7.163 24.837 0 16 0z" fill="#6B7280" stroke="#fff" stroke-width="1" filter="url(#shadow)"/>
       <!-- Inner circle/dot -->
       <circle cx="16" cy="16" r="6" fill="#fff"/>
     </svg>
     """}
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
