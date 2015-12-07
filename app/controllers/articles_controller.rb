class ArticlesController < ApplicationController
	
	before_action :find_user

	before_action :can_write, except: [:index, :show]

	def index
		if current_user?(@user)
		  @articles = @user.articles.page(params[:page]).per(25)
		else  
		  @articles = @user.articles.published.page(params[:page]).per(25)
		end  
		@articles_by_year = @articles.group_by { |article| article.created_at.beginning_of_year}
		@tags = @user.tags.all 
	end

	def show
		@article = @user.articles.find(params[:id])
	end

	def new
		@article = current_user.articles.build
	end

	def create
		@article = current_user.articles.build(article_params)
		if @article.save
			flash[:success] = "文章已發佈"
			redirect_to user_path(current_user)
		else
			render :new
		end
	end

	def edit
		@article = @user.articles.includes(:tags).find(params[:id])
	end

	def update
		@article = current_user.articles.find(params[:id])
		if @article.update_attributes(article_params)
			flash[:success] = "編輯完成"
			redirect_to user_article_path(@article)
		else
			render :edit
		end	
	end

	def recycling_bin
		@article = current_user.articles.find(params[:id])
		@article.to_trash
		redirect_to manage_user_path(current_user)
	end

	def multiple_destroy
		@articles = @user.articles.find_by_state(4)
		@articles.each { |article| article.delete }
		redirect_to manage_user_path(current_user, state: 4)
 
	end



	

	private
		def find_user
			@user = User.find(params[:user_id])
		end


		def article_params
			params[:article].permit(:title, :content, :tag_names, {:tag_ids => []},
				:state)
		end

		def can_write
			@user = User.find(params[:user_id])
			unless current_user?(@user)
			  flash[:danger] = "無此權限"
			  redirect_to root_path 
			end  
		end
end
