class User
  include Mongoid::Document
  
  key   :name
  validates_presence_of :name
  validates_uniqueness_of :name
  field :email, :type => String

  embeds_many :authentications
  
  attr_accessible :name, :email

  # Create a new user using omniAuth information
  # @param [Hash] auth The hash returned by omniauth-provider
  # @return User or nil if it can't be found or created
  def self.create_with_omniauth(auth)
    
    _name = auth['info']['name']
    
    _existing_user = User.all_of( 
      [:name => _name,
       :authentications.matches => {
         :provider => auth['provider'], :uid => auth['uid'].to_s
       }]
    ).first
    return _existing_user if _existing_user


    _user = create(name: _name) do |user|
      user.email = auth['info']['email'] || ""
      user.authentications.create(
        provider: auth['provider'],
        uid: auth['uid'].to_s
      )
    end
    
    _user.valid? ? _user : nil
  end

  def self.find_with_authentication(provider, uid)
    User.where(:authentications.matches => { provider: provider, uid: uid.to_s}).first
  end

  def add_authentication(authentication)
    authentications << authentication
  end

end

