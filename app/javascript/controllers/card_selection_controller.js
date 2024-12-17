import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="card-selection"
export default class extends Controller {
  static targets = ["card", "checkbox"];

  connect() {
    this.updateCardState(); // Initialize card state on load
  }

  toggleCard() {
    // Toggle the checkbox state when the card is clicked
    this.checkboxTarget.checked = !this.checkboxTarget.checked;

    // Update the card's appearance based on checkbox state
    this.updateCardState();
  }

  updateCardState() {
    if (this.checkboxTarget.checked) {
      this.cardTarget.classList.add("selected");
    } else {
      this.cardTarget.classList.remove("selected");
    }
  }
}