# -*- encoding : utf-8 -*-
class ContactsController < ApplicationController

  before_filter :authenticate_user!


  def new
    redirect_to new_contact_invitation_path, notice: t(:invate_contact_hint_if_no_contacts_exists)
  end

  def destroy
    _contact = User.where(_id: params[:id]).first
    if _contact && current_user.unlink_contact(_contact)
      redirect_to contacts_path, notice: t(:contact_removed, user: _contact.name)
    else
      redirect_to contacts_path, alert: t(:contact_could_not_be_removed, user: _contact ? _contact.name : "n/a")
    end
  end


  def index
    @contacts = current_user.contacts
    @rcontacts= current_user.reverse_contacts
  end

end
