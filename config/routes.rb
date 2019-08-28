Rails.application.routes.draw do
  get "/stores", to: "stores#index"
  get "/nearest", to: "stores#nearest_tambo"
end
