import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="event-tags"
export default class extends Controller {
  connect() {
    console.log("Tags controller connected!");
  }
}
