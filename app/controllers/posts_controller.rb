class PostsController < ApplicationController
	def show 
		render :json => {}, :status => 404
	end
end
