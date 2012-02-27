class SessionsController < ApplicationController

  def new
  end

  def create
    auth = request.env["omniauth.auth"]
    user = User.where(:authentications.matches => {
             :provider => auth['provider'], 
             :uid => auth['uid'].to_s
           }).first || User.create_with_omniauth(auth)

    if user
      session[:user_id] = user.id
      if user.email.blank?
        redirect_to edit_user_path(user), :alert => t(:please_enter_your_email_address)
      else
        redirect_to root_url, :notice => t(:signed_in)
      end
    else
      redirect_to signin_url, :alert => t(:invalid_credentials_or_user_exists)
    end

  end

  def destroy
    reset_session
    redirect_to root_url, :notice => t(:signed_out)
  end

  def failure
    redirect_to root_url, :alert => t(:authentication_error, error: params[:message].humanize)
  end

end
