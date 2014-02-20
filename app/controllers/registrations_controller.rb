class RegistrationsController < Devise::RegistrationsController

  def create
    flash[:newly_registered] = true
    super
  end

end