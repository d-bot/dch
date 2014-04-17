#### Timeout condition
```ruby
#!/usr/bin/env ruby

i ||= 0
while i < 6 and `find test -type f |wc -l`.to_i != 0 do
  i += 1
  puts "sleep 2 sec"
  `sleep 2`
end

puts i < 5 ?  "complete" : "abort"
```

#### Instance
```ruby
class Test
	attr_reader :list

	def initialize(f)
		@list = []
	end

	def add_to_list(e)
		@list.concat(e)
	end
end

test = Test.new([1,2,3,4])

test.add_to_list(5)	# Completing list variable in the test object

```

#### Banking Block
```ruby
class Document
	def on_save(&block)
		@save_listener = block # Save code block to instance variable
	end

	def on_load(&block)
		@load_listener = block # Save code block in instance variable
	end

	def load(path)
		@content = File.read(path)
		@load_listener.call(self, path) if @load_listener
	end

	def save(path)
		File.open(path, 'w') { |f| f.print(@content) }
		@save_listener.call(self, path) if @save_listener
	end

end
```

#### Saving code blocks for lazy initialization
```ruby

class BlockBasedArchivalDocument
	attr_reader :title, :author

	def initialize(title, author, &block)
		@title = title
		@author = author
		@initializer_block = block
	end

	def content
		if @initializer_block
			@content = @initializer_block.call
			@initializer_block = nil
		end
		@content
	end

end


file_doc = BlockBasedArchivalDocument.new(‘file’, ‘russ’) do
     File.read(‘some_text_file.txt’)
end

google_doc = BlockBasedArchivalDocument.new(‘http’, ‘russ’) do
     Net::HTTP.get_response(‘www.google.com’, ‘/index.html’).body
end

boring_doc = BlockBasedArchivalDocument.new(‘http’, ‘russ’) do
     “asdfa df ad fadsf” * 100
end

```
