// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application"

// Eager load all controllers defined in the controllers directory
const controllers = import.meta.glob("./**/*_controller.js", { eager: true })
Object.entries(controllers).forEach(([filename, module]) => {
  const name = filename
    .replace("./", "")
    .replace("_controller.js", "")
    .replace("/", "--")
  application.register(name, module.default)
})
