defmodule DeliveryMapWeb.ReactLive do
  @moduledoc false
  use DeliveryMapWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.react name="Simple" />
    """
  end
end
