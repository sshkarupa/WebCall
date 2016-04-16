require 'sinatra'
require 'dotenv'
require 'pony'

Dotenv.load

Pony.options = {
  via: :smtp,
  charset: "UTF-8",
  via_options: {
    address: 'smtp.gmail.com',
    port: '587',
    domain: 'mail.gmail.com',
    user_name: ENV['USER_NAME'],
    password: ENV['USER_PASSWORD'],
    authentication: :plain
    }
}

helpers do
  def protected!
    request_origin = request.env['HTTP_ORIGIN']
    whitelist = ENV['whitelist'].split
    halt 401 unless whitelist.include?(request_origin)
    headers 'Access-Control-Allow-Origin' => request_origin
  end
end

get '/' do
  'You have reached the test!'
end

post '/' do
  protected!
  email = ""
  params[:data].each { |value| email += "#{value[0]}: #{value[1]}\n" }
  email << "\nfrom: #{request.env['HTTP_ORIGIN']}\n"
  Thread.new do
    Pony.mail(
      to: ENV['SEND_TO'],
      from: "WebCall <#{ENV['USER_NAME']}>",
      subject: "New Contact Form",
      body: email
    )
  end
end

