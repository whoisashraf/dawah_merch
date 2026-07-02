class ApplicationController < ActionController::Base
  include Authentication
  allow_browser versions: :modern
  stale_when_importmap_changes

  private

  def require_admin
    redirect_to root_path, alert: "Not authorized" unless Current.user&.admin?
  end
end
