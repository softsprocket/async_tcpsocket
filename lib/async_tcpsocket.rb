require 'socket'
require 'thread'
require 'async_emitter'

#######################################################################
# An asyncronous TCP socket implementation (wraps TCPSocket)
#
# Inherits AsyncEmitter and emits three events, :data, :close and :error.
# :data is emitted when data is recieved,
# :close is emitted if the other side closes the connection and it is detected,
# :error emits errors
#
# ==Example
# 
#    require 'async_tcpsocket'
#    
#    socket = AsyncTCPSocket.new 
#    
#    socket.once :error, Proc.new { |err|
#        STDERR.puts "Error: #{err}"
#        socket.close
#    }
#    
#    socket.once :close, Proc.new { |err|
#       socket.close
#    }
#    
#    socket.on :data, Proc.new { |data|
#       puts "#{data}"
#    }
#    
#    socket.connect 'localhost', 80
#    socket.puts "GET / HTTP 1.1\r\n\r\n"
#    
#    #wait for return key
#    gets
#
#    socket.close
#
# @author Greg Martin
##########################################################################
class AsyncTCPSocket < AsyncEmitter

	#################################################################
	# constructor 
	#
	# @param socket [TCPSocket] or nil
	################################################################# 
	def initialize (socket=nil)
		super()
		@socket = socket
		@write_data = nil
		@write_semaphore = Mutex.new
		@write_cv = ConditionVariable.new

		if socket != nil
			threads
		end
	end

	#################################################################
	# connect to a server - if the socket is already connected it 
	# will be closed
	#
	# @param host [String] the server host address
	# @param port [FixedNum] the server port
	#################################################################
	def connect (host, port)
		close

		begin
			@socket = TCPSocket.new host, port
		rescue Exception => e
			emit :error, e
		end

		threads
	end	

	################################################################
	# closes the connection
	###############################################################
	def close 
		if @socket != nil
			@socket.close
			Thread.kill @read_thread
			Thread.kill @write_thread
			@socket = nil
		end
	end

	################################################################
	# sends data asyncronously - non-string objects will need to be 
	# serialized
	#
	# @param data [Object] - the data to send
	# #############################################################
	def puts data
		@write_semaphore.synchronize do
			@write_data = data
			@write_cv.signal
		end
	end

	protected
	def threads
		init_sem = Mutex.new
		cv = ConditionVariable.new

		@read_thread = Thread.new do
			loop do
				data = @socket.gets
				if data == nil
					e = Exception.exception ("socket closed")
					emit :close, e
					break
				else
					emit :data, data
				end
			end		
		end

		@write_thread = Thread.new do
			loop do
				@write_semaphore.synchronize do
					init_sem.synchronize do
						cv.signal
					end

					@write_cv.wait @write_semaphore
					begin
						@socket.puts @write_data
					rescue Exception => e
						emit :error, e
					end

				end
			end			
		end

		init_sem.synchronize do
			cv.wait init_sem
		end
				
	end

end

