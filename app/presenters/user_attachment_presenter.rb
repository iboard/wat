class UserAttachmentPresenter < AttachmentPresenter

  presents :user_attachment

  def present
    ( 
      file_name_link(user_attachment) + 
      insert_tag(user_attachment) + 
      file_info(user_attachment)
    ).html_safe
  end

end