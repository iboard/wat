# -*- encoding : utf-8 -*-
class AuthenticationsController < ApplicationController

  def destroy
    @user = User.find(params[:user_id])
    unless @user.authentications.count == 1
      _auth = @user.authentications.find(params[:id])
      if Settings.public_sign_up == 'disabled' && _auth.provider.downcase == 'identity'
        redirect_to user_path(@user), :alert => t(:cant_remove_local_authentication)
      else
        _auth.destroy
        @user.save
        redirect_to user_path(@user), :notice => t(:removed_authentication_successfully)
      end
    else
      redirect_to user_path(@user), :alert => t(:last_authentication_cannot_be_deleted)
    end
  end
end