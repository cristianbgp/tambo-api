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

  def nearest_tambo
    current_location = params[:currentLocation]

    url = "https://tambomas.pe/public/api/stores"
    data = JSON.parse(open(url).read)
    result = data["stores"].map do |store|
      {
        id: store["_id"],
        name: store["name"],
        latitude: store["latitude"],
        longitude: store["longitude"], 
        address: store["address"],
        allday: store["services"].include?("3"),
        atm: store["services"].include?("2"),
        distance: distance([store["latitude"], store["longitude"]], current_location)
      }
    end

    render json: result.sort_by { |store|  store[:distance] }
  end

  private

  def distance loc1, loc2
    rad_per_deg = Math::PI/180  # PI / 180
    rkm = 6371                  # Earth radius in kilometers
    rm = rkm * 1000             # Radius in meters
  
    dlat_rad = (loc2[0]-loc1[0]) * rad_per_deg  # Delta, converted to rad
    dlon_rad = (loc2[1]-loc1[1]) * rad_per_deg
  
    lat1_rad, lon1_rad = loc1.map {|i| i * rad_per_deg }
    lat2_rad, lon2_rad = loc2.map {|i| i * rad_per_deg }
  
    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
  
    rm * c # Delta in meters
  end

end
