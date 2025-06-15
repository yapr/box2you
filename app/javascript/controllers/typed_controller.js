import { Controller } from "@hotwired/stimulus"
import Typed from "typed.js"

// Connects to data-controller="typed"
export default class extends Controller {
  static values = {
    strings: Array,
    typeSpeed: { type: Number, default: 50 },
    backSpeed: { type: Number, default: 30 },
    loop: { type: Boolean, default: true },
    startDelay: { type: Number, default: 1000 }
  }

  connect() {
    this.typed = new Typed(this.element, {
      strings: this.stringsValue,
      typeSpeed: this.typeSpeedValue,
      backSpeed: this.backSpeedValue,
      loop: this.loopValue,
      startDelay: this.startDelayValue,
      fadeOut: true,
      showCursor: true,
      cursorChar: '|'
    })
  }

  disconnect() {
    if (this.typed) {
      this.typed.destroy()
    }
  }
}
