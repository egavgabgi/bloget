require 'action_controller'

module Bloget
  module Controllers
    module PostsController
      
      def self.included(base)
        base.class_eval do
          
          around_filter :load_post, :only => [:show, :edit, :update, :destroy]
          
          before_filter :login_required, :except => [ :index, :show ]
          before_filter :authenticate_blogger, :only => [:new, :create]
          before_filter :authenticate_for_post, :only => [:edit, :update, :destroy]
          before_filter :check_post_state, :only => [:show]

          layout 'bloget'
          
        end
      end
      
      def index
        @blog ||= Blog.instance
                
        @rss = formatted_posts_url(:format => 'atom')
        
        posts = if logged_in? and Blogger.valid_blogger?(current_user)
                  Post.chronologically
                else
                  Post.published.chronologically
                end
        
        respond_to do |format|
          format.html do
            if posts.respond_to?(:paginate)
              @posts = posts.paginate(:all, :page => params[:page])
            else
              @posts = posts.find(:all)
            end  
          end
          
          format.atom do 
            if posts.respond_to?(:paginate)
              @posts = posts.paginate(:all, :page => params[:page])
            else
              @posts = posts.find(:all)
            end
            render :layout => false
          end
        end
      end
      
      def show
        @rss = {'Comments RSS' => formatted_post_url(:format => 'atom')}
        respond_to do |format|
          format.html
          format.atom { render :layout => false }
        end
      end
  
      def create
        @post = Post.new(params[:post])
        @post.poster = current_user
    
        if @post.save
          flash[:notice] = "The post was successfully saved."
          redirect_to post_url(@post)
        else
          render :action => "new"
        end
      end
  
      def new
        @post = Post.new
        @post.poster = current_user
      end
    
      def edit
        render
      end
  
      def update
        if @post.update_attributes(params[:post])
          redirect_to post_url(@post)
        else
          render :action => :edit
        end
      end
      
      def destroy
        if (@post.destroy)
          flash[:notice] = "Your post has been successfully deleted."
        else
          flash[:error] = "There was some problem deleting your post."
        end
        
        redirect_to posts_url
      end
      
      protected
    
      def load_post
        begin
          @post ||= Post.find_by_permalink(params[:id])
          raise ActiveRecord::RecordNotFound if @post.nil?
          yield
        rescue ActiveRecord::RecordNotFound
          render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
        end
      end
      
      def authenticate_blogger
        unless logged_in? and Blogger.valid_blogger?(current_user)
          render :nothing => true, :status => 401
        end
      end
    
      def authenticate_for_post
        @post ||= Post.find_by_permalink(params[:id])
        if (@post.poster != current_user)
          render :nothing => true, :status => 401
        end
      end
      
      def check_post_state
        @post ||= Post.find_by_permalink(params[:id])
        unless @post.published? or (logged_in? and Blogger.valid_blogger?(current_user))
          render :nothing => true, :status => 401
        end
      end
      
    end
  end
end
