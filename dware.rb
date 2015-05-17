class Dware
	def initialize(app)
		@app = app
	end

	def call(env)
		response = []
		if(@app)
			@app.call(env)[2].each { |body| response << body }
		end

		["200", {"Content-Type" => "text/html", "X-Forwarded-Header" => "DCH", "X-Found-Header" => "You found this!"}, response]
	end
end
