import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["track", "leftArrow", "rightArrow", "card"]

  connect() {
    this.cardWidth = this.cardTargets[0]?.getBoundingClientRect().width || 0;
    this.visibleCards = 3;
    this.currentIndex = 0;

    this.positionCards();
    this.updateArrowState();
  }

  // Position cards next to each other
  positionCards() {
    this.cardTargets.forEach((card, index) => {
      card.style.left = `${index * 12}%`;
    })
  }

  // Update state of arrows
  updateArrowState() {
    this.leftArrowTarget.disabled = this.currentIndex === 0;
    this.rightArrowTarget.disabled =
      this.currentIndex >= this.cardTargets.length - this.visibleCards;
  }

  // Update Track position
  updateTrackPosition() {
    this.trackTarget.style.transform = `translateX(-${this.currentIndex * 38}%)`;
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
}
