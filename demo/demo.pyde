def setup():
    size(480, 120)

def draw():
    if  mousePressed:
        fill(10,0,0)
    else:
        fill(50,50,50)
    ellipse(mouseX, mouseY, 80, 80)
