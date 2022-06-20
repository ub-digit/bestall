class Api::CacheController < ApplicationController
  def clear
    api_key = params[:api_key]
    if !api_key.eql?(APP_CONFIG['cache']['api_key'])      
      render text: "Unauthorized", :status => 401
      return
    end
    Rails.cache.clear
    render text: "Cache cleared"
  end
end
