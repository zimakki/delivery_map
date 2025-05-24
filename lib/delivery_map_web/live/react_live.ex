defmodule DeliveryMapWeb.ReactLive do
  @moduledoc false
  use DeliveryMapWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.react name="Simple" />
    <.react
      name="GoogleMap"
      SSR={false}
      lat={51.5074}
      lng={-0.1278}
      mapId="562979e6b1924bed501ab419"
      zoom={14}
    />
    """
  end
end
