import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form-validation"
export default class extends Controller {
  static targets = ["input"];

  validate(event) {
    let isValid = true;

    this.inputTargets.forEach((input) => {
      if (!input.value.trim()) {
        // Add custom 'is-invalid' class if input is empty
        input.classList.add("is-invalid");
        isValid = false;
      } else {
        // Remove 'is-invalid' class if input becomes valid
        input.classList.remove("is-invalid");
      }
    });

    if (!isValid) {
      event.preventDefault(); // Prevent form submission if any input is invalid
    }
  }

  removeError(event) {
    // Remove the 'is-invalid' class when the user starts typing
    event.target.classList.remove("is-invalid");
  }
}
