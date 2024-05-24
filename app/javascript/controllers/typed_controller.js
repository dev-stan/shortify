import { Controller } from "@hotwired/stimulus"
import Typed from 'typed.js';

// Connects to data-controller="typed"
export default class extends Controller {
  connect() {
    const typed = new Typed(this.element, {
      strings: ['an Idea', 'Creativity', 'one Click', 'heloooo'],
      typeSpeed: 50,
    });
  }
}
