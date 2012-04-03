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
  validates_format_of     :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i, :allow_nil => true

  field                   :confirm_email_token
  field                   :email_confirmed_at, :type => DateTime
  field                   :password_reset_token

  embeds_many             :authentications
  embeds_many             :facilities
  
  # Accessible Attributes
  attr_accessible :name, :email

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

  # @param [String] what - A facility-name
  # @return [Boolean] true if User.facilities.where(name: what, access: /r../)
  def can_read?(what)
    facility = self.facilities.where(name: what).first
    facility && facility.can_read? && self.email_confirmed?
  end

  # @param [String] what - A facility-name
  # @return [Boolean] true if User.facilities.where(name: what, access: /.w./)
  def can_write?(what)
    facility = self.facilities.where(name: what).first
    facility && facility.can_write? && self.email_confirmed?
  end

  # @param [String] what - A facility-name
  # @return [Boolean] true if User.facilities.where(name: what, access: /..x/)
  def can_execute?(what)
    facility = self.facilities.where(name: what).first
    facility && facility.can_execute? && self.email_confirmed?
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

protected
  def clear_identity
    Identity.where(name: self.name).delete_all
  end

end

