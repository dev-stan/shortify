import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["title", "fsubmit", "stories"]

  connect() {
    console.log("Controller connected");
  }

  fetch_backend(event) {
    event.preventDefault(); // Prevent the default content submission action
    const query = event.currentTarget.value;
    const url = `/batches/reddit?query=${query}`;
    console.log(url);
    fetch(url, { headers: { Accept: "application/json" } })
      .then((response) => response.json())
      .then((data) => {
        console.log(data);
        console.log(this.storiesTarget);

        // Remove the 'active' class from each stories item
        const items = this.storiesTarget.querySelectorAll('.stories-item');
        items.forEach(item => item.classList.remove('active'));

        // Insert the new HTML content
        this.storiesTarget.innerHTML = ''
        this.storiesTarget.insertAdjacentHTML('afterbegin', data.html);
      });
  }

}
