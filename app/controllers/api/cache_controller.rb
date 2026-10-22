class Api::CacheController < ApplicationController
  def clear
    api_key = params[:api_key]
    if params[:api_key].blank? || APP_CONFIG['cache']['api_key'].blank? || !api_key.eql?(APP_CONFIG['cache']['api_key'])
      render plain: "Unauthorized", :status => 401
      return
    end
    Rails.cache.clear
    render plain: "Cache cleared"
  end
end
