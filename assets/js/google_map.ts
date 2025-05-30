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
    const previewAddressJson = this.el.dataset.previewAddress;
    let addresses = [];
    let previewAddress = null;
    try {
      addresses = addressesJson ? JSON.parse(addressesJson) : [];
    } catch (e) {
      addresses = [];
    }
    try {
      previewAddress = previewAddressJson ? JSON.parse(previewAddressJson) : null;
    } catch (e) {
      previewAddress = null;
    }

    if (!window.google || !window.google.maps) {
      if (!(window as any)._googleMapsLoading) {
        (window as any)._googleMapsLoading = true;
        const script = document.createElement('script');
        script.src = `https://maps.googleapis.com/maps/api/js?key=${(window as any).GOOGLE_MAPS_API_KEY}&libraries=marker`;
        script.async = true;
        script.onload = () => this.renderMap(addresses, previewAddress);
        document.head.appendChild(script);
      }
      return;
    }
    this.renderMap(addresses, previewAddress);
  },
  renderMap(addresses, previewAddress) {
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
        gestureHandling: 'greedy',
        streetViewControl: false,
        zoomControl: false,
        mapTypeControl: false,
        fullscreenControl: false
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
        const div = document.createElement('div');
        div.innerHTML = addr.icon_svg;
        markerOptions.content = div.firstChild;
        const marker = new window.google.maps.marker.AdvancedMarkerElement(markerOptions);
        this.markers.push(marker);
      }
    });

    // Add marker for preview address (if present)
    if (previewAddress && previewAddress.lat && previewAddress.lng) {
      let markerOptions: any = {
        map: this.map,
        position: { lat: Number(previewAddress.lat), lng: Number(previewAddress.lng) }
      };
      // Always use blue-pin for preview
      const div = document.createElement('div');
      div.innerHTML = "<svg width='36' height='36' viewBox='0 0 24 24' fill='blue'><circle cx='12' cy='12' r='10'/></svg>";
      markerOptions.content = div.firstChild;
      const marker = new window.google.maps.marker.AdvancedMarkerElement(markerOptions);
      this.markers.push(marker);
    }

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
