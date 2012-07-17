# -*- encoding : utf-8 -*-

#
# =Class User
# 
# * The user.name is used as a key to due readable URLs like /users/andi-altendorfer
# * A user can embed many authentications (omni-* incl. omni-identity)
# * A user can embed many [Facilities]
# * Whenever the email is changed, the :email_confirmed_at invalidats until the user
#   confirms his new address (UserMailer::registration_confirmation)
#
# ==Facilities
#
# ...can be used like:
# 
#    user = User.first
#    user.facilities.create( name: 'Author', access: 'r--')
#
#    if user.can_read?('Author')
#      yes, User can read with Author-access
#    end
#
#    if user.can_write?('Author')
#      no we'll not reach this line for this example-user
#    end
#
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  
  key                     :name
  validates_presence_of   :name
  validates_uniqueness_of :name

  field                   :email, :type => String 
  validates_format_of     :email, :with => ::VALIDATE_EMAIL_REGEX, :allow_nil => true

  field                   :confirm_email_token
  field                   :email_confirmed_at, :type => DateTime
  field                   :password_reset_token
  field                   :location, type: Hash, spacial: true

  embeds_many             :authentications
  embeds_many             :facilities
  embeds_one              :profile
  embeds_one              :avatar

  has_many                :contact_invitations #, as: 'sent_invitations'

  
  # Accessible Attributes
  attr_accessible :name, :email, :location_token

  after_destroy :clear_identity
  
  # Add an authentication to this user
  # @param [Hash] auth - as provided by omni-auth
  def add_omniauth(auth)
    self.authentications.find_or_create_by( 
      provider: auth['provider'],
      uid: auth['uid'].to_s
    )
  end

  # Create a new user using omniauth information
  # @param [Hash] auth The hash returned by omniauth-provider
  # @return User or nil if it can't be found nor created.
  def self.find_or_create_with_omniauth(auth,current_user)
    
    _name = auth['info']['name']
    _uid  = auth['uid']
    _provider = auth['provider']
    _email = auth['info']['email'].present? ? auth['info']['email'] : nil
    _first_name = auth['info']['first_name'].present? ? auth['info']['first_name'] : ''
    _last_name = auth['info']['last_name'].present? ? auth['info']['last_name'] : ''
    # e.g. Foursquare doesn't fill 'info[:name]'
    # in this case join first_name and last_name
    _name ||= [_first_name , _lastname].join(" ")
    
    _user = User.find_with_authentication(_provider, _uid) || current_user || create(name: _name) 
    if _user
      _user.email ||= _email
      _user.save
      _user.authentications.find_or_create_by(provider: _provider, uid: _uid )
    end

    _user
  end

  # Find a User by a given authentication
  # @param [String] provider like 'twitter', 'facebook', ...
  # @param [String] uid of this user at this provider
  # @return [User] or nil if not found by authentication
  def self.find_with_authentication(provider, uid)
    User.where(:authentications.matches => { provider: provider, uid: uid.to_s}).first
  end

  # Adds an authentication to this user
  # @param [Authentication]
  def add_authentication(authentication)
    authentications << authentication
  end

  # @param [String|Array] what - A facility-name
  # @return [Boolean] true if User.facilities.where(name: what, access: /r../)
  def can_read?(*what)
    what.each do |w|
      facility = self.facilities.where(name: w).first
      return true if facility && facility.can_read? && self.email_confirmed?
    end
    false
  end

  # @param [String|Array] what - A facility-name
  # @return [Boolean] true if User.facilities.where(name: what, access: /.w./)
  def can_write?(*what)
    what.each do |w|
      facility = self.facilities.where(name: w).first
      return true if facility && facility.can_write? && self.email_confirmed?
    end
    false
  end

  # @param [String|Array] what - A facility-name
  # @return [Boolean] true if User.facilities.where(name: what, access: /..x/)
  def can_execute?(*what)
    what.each do |w|
      facility = self.facilities.where(name: w).first
      return true if facility && facility.can_execute? && self.email_confirmed?
    end
    false
  end

  # Join all facility-names with access modes. "Admin (rwx), Author (rw-), ..."
  # yield a given block with this string or return the string otherwise.
  # @return [String] - if no block given
  def facilities_string(&block)
    if self.facilities.any?
      _string = I18n.translate(:facilities, list: self.facilities.map{|f| "#{f.name} (#{f.access})"}.join(", "))
      if block_given?
        yield _string
      else
        _string
      end
    else
      unless block_given?
        ""
      end
    end
  end

  # Generate a new random token and set email_confirmed_at to nil
  # UsersControler will set email_confirmed_at when the user confirms the new address
  def generate_confirm_email_token!
    self.confirm_email_token = SecureRandom.hex(10)
    self.email_confirmed_at = nil
    self.save!
  end

  # @return [Boolean] true if email_confirmed_at has a value
  def email_confirmed?
    self.email_confirmed_at != nil
  end

  # Send a reset_password_token to email on file
  def reset_password
    self.password_reset_token = SecureRandom::uuid
    save! 
    UserMailer.send_password_reset_token(self).deliver
  end

  # Return all consumers in all facilities (flatten)
  # @return Critaria for all Users which are consumers of any of self's facilities
  def contacts
    @contacts ||= User.any_in( :_id => facilities.map(&:consumer_ids).flatten.uniq )
  end

  # @return [Criteria] Users with a facility where self is a consumer
  def reverse_contacts
    @reverse_contacts ||= User.where( "facilities.consumer_ids" => self.id )
  end

  # Create facility on invitation.sender
  # @params [ContactInvitation] The received invitation
  def accept_contact_invitation(invitation)
    _sender = invitation.sender
    _sender.facilities.create( name: self.name, access: 'r--', consumer_ids: [self._id] )
    _sender.save!
  end

  # @param [User] check if this user is in contacts or reverse_contacts
  # @return nil or the contacted user
  def is_contacted_with?(_user)
    self.contacts.where(_id: _user._id).only(:_id).first
  end

  # Find User in contacts and reverse_contacts and remove the facility
  # @param [User] the user to unlink
  # @return [Boolean] - true if contact is unlinked
  def unlink_contact(_contact)
    _rc = false
    if self.contacts.detect{|c| c._id ==_contact._id}
      _facility = self.facilities.any_in( consumer_ids: [_contact._id]).first
      if _facility
        _facility.delete_or_remove_consumer(_contact)
        self.save!
        @contacts = nil
        _rc = true
      end
    end
    if self.reverse_contacts.detect{|c| c._id ==_contact._id}  
      _facility = _contact.facilities.any_in( consumer_ids: [self._id]).first
      if _facility
        _facility.delete_or_remove_consumer(self)
        _contact.save!
        @reverse_contacts = nil
        _contact
        _rc = true
      end
    end
    _rc
  end

  def location_token
    if self.location && (self.location['lat'].present? && self.location['lng'].present?)
      "%3.4f,%3.4f" % [self.location['lat'], self.location['lng']]
    end
  end

  def location_token=(str)
    coordinates = str.split(",").map! { |a| a.strip.gsub(/\(|\)/,'') }
    self.location = {
      'lat' => coordinates[0].to_f,
      'lng' => coordinates[1].to_f
    }
  end

protected
  def clear_identity
    Identity.where(name: self.name).delete_all
  end

end

