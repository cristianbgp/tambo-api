class StoresController < ApplicationController
  
  require 'open-uri'

  def index
    #Tambo+ stores services
    # 1 - pollo, 2 - cajero, 3 - 24 horas, 4 - fritanga
    url = "https://tambomas.pe/public/api/stores"
    data = JSON.parse(open(url).read)
    result = data["stores"].map do |store|
      {
        id: store["_id"],
        name: store["name"],
        longitude: store["longitude"], 
        latitude: store["latitude"],
        address: store["address"],
        allday: store["services"].include?("3"),
        atm: store["services"].include?("2")
      }
    end
    render json: result
  end

end
