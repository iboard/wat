class ContactInvitationsController < ApplicationController

  before_filter :authenticate_user!

  def new
    @contact_invitation = ContactInvitation.new
  end

  def update
    @contact_invitation = ContactInvitation.where(token: params[:token]).first
    if @contact_invitation
      current_user.accept_contact_invitation(@contact_invitation)
      @contact_invitation.token += Time.now.to_s
      @contact_invitation.save
    end
  end

  def create
    params[:contact_invitation].merge!(sender_id: current_user.id)
    @contact_invitation = ContactInvitation.create(params[:contact_invitation])
    if @contact_invitation.valid?
      redirect_to contacts_path, notice: t(:contact_invitation_sent, email: @contact_invitation.recipient_email)
    else
      render :new
    end
  end

end