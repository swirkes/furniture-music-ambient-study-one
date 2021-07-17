from gpiozero import MotionSensor, LED

#create motion sensor
pir = MotionSensor(18, False, None, 1, 10, 0.75 )