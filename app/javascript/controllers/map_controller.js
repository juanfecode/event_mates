import { Controller } from "@hotwired/stimulus"
import mapboxgl from 'mapbox-gl'

// Connects to data-controller="map"
export default class extends Controller {
  static values = {
    apiKey: String,
    marker: Array
  }

  connect() {
    console.log("Map controller connected!")
    console.log(this.markerValue)
    mapboxgl.accessToken = this.apiKeyValue

    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v10"
    })

    this.#addMarkersToMap()
    this.#fitMapToMarkers()
  }

  #addMarkersToMap(){
    this.markerValue.forEach((marker) => {
      const popup = new mapboxgl.Popup().setHTML(marker.info_window_html)
      new mapboxgl.Marker()
        .setLngLat([ this.markerValue[0].lng, this.markerValue[0].lat ])
        .setPopup(popup)
        .addTo(this.map)
    });

  }

  #fitMapToMarkers() {
    const bounds = new mapboxgl.LngLatBounds();
    bounds.extend([ this.markerValue[0].lng, this.markerValue[0].lat ]);
    this.map.fitBounds(bounds, { padding: 50, maxZoom: 15, duration: 1000 });
  }

}
