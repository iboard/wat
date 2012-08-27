class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :commentable, polymorphic: true, inverse_of: :comments

  field :comment
  validates_presence_of :comment
  validates_length_of :comment, minimum: 20
  field :user_id
  field :posted_from_ip

  after_create :fire_comment_event

  def user
    User.find(self.user_id) if self.user_id
  end
  
  def allow_delete?(_user)
    _user  && ((self.user && self.user == _user) || _user.can_execute?('Admin', 'Moderator', 'Maintainer'))
  end

  private
  def fire_comment_event
    Timeline.find_or_create_by(name: Doorkeeper::DOORKEEPER_CONTENT).create_event(
        {  message: 'commented', sender_id: self.user_id,
           ip: self.posted_from_ip,
           commentable_id: self.commentable._id, commentable_type: self.commentable.class.to_s
        }, CommentEvent
    ) if [true, nil].include?(commentable.try(:is_online))
    true
  end
end