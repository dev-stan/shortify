import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["title", "content", "fsubmit", "carousel"]

  connect() {
    console.log("Controller connected");
    console.log(this.contentTarget);
  }

  fetch_backend(event) {
    event.preventDefault(); // Prevent the default content submission action
    const query = event.currentTarget.value;
    const url = `/sources/reddit?query=${query}`;
    console.log(url);
    fetch(url, { headers: { Accept: "application/json" } })
      .then((response) => response.json())
      .then((data) => {
        console.log(data);
        console.log(this.carouselTarget);

        // Remove the 'active' class from each carousel item
        const items = this.carouselTarget.querySelectorAll('.carousel-item');
        items.forEach(item => item.classList.remove('active'));

        // Insert the new HTML content
        this.carouselTarget.insertAdjacentHTML('afterbegin', data.html);
      });
  }

}
