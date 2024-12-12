import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["input", "form"];
  
  connect() {
  }

  clear(event){
    event.preventDefault();
    this.inputTarget.value = "";
    this.formTarget.submit();
  }
}
