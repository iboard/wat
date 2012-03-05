class User
  include Mongoid::Document
  
  key                     :name
  validates_presence_of   :name
  validates_uniqueness_of :name

  field                   :email, :type => String 
  validates_format_of     :email, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i, :allow_nil => true

  embeds_many             :authentications
  
  # Accessible Attributes
  attr_accessible :name, :email


  after_destroy :clear_identities
  # Model Identity is handeled by omniauth-identity and is not
  # connected in any way to our user-model. To clean up unused
  # Identities we have to delete through this user's authentications  
  def clear_identities
    self.authentications.where(provider: 'identity').each do |i|
      if i.is_a?(Identity)
        Identity.find(i.id).delete
      end
    end
  end

  # Add an authentication to this user
  # @param [Hash] auth - as provided by omni-auth
  def add_omniauth(auth)
    self.authentications.find_or_create_by( 
      provider: auth['provider'],
      uid: auth['uid']
    )
  end

  # Create a new user using omniauth information
  # @param [Hash] auth The hash returned by omniauth-provider
  # @return User or nil if it can't be found nor created.
  def self.create_with_omniauth(auth,current_user)
    
    _name = auth['info']['name']
    _uid  = auth['info']['uid'].to_s
    _provider=auth['info']['provider']

    # e.g. Foursquare doesn't fill 'info[:name]'
    # in this case join first_name and last_name
    unless _name
      _name = [auth['info']['first_name']||'', auth['info']['last_name']||''].join(" ")
    end
    
    # Find a user with this authentication
    _user = User.where( 
      :authentications.matches => {
         :provider => _provider, :uid => _uid
      }
    ).first
    
    # Use current_user or create a new user
    unless _user
      _user = current_user || create(name: _name) do |user|
        user.email ||= auth['info']['email'] if auth['info']['email'].present?
        user.authentications.create(
          provider: auth['provider'],
          uid: auth['uid'].to_s
        )
      end
      _user.save
    end

    _user
  end


  def self.find_with_authentication(provider, uid)
    User.where(:authentications.matches => { provider: provider, uid: uid.to_s}).first
  end

  def add_authentication(authentication)
    authentications << authentication
  end

end

