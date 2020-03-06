################################################################################
# Global variables - color
################################################################################
color_background = (0, 0, 25)
color_foreground = (60, 7, 86)
color_stroke = (60, 7, 86)
white = color(255, 255, 255)
black = color(0,00,0)
pcount = 652*250
a=1

#def setup():
size(652,250)
  # Make a new instance of a PImage by loading an image file
  # Declaring a variable of type PImage
img = loadImage("gjb.jpg")
image(img,0,0)
loadPixels()
for y in range(0,height,1):
    for x in range(0, width, 1):
          if pixels[y*width+x]==pixels[y*width+x-a]:
            pixels[y*width+x]=white
            a+=1
          elif a>1:
            pixels[y*width+x]=black
            a=1
#pixels[(y-1)*width+x]==pixels[(y)*width+x]
updatePixels()


  
