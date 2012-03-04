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
  def clear_identities
    self.authentications.where(provider: 'identity').each do |i|
      if i.is_a?(Identity)
        Identity.find(i.id).delete
      end
    end
  end

  def add_omniauth(auth)
    Rails.logger.info "ADD OMNIAUTH #{auth.inspect}"
    self.authentications.create( 
      provider: auth['provider'],
      uid: auth['uid']
    )
  end

  # Create a new user using omniAuth information
  # @param [Hash] auth The hash returned by omniauth-provider
  # @return User or nil if it can't be found or created
  def self.create_with_omniauth(auth,current_user)
    
    _name = auth['info']['name']
    _uid  = auth['info']['uid'].to_s
    _provider=auth['info']['provider']
    unless _name
      _name = [auth['info']['first_name']||'', auth['info']['last_name']||''].join(" ")
    end
    
    _user = User.where( 
      :authentications.matches => {
         :provider => _provider, :uid => _uid
      }
    ).first
    return _user if _user


    _user = current_user || create(name: _name) do |user|
      user.email = auth['info']['email'] if auth['info']['email'].present?
      user.authentications.create(
        provider: auth['provider'],
        uid: auth['uid'].to_s
      )
    end
    _user.save
    _user
  end

  def self.find_with_authentication(provider, uid)
    User.where(:authentications.matches => { provider: provider, uid: uid.to_s}).first
  end

  def add_authentication(authentication)
    authentications << authentication
  end

end

