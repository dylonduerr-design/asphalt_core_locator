import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="lane-modal"
export default class extends Controller {
  static targets = ["modal", "sublotId", "form"]

  open(event) {
    // If JS is active, keep this as a modal. If not, the element is a normal link.
    event.preventDefault()

    const sublotId = event.params.sublotId
    if (!sublotId) return

    this.sublotIdTarget.value = sublotId
    this.modalTarget.classList.remove("hidden")
  }

  close() {
    this.modalTarget.classList.add("hidden")
    this.formTarget.reset()
  }

  backdropClose(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }
}
