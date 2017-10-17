import processing.video.*; //<>//
import gab.opencv.*;

OPC opc;
Capture cam;
OpenCV opencv;
Animator animator;

int counter = 0;
int numLeds = 150;
PVector[] points = new PVector[numLeds];

boolean isMapping=false;

color on = color(255, 255, 255);
color off = color(0, 0, 0);

int camWidth =640;
int camHeight =480;
float camAspect = (float)camWidth / (float)camHeight;

String IP = "fade1.local";

void setup()
{
  size(640, 480);
  opencv = new OpenCV(this, width, height);

  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, camWidth, camHeight, 30);
  } 
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    printArray(cameras);

    // The camera can be initialized directly using an element
    // from the array returned by list():
    cam = new Capture(this, camWidth, camHeight, 30);
    // Or, the settings can be defined based on the text in the list
    //cam = new Capture(this, 640, 480, "Built-in iSight", 30);

    // Start capturing the images from the camera
    cam.start();
  }

  opencv.startBackgroundSubtraction(5, 3, 0.5);
  //opencv.startBackgroundSubtraction(50, 30, 1.0);

  opc = new OPC(this, IP, 7890);
  opc.setPixelCount(numLeds);

  //stroke(244, 0, 0);
  //strokeWeight(height/12.);
  //print(opc.pixelLocations);
  //for (int i = 0; i < opc.pixelLocations.length; i++) {
  //  println(opc.pixelLocations[i]);
  //}

  animator =new Animator (64, 8, 255); //ledsPerstrip, strips, brightness
  animator.setMode(animationMode.OFF);
  animator.setFrameSkip(5);
  animator.setAllLEDColours(color(0, 0, 0)); // Clear the LED strips

  //Turn off all pixels at launch - set in draw once 
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

  animator.update();
}


void keyPressed() {
  if (key == 's') {
    saveFrame();
  }

  if (key == 'm') {
    if (animator.getMode()!=animationMode.CHASE) {
      animator.setMode(animationMode.CHASE);
      println("Chase mode");
    } else {
      animator.setMode(animationMode.OFF);
      println("Animator off");
    }
  }

  if (key == 't') {
    if (animator.getMode()!=animationMode.TEST) {
      animator.setMode(animationMode.TEST);
      println("Test mode");
    } else {
      animator.setMode(animationMode.OFF);
      println("Animator off");
    }
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