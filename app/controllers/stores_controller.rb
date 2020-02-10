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

    # FIXING
    # VENEZUELA-C9 (done) 5c61d43b73f8ee2254b5411f
    # COLONIAL-C31 (done) 5db20f3e526b6d7ccaa14fae
    venezula_c9 = result.find{ |store| store[:id] === "5c61d43b73f8ee2254b5411f" }
    venezula_c9[:latitude] = fix_coords(venezula_c9[:latitude])
    venezula_c9[:longitude] = fix_coords(venezula_c9[:longitude])
    venezula_c9[:distance] = distance([venezula_c9[:latitude], venezula_c9[:longitude]], current_location)
    colonial_c31 = result.find{ |store| store[:id] === "5db20f3e526b6d7ccaa14fae" }
    colonial_c31[:latitude] = -12.0562
    colonial_c31[:longitude] = -77.1095
    colonial_c31[:distance] = distance([colonial_c31[:latitude], colonial_c31[:longitude]], current_location)
    result.reject! do |store|
      store[:id] == "5c61d43b73f8ee2254b5411f" ||
      store[:id] == "5db20f3e526b6d7ccaa14fae"
    end
    result << venezula_c9
    result << colonial_c31

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
