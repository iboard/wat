class AttachmentPresenter < BasePresenter

private
  def insert_tag(attachment)
    if attachment.file.content_type =~ /image/
      content_tag :div do
        newline + image_tag( attachment.application_file.file.url(:small) )
      end
    elsif attachment.file.content_type =~ /video/
      content_tag :div do
        newline + video_tag( attachment.file.url, :size => "320x240", controls: true )
      end
    elsif attachment.file.content_type =~ /audio\/mp3/
      content_tag :div do
        newline + audio_tag( attachment.file.url, controls: true )
      end
    else
      ""
    end
  end

  def newline
    "<br/>".html_safe
  end

  def file_name_link(attachment)
    content_tag :span, class: 'file-name-link' do
      icon_link_to 'icon-download','stamped', attachment.file_name, attachment.file.url(:original), target: :blank
    end
  end

  def file_info(attachment)
    content_tag :span, class: 'file-info' do
      if attachment.file.content_type
        attachment.file.content_type + ", " + humanized_filesize(attachment.file.size)
      else
        'unknown'
      end
    end
  end
end