################################################################################
# Global variables - color
################################################################################
color_background = (0, 0, 25)
color_foreground = (60, 7, 86)
color_stroke = (60, 7, 86)

def setup():
  global img
  size(652,250)
  # Make a new instance of a PImage by loading an image file
  # Declaring a variable of type PImage
  img = loadImage("gjb.jpg")
  frameRate(60)
  background(*color_background)
  stroke(*color_foreground)
  fill(*color_foreground)

def draw():
  global img
  background(*color_background)
  fill(*color_background)
  # Draw the image to the screen at coordinate (0,0)
  image(img,0,0)
  
  for i in range(0, 410, 2):
        beginShape()
        for x in range(0, 50, 10):
            for y in range(0,50,10):
                vertex(x,y)
        endShape()
