import argparse
import random
import time

from pythonosc import udp_client
from pythonosc import osc_message_builder

parser = argparse.ArgumentParser()
parser.add_argument("--ip", default="127.0.0.1", help="The ip of the OSC server")
parser.add_argument("--port", type=int, default=57120, help="The port the OSC server is listening on")
args = parser.parse_args()

client = udp_client.SimpleUDPClient("192.168.1.114", 57120)