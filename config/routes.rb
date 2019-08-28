Rails.application.routes.draw do
  get "/", to: "welcome#hello"
  get "/stores", to: "stores#index"
  get "/nearest", to: "stores#nearest_tambo"
end
