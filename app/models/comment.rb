class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :commentable, polymorphic: true, :inverse_of => :comments

  field :comment
  validates_presence_of :comment
  validates_length_of :comment, :minimum => 20
  field :user_id
  field :posted_from_ip

  def user
    User.find(self.user_id) if self.user_id
  end
  
  def allow_delete?(_user)
    _user  && ((self.user && self.user == _user) || _user.can_execute?('Admin', 'Moderator', 'Maintainer'))
  end
end