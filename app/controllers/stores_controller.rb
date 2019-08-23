class StoresController < ApplicationController
  
  require 'open-uri'

  def index
    # 1 pollo
    # 2 cajero
    # 3 24 horas
    # 4 fritanga
    url = "https://tambomas.pe/public/api/stores"
    data = JSON.parse(open(url).read)
    p data["stores"].size
    render json: data
  end

end
