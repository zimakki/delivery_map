defmodule DeliveryMap.Secrets do
  use AshAuthentication.Secret

  def secret_for(
        [:authentication, :tokens, :signing_secret],
        DeliveryMap.Accounts.User,
        _opts,
        _context
      ) do
    Application.fetch_env(:delivery_map, :token_signing_secret)
  end
end
