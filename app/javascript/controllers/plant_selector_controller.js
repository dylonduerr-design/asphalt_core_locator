import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="plant-selector"
export default class extends Controller {
  static targets = ["mixOverlay", "selectedPlant", "mixBtn", "drawer", "drawerContent", "chevron"]

  connect() {
    this.drawerExpanded = false
  }

  togglePlant(event) {
    const button = event.currentTarget
    const plant = button.dataset.plant

    // Update the selected plant in the overlay
    this.selectedPlantTarget.textContent = `${plant} - Select Mix Type`

    // Update all mix buttons to use the selected plant
    this.mixBtnTargets.forEach(btn => {
      const form = btn.closest('form')
      const plantInput = form.querySelector('input[name="plant"]')
      if (plantInput) {
        plantInput.value = plant
      } else {
        const input = document.createElement('input')
        input.type = 'hidden'
        input.name = 'plant'
        input.value = plant
        form.appendChild(input)
      }
    })

    // Show the mix overlay
    this.mixOverlayTarget.classList.remove('hidden')
    document.body.style.overflow = 'hidden' // Prevent background scrolling
  }

  closeMix() {
    this.mixOverlayTarget.classList.add('hidden')
    document.body.style.overflow = ''
  }

  toggleDrawer() {
    this.drawerExpanded = !this.drawerExpanded
    
    if (this.drawerExpanded) {
      this.drawerTarget.classList.add('expanded')
      this.chevronTarget.style.transform = 'rotate(180deg)'
    } else {
      this.drawerTarget.classList.remove('expanded')
      this.chevronTarget.style.transform = 'rotate(0deg)'
    }
  }
}
