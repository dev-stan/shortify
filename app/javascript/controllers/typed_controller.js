import { Controller } from "@hotwired/stimulus"
import Typed from 'typed.js';

// Connects to data-controller="typed"
export default class extends Controller {
  connect() {
    const typed = new Typed(this.element, {
      strings: ['<i>First</i> sentence.', '&amp; a second sentence.'],
      typeSpeed: 50,
    });

  }
}
