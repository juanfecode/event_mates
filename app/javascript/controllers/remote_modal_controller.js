import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { closeOnSubmit: Boolean }

  connect() {
    const showBackdrop = document.querySelector('.modal-backdrop') == null ? true : false;
    this.modal = new bootstrap.Modal(this.element, { "backdrop": showBackdrop })
    this.modal.show();

    if (this.closeOnSubmitValue) {
      this.element.addEventListener("turbo:submit-end", (event) => {
        // console.log(event.detail)
        if (event.detail.success) {
          this.modal.hide();
        }
      });
    }
  }

  disconnect() {
    if (this.modal._element) {
      this.modal.dispose();
    }
  }
}