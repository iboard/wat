# -*- encoding : utf-8 -*-
class SessionsController < ApplicationController

  def new
  end

  # 1. Login if user found by authentication
  # 2. Add authentication to current_user if one exists
  # 3. Create a new user by this authentication
  # 4. Redirect to edit_user if email is invalid
  # 5. Redirect to root_url with notice
  def create
    auth = request.env["omniauth.auth"]

    user = User.where(:authentications.matches => {
             :provider => auth['provider'], 
             :uid => auth['uid'].to_s
           }).first
    if user && !current_user
      session[:user_id] = user.id
    elsif current_user
      current_user.add_omniauth(auth)
      current_user.save!
    else
      user = User.create_with_omniauth(auth,current_user)
      if user.email.present?
        user.email_confirmed_at = Time.now
        user.save!
        _send_notification = false
      else
        _send_notification = true
      end
      session[:user_id] = user.id
    end

    if user && current_user
      if user.email.blank? 
        redirect_to edit_user_path(user.id.to_s), :info => t(:please_enter_your_email_address)
      else
        unless user.email_confirmed?
          flash[:message] = t(:email_not_confirmed_yet, email: user.email, 
            confirm_link: dirty_link_to(I18n.t(:resend_confirmation_mail), resend_confirmation_mail_user_path(user))
          ).html_safe


          if _send_notification
            UserMailer.registration_confirmation(user).deliver
          end
        end
        redirect_to root_url, :notice => t(:signed_in)
      end
    else
      unless user
        redirect_to current_user, :notice => t(:provider_added, provider: auth['provider']).html_safe
      else
        redirect_to user, :alert => t(:invalid_credentials_or_user_exists, user: user ? user.name : '')
      end
    end
  end

  def destroy
    reset_session
    redirect_to root_url, :notice => t(:signed_out)
  end

  def failure
    redirect_to root_url, :alert => t(:authentication_error, error: params[:message].humanize)
  end

  def switch_language
    session[:locale] = params[:locale].to_sym
    cookies.permanent[:locale] = params[:locale].to_sym
    _path =  request.env['HTTP_REFERER'].present? ? :back : root_path
    redirect_to _path, :notice => t(:language_changed_to, :lang => t(params[:locale].to_sym))
  end

private
  def dirty_link_to(body,url)
    "<a href='#{url}'>#{body}</a>".html_safe
  end
end
