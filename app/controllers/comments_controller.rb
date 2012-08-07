class CommentsController < ApplicationController

  before_filter :authenticate_user!, except: [:index]
  before_filter :load_resource
  before_filter :initialize_new_comment, only: [:index,:new]

  def index
    respond_to do |format|
      format.js   { }
      format.html { }
    end
  end

  def new
    render :index
  end

  def edit
    respond_to do |format|
      format.html {}
      format.js {}
    end
  end

  def update
    _params = params[:comment][:comment].merge(user_id: current_user.to_param, posted_from_ip: request.remote_ip)
    @comment.update_attributes(_params)
    if @commentable.save
      respond_to do |format|
        format.js { 
          initialize_new_comment        
        }
        format.html {
          redirect_to @commentable, notice: t(:comment_successfully_posted)
        }
      end
    else
      render :edit
    end
  end

  def create
    _params = params[:comment][:comment].merge(user_id: current_user.to_param, posted_from_ip: request.remote_ip)
    @comment =  @commentable.comments.create(_params)
    if @commentable.save
      respond_to do |format|
        format.js {
          initialize_new_comment
          render 'update_comments'
        }
        format.html {
          redirect_to @commentable, notice: t(:comment_successfully_posted)
        }
      end
    else
      render :index
    end
  end

  def destroy
    @comment.delete
    @commentable.save
    respond_to do |format|
      format.js {
        initialize_new_comment
      }
      format.html {
        redirect_to commentable_comments_path(@commentable), notice: t(:comment_successfully_deleted)
      }
    end
  end


private
  def load_resource
    id_param = params.detect {|k,v| k =~ /_id\Z/ }
    model_name = id_param[0].gsub( /_id\Z/, '' )
    @commentable = model_name.camelize.constantize.find( id_param[1] )
    @comments = @commentable.comments
    @comment = @commentable.comments.find(params[:id]) if params[:id].present?
  end

  def initialize_new_comment
    @comment = @commentable.comments.build(user_id: current_user.to_param)
  end

  def commentable_comments_path(commentable)
    eval "#{class_to_param(commentable)}_comments_path(commentable)"
  end

end

