#AsyncTCPSocket
##Ruby Asynchronous TCP Socket Implementation 
###Example
```ruby

require 'async_tcpsocket'

socket = AsyncTCPSocket.new 

socket.once :error, Proc.new { |err|
	STDERR.puts "Error: #{err}"
	socket.close
}

socket.once :close, Proc.new { |err|
	socket.close
}

socket.on :data, Proc.new { |data|
	puts "#{data}"
}


socket.connect 'localhost', 80
socket.puts "GET / HTTP 1.1\r\n\r\n"

#wait for return key
gets

socket.close


```


