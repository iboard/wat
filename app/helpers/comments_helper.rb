# -*- encoding : utf-8 -*-

module CommentsHelper

  def commentable_comments_path(commentable)
    eval "#{class_to_param(commentable)}_comments_path(commentable)"
  end
 
  def edit_commentable_comment_path(commentable,comment)
    eval "edit_#{class_to_param(commentable)}_comment_path(commentable,comment)"
  end

  def commentable_comment_delete_path(comment)
    eval "#{class_to_param(comment.commentable)}_comment_path(comment.commentable,comment)"
  end

end