module LayoutHelper

  def menu(&block)
    content_for :content_menu do
      yield
    end
  end

  def title(_title)
    content_for :title do
      _title
    end
    _title
  end

end