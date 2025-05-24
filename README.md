# DeliveryMap

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## TypeScript & IDE Setup

If you see IDE or TypeScript errors like:
- `Cannot find module 'phoenix' or its corresponding type declarations.`
- `Cannot find module 'phoenix_live_view' or its corresponding type declarations.`
- `Cannot find namespace 'google'.`

You need to install the following dependencies:

```sh
npm install phoenix phoenix_live_view
npm install --save-dev @types/phoenix @types/phoenix_live_view @types/google.maps
```

If you use Google Maps in your TypeScript code, add this line at the top of any file that references `google.maps`:

```typescript
/// <reference types="google.maps" />
```

If you assign custom properties to `window` (like `window.liveSocket`), extend the Window interface in your code or in a `global.d.ts` file:

```typescript
declare global {
  interface Window {
    liveSocket: any;
    google: typeof google;
    _googleMapsLoading?: boolean;
  }
}
```

After installing dependencies, restart your IDE or TypeScript server if errors persist.

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
