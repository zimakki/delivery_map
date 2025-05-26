/// <reference types="google.maps" />
// Google Maps LiveView Hook for DeliveryMap

export interface GoogleMapHookElement extends HTMLElement {
  __lat?: string;
  __lng?: string;
}

type NullableNumber = number | null | undefined;

type GoogleMapHook = {
  map?: google.maps.Map;
  markers?: google.maps.marker.AdvancedMarkerElement[];
  el: GoogleMapHookElement;
  handleMap(): void;
  renderMap(addresses: any[]): void;
  mounted(): void;
  updated(): void;
}

export const GoogleMap: Partial<GoogleMapHook> = {
  mounted() {
    console.log("GoogleMap mounted");
    this.handleMap();

  },
  updated() {
    console.log("GoogleMap updated");
    this.handleMap();
  },
  handleMap() {
    const addressesJson = this.el.dataset.addresses;
    let addresses = [];
    try {
      addresses = addressesJson ? JSON.parse(addressesJson) : [];
    } catch (e) {
      addresses = [];
    }

    if (!window.google || !window.google.maps) {
      if (!(window as any)._googleMapsLoading) {
        (window as any)._googleMapsLoading = true;
        const script = document.createElement('script');
        script.src = `https://maps.googleapis.com/maps/api/js?key=${(window as any).GOOGLE_MAPS_API_KEY}&libraries=marker`;
        script.async = true;
        script.onload = () => this.renderMap(addresses);
        document.head.appendChild(script);
      }
      return;
    }
    this.renderMap(addresses);
  },
  renderMap(addresses) {
    // Remove old markers
    if (this.markers && Array.isArray(this.markers)) {
      this.markers.forEach(marker => marker.setMap(null));
    }
    this.markers = [];

    let center = { lat: 0, lng: 0 };
    let zoom = 2;
    if (addresses.length > 0) {
      const first = addresses[0];
      center = { lat: Number(first.lat), lng: Number(first.lng) };
      zoom = 12;
    } else {
      // Default to El Born, Barcelona
      center = { lat: 41.3851, lng: 2.1801 };
      zoom = 16;
    }

    if (!this.map) {
      this.map = new window.google.maps.Map(this.el, {
        center,
        zoom,
        mapId: 'YOUR_MAP_ID_HERE', // <-- Replace with your actual Map ID
        gestureHandling: 'greedy'
      });
      // Attach map click listener only once
      if (!this._clickListenerAdded) {
        this.map.addListener('click', (e: any) => {
          if (this.pushEvent && e && e.latLng) {
            this.pushEvent('map_add_address', {
              lat: e.latLng.lat(),
              lng: e.latLng.lng()
            });
          }
        });
        this._clickListenerAdded = true;
      }
    }
    // On update, do NOT change center or zoom

    // Add markers for all addresses
    addresses.forEach(addr => {
      if (addr.lat && addr.lng) {
        let markerOptions: any = {
          map: this.map,
          position: { lat: Number(addr.lat), lng: Number(addr.lng) }
        };
        // If icon is a known SVG type, set content to SVG markup
        if (addr.icon) {
          // Map icon key to SVG string
          const svgMap: Record<string, string> = {
            'red-pin': "<svg width='32' height='32' viewBox='0 0 24 24' fill='red'><circle cx='12' cy='12' r='10'/></svg>",
            'blue-pin': "<svg width='32' height='32' viewBox='0 0 24 24' fill='blue'><circle cx='12' cy='12' r='10'/></svg>",
            'green-pin': "<svg width='32' height='32' viewBox='0 0 24 24' fill='green'><circle cx='12' cy='12' r='10'/></svg>",
            'star': "<svg width='32' height='32' viewBox='0 0 24 24' fill='gold'><polygon points='12,2 15,10 23,10 17,15 19,23 12,18 5,23 7,15 1,10 9,10'/></svg>",
            'flag': "<svg width='32' height='32' viewBox='0 0 24 24'><rect x='4' y='4' width='4' height='16' fill='gray'/><rect x='8' y='4' width='12' height='8' fill='red'/></svg>"
          };
          if (svgMap[addr.icon]) {
            const div = document.createElement('div');
            div.innerHTML = svgMap[addr.icon];
            markerOptions.content = div.firstChild;
          }
        }
        const marker = new window.google.maps.marker.AdvancedMarkerElement(markerOptions);
        this.markers.push(marker);
      }
    });

    // Center map on selected address if provided
    const selectedLat = this.el.dataset.selectedLat;
    const selectedLng = this.el.dataset.selectedLng;
    if (this.map && selectedLat && selectedLng) {
      const lat = Number(selectedLat);
      const lng = Number(selectedLng);
      if (!isNaN(lat) && !isNaN(lng)) {
        this.map.setCenter({ lat, lng });
        // Do NOT change zoom
      }
    }
  }
};
