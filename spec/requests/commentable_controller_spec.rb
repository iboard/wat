require File::expand_path('../../spec_helper', __FILE__)

describe Commentable do
  describe "on Page::show" do

    before(:each) do
      Page.delete_all
      @page = Page.create!(permalink: "First Page", title: 'First Page', body: lorem_text(), is_commentable: true)
      User.delete_all
      Identity.delete_all
      visit switch_language_path(:en)
      @user = test_user 'Testuser', 'notsecret', 'Admin'
      sign_in_user name: 'Testuser', password: 'notsecret'
      visit page_path(@page)
    end  
  
    describe "if there is no comment" do
      it "shows number of comments" do
        page.should have_css("#comments-for-" + @page.to_param)
        page.should have_content "No comments"
      end
    end

    describe "if there are comments" do
      before(:each) do
        @page.comments.delete_all
        @page.comments.create( comment: 'This is a cool feature '*3, user_id: @user.to_param)
        @page.save!
        @page.reload  
        visit page_path(@page)
        page.should have_link "One comment"
      end

      it "doesn't show the bubble if is_commentable is defined but not true in the commentable" do
        @page.is_commentable = false
        @page.save!
        @page.reload
        visit page_path(@page)
        page.should_not have_link "One comment"
      end

      it "doesn't show the bubble, not even on the start-page" do
        @page.is_commentable = false, @page.featured = true
        @page.save!
        @page.reload
        visit signout_path
        visit root_path
        page.should_not have_link "One comment"
      end



      it "shows comments when click on 'comments-link'" do
        page.should_not have_content "This is a cool feature"
        page.should have_link "One comment"
        click_link "One comment"
        page.should have_content "This is a cool feature"
      end

      it "offers a form to enter a new comment" do
        click_link "One comment"
        fill_in "comment_comment_comment", with: "To short"
        click_button "Post comment"
        page.should have_content "To short"
        fill_in "comment_comment_comment", with: "XXXX " + lorem_text()
        click_button "Post comment"
        page.should have_content "Comment successfully posted"
        latest_doorkeeper_event.text.should == "'[First Page](/pages/first-page)' was commented by Testuser, less than a minute ago"
        click_link "2 comments"
        page.should have_content "2 comments for Page 'First Page'"
        page.should have_content "This is a cool feature"
        page.should have_content "XXXX Lorem ipsum dolor sit amet"
      end

      it "offers a form to modify an existing comment" do
        click_link "One comment"
        click_link "Edit comment"
        fill_in "comment_comment_comment", with: "To short"
        click_button "Update comment"
        page.should have_content "To short"
        fill_in "comment_comment_comment", with: "XXXX " + lorem_text()
        click_button "Update comment"
        page.should have_content "Comment successfully posted"
        click_link "One comment"
        page.should have_content "One comment for Page 'First Page'"
        page.should_not have_content "This is a cool feature"
        page.should have_content "XXXX Lorem ipsum dolor sit amet"
      end

      it "they can be deleted" do
        click_link "One comment"
        click_link "Delete comment"
        page.should have_content "No comments"
      end

    end
   
  end

end