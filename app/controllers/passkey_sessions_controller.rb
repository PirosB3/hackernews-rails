class PasskeySessionsController < ApplicationController
  def new
    get_options = WebAuthn::Credential.options_for_get

    session[:webauthn_authentication_challenge] = get_options.challenge

    render json: get_options
  end

  def create
    webauthn_credential = WebAuthn::Credential.from_get(params[:credential])

    stored_credential = PasskeyCredential.find_by!(
      external_id: Base64.strict_encode64(webauthn_credential.raw_id)
    )

    webauthn_credential.verify(
      session.delete(:webauthn_authentication_challenge),
      public_key: Base64.strict_decode64(stored_credential.public_key),
      sign_count: stored_credential.sign_count
    )

    stored_credential.update!(sign_count: webauthn_credential.sign_count)

    session[:user_id] = stored_credential.user_id
    render json: { status: "ok", redirect_to: root_path }
  rescue WebAuthn::Error => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Passkey not recognized." }, status: :unprocessable_entity
  end
end
