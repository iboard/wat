# -*- encoding : utf-8 -*-"
#
# Created by Andi Altendorfer <andreas@altendorfer.at>, 19.08.12, 18:51
#
class CommentEvent < DoorkeeperEvent

  field :commentable_id
  field :commentable_type

  def commentable
    self.commentable_type.constantize.find(self.commentable_id)
  end

  def text
    _name = self.sender.nil? ? I18n.t(:anonymous) : sender_markdown_link
    @text ||= I18n.t(:comment_event,
                     user: _name,
                     time: distance_of_time_in_words(Time.now, self.created_at),
                     commentable_link: commentable_markdown_link()
                    )
  rescue => e
    self.message += " " + e.inspect + " => " + self.inspect
    super
  end

  private
  def commentable_markdown_link
    "[#{commentable.try(:title)}](/#{commentable_type.underscore.pluralize}/#{self.commentable_id})"
  end

end