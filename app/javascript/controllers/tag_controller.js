import { Controller } from "@hotwired/stimulus";
export default class extends Controller {
  static targets = ["tag"];
  connect() {
    console.log("Tags controller connected!");
  }
  toggle(event) {
    console.log("Tag clicked!");
    const tagElement = event.target;
    const tagId = tagElement.dataset.tagId;
    const method = tagElement.classList.contains("active") ? "DELETE" : "POST";
    const url = method === "POST" ? `/tags/${tagId}/add_user_tag` : `/tags/${tagId}/remove_user_tag`;



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
