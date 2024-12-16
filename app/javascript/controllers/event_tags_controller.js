import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="event-tags"
export default class extends Controller {
  static targets = ["tag"];

  connect() {
    console.log("EVENTS Tags controller connected!");
  }

  eventTagToggle(event) {
    console.log("Tag clicked!");
    const tagElement = event.target;
    const tagId = tagElement.dataset.tagId;
    const method = tagElement.classList.contains("active") ? "POST" : "DELETE";
    const url = method === "POST" ? `/tags/${tagId}/add_event_tag` : `/tags/${tagId}/remove_event_tag`;


    fetch(url, {
      method: method,
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
      },
    })
      .then(() => {
        tagElement.classList.toggle("active");
      });
  }
}

