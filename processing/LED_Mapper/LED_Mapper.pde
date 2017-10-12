import processing.video.*;
import gab.opencv.*;

OPC opc;
Capture cam;
OpenCV opencv;

int counter = 0;
int numLeds = 150;
PVector[] points = new PVector[numLeds];

boolean isMapping=false;

color on = color(255, 255, 255);
color off = color(0, 0, 0);

int camX =640;
int camY =480;

void setup()
{
  size(640, 480);
  opencv = new OpenCV(this, width, height);

   String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, camX, camY,30);
  } if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    printArray(cameras);

    // The camera can be initialized directly using an element
    // from the array returned by list():
    cam = new Capture(this, camX, camY,30);
    // Or, the settings can be defined based on the text in the list
    //cam = new Capture(this, 640, 480, "Built-in iSight", 30);
    
    // Start capturing the images from the camera
    cam.start();
  }

  opencv.startBackgroundSubtraction(5, 3, 0.5);
  //opencv.startBackgroundSubtraction(50, 30, 1.0);

  // Connect to the local instance of fcserver
  //opc = new OPC(this, "127.0.0.1", 7890);
  // Connect with the Raspberry Pi FadeCandy server
  opc = new OPC(this, "fade1.local", 7890);

  //colorMode(RGB, 100);
  // Map an 5x10 grid of LEDs to the center of the window
  //opc.ledGrid5x10(0, width/2, height/2, height / 12.0, 0, true);

  //stroke(244, 0, 0);
  //strokeWeight(height/12.);
  //print(opc.pixelLocations);
  //for (int i = 0; i < opc.pixelLocations.length; i++) {
  //  println(opc.pixelLocations[i]);
  //}

  //Turn off all pixels at launch - set in draw once s
  for (int i=0; i<numLeds; i++) {
    opc.setPixel(i, off);
  }

  background(0);
}

void draw()
{
  if (opc.isConnected()) {
    opc.writePixels();
  }

  // Display the camera input
  if (cam.available()) {
    cam.read();
  }
      image(cam, 0, 0, width, height);


  if (isMapping&&opc.isConnected()) {
    sequentialMapping();
  }
}


void keyPressed() {
  if (key == 's') {
    saveFrame();
  }

  if (key == 'm') {
    isMapping=!isMapping;
  }
}

void sequentialMapping() {
  // Light up LEDs sequentially 
  opc.setPixel(counter, on);
  opc.writePixels();

  // Get a new camera frame after we turn the LED on
  if (cam.available() == true) {
    cam.read();
    opencv.loadImage(cam);

    // Background differencing 
    opencv.updateBackground();

    //delay(1000);
  }

  // Calibration over, display the results
  if (counter >=  numLeds) {
    counter = 0;
    //noLoop();
    background(0);
    // Print the points
    for (int i = 0; i < numLeds; i++) {
      //print(points[i]);
      point(points[i].x, points[i].y);
    }
  }

  // Get the brightest point
  //image(opencv.getOutput(), 0, 0); 
  PVector loc = opencv.max();
  points[counter] = loc;

  //draw circle around brightest point detected
  stroke(255, 0, 0);
  strokeWeight(4);
  noFill();
  ellipse(loc.x, loc.y, 10, 10);

  delay(30);
  //show counter
  //print(counter);

  // Turn the LED off when we've detected its location
  opc.setPixel(counter, off);
  opc.writePixels();

  counter++;
}