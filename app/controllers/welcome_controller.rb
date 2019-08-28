class WelcomeController < ApplicationController
  
  def hello
    message = "Welcome to tambo-api"
    description = "A little tambo+ api with rails"
    author = "@cristianbgp"
    routes = ["/stores", "/nearest"]
    result = 
    {
      message: message,
      description: description,
      author: author,
      routes: routes
    }
    render json: result
  end

end
