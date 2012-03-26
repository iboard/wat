# -*- encoding : utf-8 -*-
class AuthenticationsController < ApplicationController

  def destroy
    @user = User.find(params[:user_id])
    unless @user.authentications.count == 1
      @user.authentications.find(params[:id]).delete
      @user.save
      redirect_to user_path(@user), :notice => t(:removed_authentication_successfully)
    else
      redirect_to user_path(@user), :alert => t(:last_authentication_cannot_be_deleted)
    end
  end
end