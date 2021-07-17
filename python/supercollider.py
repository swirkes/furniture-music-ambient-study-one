from supercollider import Server, Synth, Buffer
import time

server = Server()

#-------------------------------------------------------------------------------
# Read sample data into a Buffer.
#-------------------------------------------------------------------------------
buf = Buffer.read(server, AUDIO_FILE)
buf_info = buf.get_info()
print("Read buffer, sample rate %d, duration %.1fs" % (buf_info["sample_rate"], buf_info["num_frames"] / buf_info["sample_rate"]))

def bufselect(x):
	buf = Buffer.read(server, pianoarr[x])
	return buf


#-------------------------------------------------------------------------------
# Calculate the required playback rate (akin to SC BufRateScale.kr)
# and begin playback.
#-------------------------------------------------------------------------------
server_status = server.get_status()
server_sample_rate = server_status["sample_rate_nominal"]
buffer_sample_rate = buf_info["sample_rate"]
rate = buffer_sample_rate / server_sample_rate