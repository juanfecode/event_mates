document.addEventListener("DOMContentLoaded", () => {
  const carousels = document.querySelectorAll(".carousel");

  carousels.forEach((carousel) => {
    const track = carousel.querySelector(".carousel-track");
    const leftArrow = carousel.querySelector(".left-arrow");
    const rightArrow = carousel.querySelector(".right-arrow");
    const cards = track.querySelectorAll(".card");
    const cardWidth = cards[0].getBoundingClientRect().width; // explanation at bottom 1.
    const visibleCards = 3;
    console.log(cardWidth)
    console.log(cards.length)

    let currentIndex = 0;

    // Position cards next to each other... Explanation at bottom 2.
    Array.from(cards).forEach((card, index) => {
      card.style.left = `${index * 12}%`;
    });

    // Update carousel track position... Explanation at bottom 3.
    const updateTrackPosition = () => {
      track.style.transform = `translateX(-${currentIndex * 38}%)`;
    };

    // Event listeners for arrows
    leftArrow.addEventListener("click", () => {
      if (currentIndex > 0) {
        currentIndex -= 1;
        updateTrackPosition();
      }
    });

    rightArrow.addEventListener("click", () => {
      if (currentIndex < cards.length - visibleCards) {
        currentIndex += 1;
        updateTrackPosition();
      }
    });

    // Disable arrows if at the end
    const updateArrowState = () => {
      leftArrow.disabled = currentIndex === 0;
      rightArrow.disabled = currentIndex >= cards.length - visibleCards;
    };

    // Update arrow state initially
    updateArrowState();

    // Add listeners to update arrow state
    leftArrow.addEventListener("click", updateArrowState);
    rightArrow.addEventListener("click", updateArrowState);
  });
});

// EXPLANATIONS

// 1. const cardWidth = cards[0].getBoundingClientRect().width;
// •	This line calculates the width of a single card in the carousel.
// •	cards[0] refers to the first card in the carousel.
// •	getBoundingClientRect() is a built-in JavaScript method that 
//    returns the size and position of an element relative to the viewport.
// •	width gives the horizontal size (in pixels) of the card.
//
// Why it’s needed:
// •	The width of the cards is used to calculate how far to slide the carousel track when the user clicks the arrows.
// •	This ensures that the carousel slides exactly one card at a time.

// 2. Array.from(cards).forEach((card, index) => { card.style.left = `${index * cardWidth}px`});
// •	Array.from(cards):
//     •	Converts the cards collection (usually a NodeList from track.children) into an array so that methods like .forEach can be used.
// •	.forEach((card, index) => { ... }):
//     •	Loops over each card in the carousel and sets its left position.
// •	card.style.left = ${index * cardWidth}px;:
//     •	Dynamically sets the left position of each card using the card’s width multiplied by its index in the list.
// •	For example:
// •	Card 0 (index = 0): left = 0 * cardWidth = 0px
// •	Card 1 (index = 1): left = 1 * cardWidth = cardWidth
// •	Card 2 (index = 2): left = 2 * cardWidth = 2 * cardWidth
//
// Why it’s needed:
// •	This ensures that all the cards are placed side-by-side in a horizontal line (instead of stacking vertically).
// •	By calculating each card’s position using its index, you can properly align them in the carousel track.

// 3. const updateTrackPosition = () => { track.style.transform = translateX(-${currentIndex * cardWidth}px); };
// •	track.style.transform = ...:
//     •	Changes the position of the carousel track by moving it horizontally.
//     •	The transform: translateX(...) CSS property moves the entire track left or right.
// •	-currentIndex * cardWidth:
//     •	Moves the track to the left by the width of currentIndex cards.
// •	For example:
//     •	If currentIndex = 0: translateX(0) (no movement; the first 3 cards are visible).
//     •	If currentIndex = 1: translateX(-cardWidth) (the track moves left by one card width, showing the next set of cards).
//
// Why it’s needed:
// •	This allows the carousel to scroll horizontally when the user clicks the arrows.
// •	By changing the transform: translateX(...), the visible portion of the carousel moves left or right to reveal the next or previous set of cards.