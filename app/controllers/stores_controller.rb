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
    # FIXING
    # VENEZUELA-C9 (done)
    # GAVIOTAS
    current_location = [params[:currentLatitude].to_f, params[:currentLongitude].to_f]
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
        distance: store["latitude"] ? distance([store["latitude"], store["longitude"]], current_location) : nil
      }
    end

    buggy_store = result.find{ |store| store[:id] === "5c61d43b73f8ee2254b5411f" }
    buggy_store[:latitude] = fix_coords(buggy_store[:latitude])
    buggy_store[:longitude] = fix_coords(buggy_store[:longitude])
    buggy_store[:distance] = distance([buggy_store[:latitude], buggy_store[:longitude]], current_location) 
    result.reject!{ |store| store[:id] == "5c61d43b73f8ee2254b5411f" }
    result << buggy_store

    render json: result.reject{ |store| store[:distance] == nil }.sort_by { |store|  store[:distance] }
  end

  private

  def distance loc1, loc2
    p loc1, loc2
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

  def fix_coords coord
    coord / (10 ** (coord.abs.to_s.size - 2)).to_f
  end

end
