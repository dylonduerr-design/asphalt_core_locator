// Import and register all your controllers from the importmap via controllers/**/*_controller
import { Controller } from "@hotwired/stimulus"
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// Register here (vs separate file) so it works even if the server
// was started before the file existed (importmap pins are evaluated at boot).
class LaneModalController extends Controller {
	static targets = ["modal", "sublotId", "form"]

	open(event) {
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

try {
	application.register("lane-modal", LaneModalController)
} catch (_e) {
	// Ignore if already registered (e.g. after hot reload or future refactor)
}
