class Admin::SettingsController < Admin::BaseController
  def show
    @whatsapp_link = Setting.get("whatsapp_group_link")
  end

  def update
    Setting.set("whatsapp_group_link", params[:whatsapp_group_link])
    redirect_to admin_settings_url, notice: "Settings updated"
  end
end
