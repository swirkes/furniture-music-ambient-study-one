"""
Example: Read and play an audio file.
Before running this script, the SC server must be started, and the following
SynthDef stored:
SynthDef(\playbuf, { |out = 0, bufnum = 0, gain = 0.0|
    var data = PlayBuf.ar(1, bufnum, loop: 1) * gain.dbamp;
    Out.ar(out, Pan2.ar(data));
}).store;
You will also need to download some sample audio:
curl https://nssdc.gsfc.nasa.gov/planetary/sound/apollo_13_problem.wav -o apollo.wav
"""
import busio
import digitalio
import board
import adafruit_mcp3xxx.mcp3008 as MCP
from adafruit_mcp3xxx.analog_in import AnalogIn
from gpiozero import MotionSensor, LED
from signal import pause
import time
from supercollider import Server, Synth, Buffer
import os
from os import listdir
from os.path import isfile, join
# generate random integer values
from random import seed
from random import randint
import argparse
import random
import time

from pythonosc import udp_client
from pythonosc import osc_message_builder


parser = argparse.ArgumentParser()
parser.add_argument("--ip", default="127.0.0.1", help="The ip of the OSC server")
parser.add_argument("--port", type=int, default=57120, help="The port the OSC server is listening on")
args = parser.parse_args()
# seed random number generator
seed(1)

pianoarr = []

client = udp_client.SimpleUDPClient("192.168.1.114", 57120)
    


def files(path):
	for file in os.listdir("/home/pi/AmbientStudy1Samples/PianoHigh/"):
		if os.path.isfile(os.path.join("/home/pi/AmbientStudy1Samples/PianoHigh/", file)):
			yield file
			
for file in files("."):
	filepathname = "/home/pi/AmbientStudy1Samples/PianoHigh/" + file
	pianoarr.append(filepathname)
	
for x in pianoarr:
	print(x)
	
AUDIO_FILE = "/home/pi/AmbientStudy1Samples/PianoHigh/PianoHigh6.wav"

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

#create motion sensor
pir = MotionSensor(18, False, None, 1, 10, 0.75 )

# create the spi bus
spi = busio.SPI(clock=board.SCK, MISO=board.MISO, MOSI=board.MOSI)

# create the cs (chip select)
cs = digitalio.DigitalInOut(board.D5)

# create the mcp object
mcp = MCP.MCP3008(spi, cs)

# create an analog input channel on pin 0
chan = AnalogIn(mcp, MCP.P0)

try:
	while True:
		if(pir.motion_detected):
			ran = randint(0, len(pianoarr))
			synth = Synth(server, 'playbuf', { "buffer" : bufselect(ran), "rate": rate })
			print('motion detected')
			print('Raw ADC Value: ', chan.value)
			print('ADC Voltage: ' + str(chan.voltage) + 'V')
			msg = osc_message_builder.OscMessageBuilder(address = '/hello')
			msg.add_arg(chan.value, arg_type='f')
			msg = msg.build()
			client.send(msg)
		else:
			print('no motion detected')
			
		time.sleep(1)
except KeyboardInterrupt:
	synth.free()
	print("Press Ctrl-C to terminate")
	pass













