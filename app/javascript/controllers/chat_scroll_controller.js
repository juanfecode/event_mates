import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chat-scroll"
export default class extends Controller {
  static targets = ["messages", "input"]
  connect() {
    this.messagesTarget.parentNode.lastElementChild.scrollIntoView({ behavior: 'smooth' }); 
  }

  reset() {
    this.messagesTarget.parentNode.lastElementChild.scrollIntoView({ behavior: 'smooth' });
    this.inputTarget.reset()

  }
}
