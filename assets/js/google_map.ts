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
        mapId: 'YOUR_MAP_ID_HERE' // <-- Replace with your actual Map ID
      });
    }
    // On update, do NOT change center or zoom

    // Add markers for all addresses
    addresses.forEach(addr => {
      if (addr.lat && addr.lng) {
        const marker = new window.google.maps.marker.AdvancedMarkerElement({
          map: this.map,
          position: { lat: Number(addr.lat), lng: Number(addr.lng) }
        });
        this.markers.push(marker);
      }
    });
  }
};
