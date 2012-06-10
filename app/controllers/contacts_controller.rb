# -*- encoding : utf-8 -*-
class ContactsController < ApplicationController

  before_filter :authenticate_user!

  def index
    @contacts = current_user.contacts
    @rcontacts= current_user.reverse_contacts
  end

end
