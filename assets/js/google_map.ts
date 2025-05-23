// Google Maps LiveView Hook for DeliveryMap

export interface GoogleMapHookElement extends HTMLElement {
  __lat?: string;
  __lng?: string;
}

type NullableNumber = number | null | undefined;

type GoogleMapHook = {
  map?: google.maps.Map;
  marker?: google.maps.Marker;
  el: GoogleMapHookElement;
  handleMap(): void;
  renderMap(lat: NullableNumber, lng: NullableNumber): void;
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
    const latStr = this.el.dataset.lat || this.el.getAttribute('data-lat') || this.el.__lat;
    const lngStr = this.el.dataset.lng || this.el.getAttribute('data-lng') || this.el.__lng;
    const lat = latStr ? Number(latStr) : undefined;
    const lng = lngStr ? Number(lngStr) : undefined;

    if (!window.google || !window.google.maps) {
      if (!(window as any)._googleMapsLoading) {
        (window as any)._googleMapsLoading = true;
        const script = document.createElement('script');
        script.src = `https://maps.googleapis.com/maps/api/js?key=${(window as any).GOOGLE_MAPS_API_KEY}`;
        script.async = true;
        script.onload = () => this.renderMap(lat, lng);
        document.head.appendChild(script);
      }
      return;
    }
    // If no coordinates, show default map view and remove marker if exists
    if (lat === undefined || lng === undefined || isNaN(lat) || isNaN(lng)) {
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
        this.marker = undefined;
      }
      return;
    }
    // Save for re-use
    this.el.__lat = latStr;
    this.el.__lng = lngStr;
    this.renderMap(lat, lng);
  },
  renderMap(lat, lng) {
    const isValidCoord = (v: NullableNumber): v is number => typeof v === "number" && isFinite(v);
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
      this.marker = undefined;
    }
  }
};
