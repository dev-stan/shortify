import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["title", "content", "fsubmit"];

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
          this.titleTarget.value = data.title
          this.contentTarget.value = data.content
      });
  }
}
