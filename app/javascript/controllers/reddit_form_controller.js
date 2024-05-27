import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form", "fsubmit"];

  connect() {
    console.log("Controller connected");
    console.log(this.formTarget);
  }

  fetch_backend(event) {
    event.preventDefault(); // Prevent the default form submission action
    const query = this.fsubmitTarget.value;
    const url = `/sources/reddit?query=${query}`;
    console.log(url);
    fetch(url, { headers: { Accept: "application/json" } })
      .then((response) => response.json())
      .then((data) => {
        console.log(data);
          this.formTarget.value = data.string
      });
  }
}
