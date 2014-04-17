require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra'
require 'redcarpet'

use Rack::Auth::Basic, "Restricted Area" do |username, password|
  username == 'dylan' and password == 'test'
end

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end

	def m_down(file)
		redcarpet = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :fenced_code_blocks => true, :disable_indented_code_blocks => true)
		markdown = redcarpet.render(File.read(file))
	end
end

=begin
before '/secure/*' do
  if !session[:identity] then
    session[:previous_url] = request.path
    @error = 'Sorry guacamole, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end
=end

get '/' do
  erb "<div class='container'><br><h6>dch.io @2014</h6><img src=vendor/imgs/genius.png width=600 height=328><br><br><br><br><br><br><br></div>"
end

get '/rtt' do
	#headers['Cache-Control'] = 'no-cache'
  erb :rtt
end

get '/dns-lookup' do
	#headers['Cache-Control'] = 'no-cache'
  erb :dns_lookup
end

get '/tcp-handshake' do
  erb :tcp_handshake
end

get '/tls-handshake' do
  erb :tls_handshake
end

get '/time-to-first-byte' do
  erb :time_to_first_byte
end

get '/handshake-vs-rtt' do
  erb :handshake_rtt
end

get '/breakdown' do
  erb :breakdown
end

get '/test' do
  erb :test
end

get '/code' do
	@converted = m_down('views/md_test.md')
	erb :code
end

=begin
get '/login/form' do 
  erb :login_form
end

post '/login/attempt' do
  session[:identity] = params['username']
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from 
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end


get '/secure/place' do
  erb "This is a secret place that only <%=session[:identity]%> has access to!"
end
=end
