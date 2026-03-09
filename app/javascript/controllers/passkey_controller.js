import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["status"]

  async register(event) {
    event.preventDefault()

    try {
      this.setStatus("Requesting passkey options...")

      const optionsResponse = await fetch("/passkey_registrations/new", {
        headers: { "Accept": "application/json" }
      })
      const options = await optionsResponse.json()

      options.challenge = this.base64urlToBuffer(options.challenge)
      options.user.id = this.base64urlToBuffer(options.user.id)
      if (options.excludeCredentials) {
        options.excludeCredentials = options.excludeCredentials.map(cred => ({
          ...cred,
          id: this.base64urlToBuffer(cred.id)
        }))
      }

      this.setStatus("Waiting for passkey...")

      const credential = await navigator.credentials.create({ publicKey: options })

      const credentialData = {
        id: credential.id,
        rawId: this.bufferToBase64url(credential.rawId),
        type: credential.type,
        response: {
          attestationObject: this.bufferToBase64url(credential.response.attestationObject),
          clientDataJSON: this.bufferToBase64url(credential.response.clientDataJSON)
        }
      }

      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

      const result = await fetch("/passkey_registrations", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": csrfToken
        },
        body: JSON.stringify({ credential: credentialData })
      })

      const data = await result.json()

      if (data.status === "ok") {
        this.setStatus("Passkey registered!")
        window.location.reload()
      } else {
        this.setStatus(`Error: ${data.error}`)
      }
    } catch (error) {
      if (error.name === "NotAllowedError") {
        this.setStatus("Passkey registration was cancelled.")
      } else {
        this.setStatus(`Error: ${error.message}`)
      }
    }
  }

  async authenticate(event) {
    event.preventDefault()

    try {
      this.setStatus("Requesting passkey options...")

      const optionsResponse = await fetch("/passkey_sessions/new", {
        headers: { "Accept": "application/json" }
      })
      const options = await optionsResponse.json()

      options.challenge = this.base64urlToBuffer(options.challenge)
      if (options.allowCredentials) {
        options.allowCredentials = options.allowCredentials.map(cred => ({
          ...cred,
          id: this.base64urlToBuffer(cred.id)
        }))
      }

      this.setStatus("Waiting for passkey...")

      const credential = await navigator.credentials.get({ publicKey: options })

      const credentialData = {
        id: credential.id,
        rawId: this.bufferToBase64url(credential.rawId),
        type: credential.type,
        response: {
          authenticatorData: this.bufferToBase64url(credential.response.authenticatorData),
          clientDataJSON: this.bufferToBase64url(credential.response.clientDataJSON),
          signature: this.bufferToBase64url(credential.response.signature),
          userHandle: credential.response.userHandle
            ? this.bufferToBase64url(credential.response.userHandle)
            : null
        }
      }

      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

      const result = await fetch("/passkey_sessions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": csrfToken
        },
        body: JSON.stringify({ credential: credentialData })
      })

      const data = await result.json()

      if (data.status === "ok") {
        window.location.href = data.redirect_to
      } else {
        this.setStatus(`Error: ${data.error}`)
      }
    } catch (error) {
      if (error.name === "NotAllowedError") {
        this.setStatus("Passkey authentication was cancelled.")
      } else {
        this.setStatus(`Error: ${error.message}`)
      }
    }
  }

  setStatus(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
    }
  }

  base64urlToBuffer(base64url) {
    const base64 = base64url.replace(/-/g, "+").replace(/_/g, "/")
    const padding = "=".repeat((4 - (base64.length % 4)) % 4)
    const binary = atob(base64 + padding)
    const buffer = new ArrayBuffer(binary.length)
    const view = new Uint8Array(buffer)
    for (let i = 0; i < binary.length; i++) {
      view[i] = binary.charCodeAt(i)
    }
    return buffer
  }

  bufferToBase64url(buffer) {
    const bytes = new Uint8Array(buffer)
    let binary = ""
    for (let i = 0; i < bytes.length; i++) {
      binary += String.fromCharCode(bytes[i])
    }
    return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "")
  }
}
