import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chat-scroll"
export default class extends Controller {
  static targets = ["messages"]
  connect() {
    this.messagesTarget.parentNode.lastElementChild.scrollIntoView(); 
  }
}
