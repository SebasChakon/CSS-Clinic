import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    console.log("Geolocation controller connected")
  }

  getLocation(event) {
    event.preventDefault()
    
    if (!navigator.geolocation) {
      alert("La geolocalización no es soportada por tu navegador")
      return
    }

    this.buttonTarget.disabled = true
    this.buttonTarget.innerHTML = '<span class="animate-spin"></span> Detectando ubicación...'

    navigator.geolocation.getCurrentPosition(
      (position) => {
        this.handleSuccess(position)
      },
      (error) => {
        this.handleError(error)
      },
      {
        enableHighAccuracy: true,
        timeout: 10000,
        maximumAge: 60000
      }
    )
  }

  handleSuccess(position) {
    const lat = position.coords.latitude
    const lng = position.coords.longitude
    
    console.log("Ubicación detectada:", lat, lng)
    
    this.buttonTarget.innerHTML = '<span></span> Redirigiendo...'

    window.location.href = `/reservas/farmacias_cercanas?lat=${lat}&lng=${lng}`
  }

  handleError(error) {
    let message = "Error obteniendo ubicación"
    
    switch(error.code) {
      case error.PERMISSION_DENIED:
        message = "Permiso de ubicación denegado. Por favor permite el acceso a tu ubicación en tu navegador."
        break
      case error.POSITION_UNAVAILABLE:
        message = "Información de ubicación no disponible."
        break
      case error.TIMEOUT:
        message = "Tiempo de espera agotado."
        break
    }
    
    this.showError(message)
  }

  showError(message) {
    this.buttonTarget.innerHTML = '<span></span> ' + message
    this.buttonTarget.disabled = false
    
    setTimeout(() => {
      this.buttonTarget.innerHTML = '<span></span> Usar mi ubicación real'
      this.buttonTarget.disabled = false
    }, 4000)
  }
}