import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="video"
export default class extends Controller {
  connect() {
    console.log("Hello world");
  }

play(event){
  event.currentTarget.addEventListener("mouseout", (event)=> {
    event.currentTarget.pause()
  })
  event.currentTarget.play()
}

}
