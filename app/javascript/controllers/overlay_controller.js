import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="overlay"

  export default class extends Controller {
    static targets = ["text", "preview"];

    connect() {
      console.log("Overlay connected");
      // Hide text overlay initially
      // this.textTarget.style.display = "none";


    }
    resizefont(event) {
     const fontSize = event.currentTarget.value
     this.textTarget.style.fontSize = fontSize + "px"
    }

    fontstyle(event){
      const fontStyle = event.currentTarget.value;
      console.log(fontStyle);
      this.textTarget.style.fontStyle = fontStyle;
    }

    fontfamily(event){
      const fontFamily = event.currentTarget.value
      this.textTarget.style.fontFamily = fontFamily
    }

    videochange(event) {
      const video = event.currentTarget.querySelector("video source")
      console.log(video);
      this.previewTarget.src = video.src
    }
  }
