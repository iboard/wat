class CommentPresenter < BasePresenter

  presents :comment

  def posted_by
    rc = avatar.html_safe
    rc += (comment.user.name || t(:anonymous)) if comment.user
  end

  def timestamp
    if comment.new_record?
      t(:new_comment)
    else
      (
        "<span title='#{I18n.l(comment.created_at, format: :short)}'>" + 
        I18n.t(:age_in_words, distance: time_ago_in_words(comment.created_at) ) + 
        "</span>"
      ).html_safe
    end
  end

  def body
    interpret (comment.comment||'')
  end


private
  def avatar
    _class = 'floating-avatar avatar-tiny'
    if comment.user
      image_tag comment.user.picture(:icon).first, class: _class
    else
      image_tag '/images/avatars/tiny/missing.png', class: _class
    end
  end

end