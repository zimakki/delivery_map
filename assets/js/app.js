// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const Hooks = {};

Hooks.GoogleMap = {
  mounted() {
    console.log("GoogleMap mounted");
    this.handleMap();
  },
  updated() {
    console.log("GoogleMap updated");
    this.handleMap();
  },
  handleMap() {
    console.log("GoogleMap handleMap called", this.el.dataset.lat, this.el.dataset.lng);
    const lat = this.el.dataset.lat || this.el.getAttribute('data-lat') || this.el.__lat;
    const lng = this.el.dataset.lng || this.el.getAttribute('data-lng') || this.el.__lng;
    if (!window.google || !window.google.maps) {
      if (!window._googleMapsLoading) {
        window._googleMapsLoading = true;
        const script = document.createElement('script');
        script.src = `https://maps.googleapis.com/maps/api/js?key=${window.GOOGLE_MAPS_API_KEY}`;
        script.async = true;
        script.onload = () => this.renderMap(lat ? Number(lat) : null, lng ? Number(lng) : null);
        document.head.appendChild(script);
      }
      return;
    }
    // If no coordinates, show default map view and remove marker if exists
    if (!lat || !lng) {
      if (!this.map) {
        this.map = new window.google.maps.Map(this.el, {
          center: { lat: 0, lng: 0 },
          zoom: 2
        });
      } else {
        this.map.setCenter({ lat: 0, lng: 0 });
        this.map.setZoom(2);
      }
      if (this.marker) {
        this.marker.setMap(null);
        this.marker = null;
      }
      return;
    }
    // Save for re-use
    this.el.__lat = lat;
    this.el.__lng = lng;
    this.renderMap(Number(lat), Number(lng));
  },
  renderMap(lat, lng) {
    // Helper to check if lat/lng are valid finite numbers
    const isValidCoord = (v) => typeof v === "number" && isFinite(v);
    const hasCoords = isValidCoord(lat) && isValidCoord(lng);

    if (!this.map) {
      this.map = new window.google.maps.Map(this.el, {
        center: hasCoords ? { lat, lng } : { lat: 0, lng: 0 },
        zoom: hasCoords ? 16 : 2
      });
    } else {
      this.map.setCenter(hasCoords ? { lat, lng } : { lat: 0, lng: 0 });
      this.map.setZoom(hasCoords ? 16 : 2);
    }

    // Only show marker if valid coordinates
    if (hasCoords) {
      if (!this.marker) {
        this.marker = new window.google.maps.Marker({
          position: { lat, lng },
          map: this.map
        });
      } else {
        this.marker.setPosition({ lat, lng });
        this.marker.setMap(this.map);
      }
    } else if (this.marker) {
      this.marker.setMap(null);
      this.marker = null;
    }
  }
};

let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

