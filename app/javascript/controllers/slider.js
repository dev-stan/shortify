import { Controller } from "stimulus";
import Slider from "bootstrap-slider";

export default class extends Controller {
  connect() {
    this.initializeSlider();
  }

  initializeSlider() {
    const ticks = JSON.parse(this.data.get("ticks"));
    const ticksLabels = JSON.parse(this.data.get("ticksLabels"));
    const ticksSnapBounds = Number(this.data.get("ticksSnapBounds"));

    this.slider = new Slider(this.element, {
      ticks: ticks,
      ticks_labels: ticksLabels,
      ticks_snap_bounds: ticksSnapBounds
    });
  }
}
