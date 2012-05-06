class PagePresenter < BasePresenter

  presents :page

  def title
    page.title
  end

  def created_at
    I18n.l( page.created_at.localtime, format: :short )
  end

  def body
    interpret page.body
  end

end