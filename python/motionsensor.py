from gpiozero import MotionSensor, LED
from signal import pause
import time


pir = MotionSensor(4, False, None, 1, 10, 0.75 )
led = LED(16)


pir.when_motion = led.on
pir.when_no_motion = led.off

while True:
	if(pir.motion_detected):
		print('motion detected')
	else:
		 print('no motion detected')
	time.sleep(1)
