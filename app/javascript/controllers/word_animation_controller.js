import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="word-animation"
export default class extends Controller {
  static targets = ["word"]

  connect() {
    console.log("Connected to word-animation controller");
    this.animate()
  }

  animate() {
    let words = this.wordTargets;

    words.forEach(word => {
      let letters = word.textContent.split("");
      word.textContent = "";
      letters.forEach(letter => {
        let span = document.createElement("span");
        span.textContent = letter;
        span.className = "letter";
        word.append(span);
      });
    });

    let currentWordIndex = 0;
    let maxWordIndex = words.length - 1;
    words[currentWordIndex].style.opacity = "1";
    words[currentWordIndex].style.position = "relative"; // Ensure the first word stays in place

    let rotateText = () => {
      let currentWord = words[currentWordIndex];
      let nextWord = currentWordIndex === maxWordIndex ? words[0] : words[currentWordIndex + 1];

      Array.from(currentWord.children).forEach((letter, i) => {
        setTimeout(() => {
          letter.className = "letter out";
        }, i * 80);
      });

      nextWord.style.opacity = "1";
      nextWord.style.position = "absolute"; // Ensure the next words overlap
      Array.from(nextWord.children).forEach((letter, i) => {
        letter.className = "letter behind";
        setTimeout(() => {
          letter.className = "letter in";
        }, 340 + i * 80);
      });

      currentWordIndex = currentWordIndex === maxWordIndex ? 0 : currentWordIndex + 1;
    };

    rotateText();
    setInterval(rotateText, 4000);
  }
}
