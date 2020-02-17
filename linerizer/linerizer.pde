import drop.*;
import java.io.File;

SDrop drop;
PImage input;
PImage prepared;
PImage output;
int width, height;
int pixelsize = 3;
ArrayList<Point> path;
// stuff for animation
int step = 1;
int speed = 120;
boolean inverted = false;
boolean readyToDraw = false;
boolean killThreads = true;

void setup () {
    size(500, 100);
    surface.setResizable(true);
    drop = new SDrop(this);
    textSize(32);
}

void draw () {
    if (path == null) {
        fill(20);
        text("Drop an image here ...", 10, 60);
        return;
    }
    if (step < path.size() - 1){
        if (input != null) image(input, 0,0);
    } else {
        if (inverted) {
            background(20);
        } else {
            background(235);
        }
    }
    if (readyToDraw) {
        animatedPath(path, pixelsize, speed);
    }
    // displayPath(path, pixelsize);
}

void mouseClicked () {
    readyToDraw = false;
    // kill other path-calculating threads if still open
    killThreads = true;
    inverted = mouseY > input.height/2;
    step = 1;
    int threshold = (int) map(mouseX, 0, input.width, 0, 255);
    output = floydSteinberg(prepared, threshold);
    thread("neighborPathFromImage");
}

void dropEvent (DropEvent event) {
    if (event.isFile() && event.isImage()) {
        // don't use event.loadImage() because it runs in a seperate thread :(
        File f = event.file();
        input = loadImage(f.getAbsolutePath());
        // make a copy of input
        prepared = input.get(0, 0, input.width, input.height);
        // determine size
        if (input.height <= input.width) {
            width = 300;
            prepared.resize(width, 0);
            height = prepared.height;
        } else {
            height = 300;
            prepared.resize(0, height);
            width = prepared.width;
        }
        surface.setSize(width*pixelsize, height*pixelsize);
        prepared.filter(GRAY);
        output = floydSteinberg(prepared, 128);
        neighborPathFromImage();
        // scale input
        input.resize(width*pixelsize, 0);
    }
}


void displayPixels (PImage image, int pixelwidth) {
    noStroke();
    for (int y=0; y<image.height; y++) {
        for (int x=0; x<image.width; x++) {
            int loc = x + y * image.width;
            fill(image.pixels[loc]);
            rect(x*pixelwidth, y*pixelwidth, pixelwidth, pixelwidth);
        }
    }
}

void animatedPath(ArrayList<Point> points, float scale, int speed) {
    if (inverted) {
        stroke(235);
    } else {
        stroke(20);
    }
    for (int i=0; i<step; i++) {
        try {
            Point from = path.get(i);
            Point to = path.get(i+1);
            line(from.x*pixelsize, from.y*pixelsize, to.x*pixelsize, to.y*pixelsize);
        } catch (IndexOutOfBoundsException e) {
            // might happen if starts writing to path
            // simply stop drawing in that case
            return;
        }
    }
    if (!(step + speed > path.size()-1)) {
        step += speed;
    } else {
        step = path.size() - 1;
    }
}

void displayPath (ArrayList<Point> points, float scale) {
    background(255);
    stroke(0);
    for (int i=0; i<points.size()-1; i++) {
        Point from = points.get(i);
        Point to = points.get(i+1);
        line(from.x*scale, from.y*scale, to.x*scale, to.y*scale);
    }
}

PImage errorDiffusion (PImage in, int threshold) {
    PImage out = createImage(in.width, in.height, RGB);
    in.loadPixels();
    out.loadPixels();
    float err = 0;
    float tmp;
    for (int i=0; i<in.width*in.height; ++i) {
        tmp = brightness(in.pixels[i]) + err;
        if (tmp > threshold) {
            out.pixels[i] = color(255);
            err = brightness(in.pixels[i]) - 255;
        } else {
            out.pixels[i] = color(0);
            err = 255 - brightness(in.pixels[i]);
        }
    }
    return out;
}

PImage floydSteinberg (PImage in, int threshold) {
    // the cooler errorDiffusion
    // copy input image
    PImage out = in.get(0, 0, in.width, in.height);
    out.loadPixels();
    float tmp;
    float err;
    color newcolor;
    for (int y=0; y<out.height-1; y++) {
        for (int x=0; x<out.width-1; x++) {
            tmp = brightness(out.pixels[x + y * out.width]);
            if (tmp > threshold) {
                newcolor = color(255);
            } else {
                newcolor = color(0);
            }
            err = tmp - brightness(newcolor);
            out.pixels[x + y * out.width] = newcolor;
            out.pixels[x+1 + y * out.width] += err * 7/16;
            out.pixels[x-1 + (y+1) * out.width] += err * 3/16;
            out.pixels[x + (y+1) * out.width] += err * 5/16;
            out.pixels[x+1 + (y+1) * out.width] += err * 1/16;
        }
    }
    return out;
}

void neighborPathFromImage () {
    int col;
    if (inverted) {
        col = 255;
    } else {
        col = 0;
    }
    PImage img = output;
    // get all black points
    ArrayList<Point> points = new ArrayList<Point>();
    for (int y=0; y<img.height; y++) {
        for (int x=0; x<img.width; x++) {
            if (brightness(img.pixels[x + y*img.width]) == col) {
                points.add(new Point(x, y));
            }
        }
    }
    // construct path through nearest neighbors
    closestNeighborPath(points);
}

void closestNeighborPath (ArrayList<Point> pointList) {
    // writes the list of points folling the nearest neighbor
    // to global path (ArrayList<Point>) variable
    // using linear search

    if (killThreads) killThreads = false;
    // don't start the animated draw, because path is empty right now
    path = new ArrayList<Point>();
    Point current = pointList.get(0);
    pointList.remove(0);
    while (pointList.size() > 0) {
        int min = current.square_distance(pointList.get(0));
        int neighborIndex = 0;
        for (int i=0; i<pointList.size()-1; i++) {
            if (killThreads) return;
            int dist = current.square_distance(pointList.get(i));
            if (dist < min) {
                min = dist;
                neighborIndex = i;
            }
        }
        Point neighbor = pointList.get(neighborIndex);
        pointList.remove(neighborIndex);
        path.add(neighbor);
        current = neighbor;
        // as soon as there are more than speed points in path,
        // it's safe to start drawing them
        if ((path.size() > speed) && !readyToDraw) readyToDraw = true;
    }
}

class Point {
    int x, y;

    Point (int x, int y) {
        this.x = x;
        this.y = y;
    }

    int square_distance (Point p) {
        return (x - p.x)*(x - p.x) + (y - p.y)*(y - p.y);
    }
}
