import { useEffect, useRef, useState } from "react";

type NullableNumber = number | null | undefined;

interface GoogleMapProps {
  lat?: NullableNumber;
  lng?: NullableNumber;
  mapId?: string;
  zoom?: number;
}

declare global {
  interface Window {
    google?: typeof google;
    GOOGLE_MAPS_API_KEY?: string;
    _googleMapsLoading?: boolean;
    _googleMapsLoadedCallbacks?: (() => void)[];
  }
}

const DEFAULT_CENTER = { lat: 0, lng: 0 };
const DEFAULT_ZOOM = 2;

export default function GoogleMap({
  lat,
  lng,
  mapId = "YOUR_MAP_ID_HERE", // Replace this with your actual mapId
  zoom = 16,
}: GoogleMapProps) {
  const mapRef = useRef<HTMLDivElement | null>(null);
  const mapInstance = useRef<google.maps.Map>();
  const markerInstance = useRef<google.maps.marker.AdvancedMarkerElement>();
  const [mapReady, setMapReady] = useState(false);

  useEffect(() => {
    if (!window.google || !window.google.maps) {
      if (!window._googleMapsLoading) {
        window._googleMapsLoading = true;
        window._googleMapsLoadedCallbacks = [];
        

        const script = document.createElement("script");
        script.src = `https://maps.googleapis.com/maps/api/js?key=${}&libraries=marker`;
        script.async = true;
        script.onload = () => {
          setMapReady(true);
          window._googleMapsLoadedCallbacks?.forEach((cb) => cb());
        };
        document.head.appendChild(script);
      } else {
        window._googleMapsLoadedCallbacks?.push(() => setMapReady(true));
      }
    } else {
      setMapReady(true);
    }
  }, []);

  useEffect(() => {
    if (!mapReady || !mapRef.current) return;

    const validLat = typeof lat === "number" && isFinite(lat);
    const validLng = typeof lng === "number" && isFinite(lng);

    const center = validLat && validLng ? { lat, lng } : DEFAULT_CENTER;

    if (!mapInstance.current) {
      mapInstance.current = new google.maps.Map(mapRef.current, {
        center,
        zoom: validLat && validLng ? zoom : DEFAULT_ZOOM,
        mapId,
      });
    } else {
      mapInstance.current.setCenter(center);
      mapInstance.current.setZoom(validLat && validLng ? zoom : DEFAULT_ZOOM);
    }

    // Manage marker
    if (validLat && validLng) {
      const position = { lat, lng };

      if (!markerInstance.current) {
        markerInstance.current = new google.maps.marker.AdvancedMarkerElement({
          map: mapInstance.current,
          position,
        });
      } else {
        markerInstance.current.position = position;
        markerInstance.current.map = mapInstance.current;
      }
    } else if (markerInstance.current) {
      markerInstance.current.map = null;
      markerInstance.current = undefined;
    }
  }, [mapReady, lat, lng, zoom, mapId]);

  return (
    <div
      ref={mapRef}
      className="w-full h-full rounded-2xl shadow-md border border-gray-200"
    />
  );
}
