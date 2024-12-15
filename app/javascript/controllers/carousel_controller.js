import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["track", "leftArrow", "rightArrow", "card"]

  connect() {
    this.updateDimensions(); // Dynamically calculate card width and gap
    this.visibleCards = 3;
    this.currentIndex = 0;

    this.positionCards();
    this.updateArrowState();
    this.addResizeListener();
    this.makeCardsClickable();
  }

  // Dynamically calculate card width and gap
  updateDimensions() {
    const firstCard = this.cardTargets[0];
    if (!firstCard) {
      this.cardWidth = 0;
      this.gap = 0;
      return;
    }

    const style = window.getComputedStyle(this.trackTarget); // Get CSS styles of the track
    this.gap = parseFloat(style.gap || 0); // Dynamically fetch the `gap` value
    this.cardWidth = firstCard.getBoundingClientRect().width; // Fetch actual card width
  }

  // Position cards next to each other
  positionCards() {
    this.cardTargets.forEach((card, index) => {
      card.style.left = `${index * (this.cardWidth + this.gap)}px`; // Position cards based on dynamic width and gap
    });
  }

  // Update arrow button states
  updateArrowState() {
    this.leftArrowTarget.disabled = this.currentIndex === 0;
    this.rightArrowTarget.disabled =
      this.currentIndex >= this.cardTargets.length - this.visibleCards;
  }

  // Update Track position
  updateTrackPosition() {
    this.trackTarget.style.transform = `translateX(-${this.currentIndex * (this.cardWidth + this.gap)}px)`;
    this.updateArrowState();
  }

  // Slide track to left 
  slideLeft() {
    if (this.currentIndex > 0) {
      this.currentIndex -= 1;
      this.updateTrackPosition();
    }
  }

  // Slide track to the right
  slideRight() {
    if (this.currentIndex < this.cardTargets.length - this.visibleCards) {
      this.currentIndex += 1;
      this.updateTrackPosition();
    }
  }

  // Handle window resizing dynamically
  addResizeListener() {
    window.addEventListener("resize", () => {
      this.updateDimensions(); // Recalculate dimensions
      this.positionCards(); // Reposition cards
      this.updateTrackPosition(); // Update track translation
    });
  }

  // Make each card clickable and navigate to the URL in data-url
  makeCardsClickable() {
    this.cardTargets.forEach((card) => {
      card.addEventListener("click", () => {
        const url = card.dataset.url; // Extract URL from data-url attribute
        if (url) {
          window.location.href = url; // Navigate to the URL
        }
      });
    });
  }
}