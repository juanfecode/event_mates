import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["dateButton", "tagButton", "categoryButton", "eventCard", "sortButton"];

  connect() {
    console.log("FiltersController connected");
    this.activeFilters = {
      date: "All Dates",
      genre: "All Genres",
    };
    this.currentSort = "date"; // Default sort by date

    this.applyFilters(); // Apply default filters
    this.applySort(); // Apply initial sort
    this.makeCardsClickable();
  }

  // Date Filter Logic
  filterByDate(event) {
    this.clearActive("dateButton");
    this.setActive(event.currentTarget, "dateButton");

    this.activeFilters.date = event.currentTarget.dataset.filter;
    this.applyFilters();
  }

  // Genre/Tag Filter Logic
  filterByTag(event) {
    this.clearActive("tagButton");
    this.setActive(event.currentTarget, "tagButton");

    this.activeFilters.genre = event.currentTarget.dataset.filter;
    this.applyFilters();
  }

  // Sorting Logic (Sort by Date or Interest)
  sortBy(event) {
    this.clearActive("sortButton");
    this.setActive(event.currentTarget, "sortButton");

    this.currentSort = event.currentTarget.dataset.sort; // "date" or "interest"
    this.applySort();
  }

  // Set active class for clicked button
  setActive(button, targetType) {
    button.classList.add("active");
  }

  clearActive(targetType) {
    this[`${targetType}Targets`].forEach((button) =>
      button.classList.remove("active")
    );
  }

  // Apply sorting logic
  applySort() {
    let sortedCards = [...this.eventCardTargets];

    if (this.currentSort === "interest") {
      sortedCards.sort((a, b) => {
        return (
          parseInt(b.dataset.favoritesCount) - parseInt(a.dataset.favoritesCount)
        );
      });
    } else {
      sortedCards.sort((a, b) => {
        return new Date(a.dataset.date) - new Date(b.dataset.date);
      });
    }

    // Reorder the cards in the DOM
    const container = this.eventCardTargets[0].parentElement;
    container.innerHTML = ""; // Clear current cards
    sortedCards.forEach((card) => container.appendChild(card));
  }

  // Core Filtering Logic
  applyFilters() {
    this.eventCardTargets.forEach((card) => {
      const eventDate = card.dataset.date;
      const eventGenres = card.dataset.genre
        .split(",")
        .map((genre) => genre.trim());

      const dateMatch =
        this.activeFilters.date === "All Dates" ||
        this.matchesDateFilter(eventDate, this.activeFilters.date);

      const genreMatch =
        this.activeFilters.genre === "All Genres" ||
        eventGenres.includes(this.activeFilters.genre);

      if (dateMatch && genreMatch) {
        card.style.display = "block";
      } else {
        card.style.display = "none";
      }
    });
  }

  // Helper function to match dates
  matchesDateFilter(eventDate, filter) {
    const today = new Date();
    const event = new Date(eventDate);

    switch (filter) {
      case "Today":
        return event.toDateString() === today.toDateString();
      case "This Week":
        const weekFromNow = new Date(today);
        weekFromNow.setDate(today.getDate() + 7);
        return event >= today && event <= weekFromNow;
      case "This Month":
        return (
          event.getFullYear() === today.getFullYear() &&
          event.getMonth() === today.getMonth()
        );
      default:
        return true;
    }
  }

  // Make cards clickable
  makeCardsClickable() {
    this.eventCardTargets.forEach((card) => {
      card.addEventListener("click", () => {
        const url = card.dataset.url;
        if (url) window.location.href = url;
      });
    });
  }
}