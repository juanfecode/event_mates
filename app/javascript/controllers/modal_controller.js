import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  connect() {
  }

  show(event) {
    const currentTarget = event.currentTarget;
    const modal = currentTarget.nextElementSibling;
    const modalInstance = new bootstrap.Modal(modal);
    modalInstance.show();
  }
}
