import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"
import yearDropdownPlugin from "../plugins/year_dropdown_plugin";

// Connects to data-controller="datepicker"
export default class extends Controller {
  static targets = ["dob"]

  connect() {
    console.log("Datepicker controller connected!");
    console.log("Initializing Flatpickr on:", this.dobTarget)
    const fp = flatpickr(this.dobTarget, {
      plugins: [
        new yearDropdownPlugin({
          date: "2024-12-13",
          yearStart: 1950,
          yearEnd: 0,
        })
      ],
      altInput: true,
      clickOpens: true,
      yearSelectorType: "dropdown",
      altFormat: "F j, Y",
      dateFormat: "Y-m-d",
      minDate: new Date(1950, 0, 1)
    });
    console.log("Flatpickr instance:", fp);
  }

}
