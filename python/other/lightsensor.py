from gpiozero import LightSensor

sensor = LightSensor(18)

while True:
	sensor.wait_for_light()
	print("It's light! :)")
	sensor.wait_for_light()
	print("it's dark :(")
