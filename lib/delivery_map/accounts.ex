defmodule DeliveryMap.Accounts do
  @moduledoc false
  use Ash.Domain,
    otp_app: :delivery_map

  resources do
    resource DeliveryMap.Accounts.Token
    resource DeliveryMap.Accounts.User
  end
end
