require 'redcarpet'

class HTMLwithAlbino < Redcarpet::Render::HTML
  def block_code(code, language)
    args = [code, language].compact
    Albino.colorize(*args).gsub(/\n/,"<br/>")
  end
end


Markdown = Redcarpet::Markdown.new(HTMLwithAlbino,
  :space_after_headers => false,
  :fenced_code_blocks => true, 
  :autolink => true, 
  :no_intra_emphasis => true,
  :strikethrough => true, 
  :superscripts => true
)
