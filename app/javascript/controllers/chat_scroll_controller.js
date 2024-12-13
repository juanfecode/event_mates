import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chat-scroll"
export default class extends Controller {
  connect() {
    this.element.scrollIntoView(); 
  }
}
