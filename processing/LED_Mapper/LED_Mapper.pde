import processing.video.*; //<>// //<>// //<>//
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
  size(1280, 480);

  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, camWidth, camHeight, 30);
  } 
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    //println("Available cameras:");
    //printArray(cameras);

    cam = new Capture(this, camWidth, camHeight, 30);
    cam.start();
  }
  opencv = new OpenCV(this, camWidth, camHeight);
  opencv.threshold(15);
  opencv.startBackgroundSubtraction(1, 3, 0.5); //int history, int nMixtures, double backgroundRatio
  //opencv.startBackgroundSubtraction(50, 30, 1.0);

  opc = new OPC(this, IP, 7890);
  opc.setPixelCount(numLeds);

  //stroke(244, 0, 0);
  //strokeWeight(height/12.);
  //print(opc.pixelLocations);
  //for (int i = 0; i < opc.pixelLocations.length; i++) {
  //  println(opc.pixelLocations[i]);
  //}

  animator =new Animator (50, 3, 100); //ledsPerstrip, strips, brightness
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
    image(cam, 0, 0, camWidth, camHeight);
  }

  if (isMapping)sequentialMapping();
  animator.update();
}

void keyPressed() {
  if (key == 's') {
    saveFrame();
  }

  if (key == 'm') {
    isMapping=!isMapping;
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

  cam.read();
  opencv.loadImage(cam);
  // Gray channel
  opencv.gray();
  opencv.contrast(1.35);

  opencv.updateBackground();

  //these help close holes in the binary image
  opencv.dilate();
  opencv.erode();
  opencv.blur(2);

  image(opencv.getSnapshot(), camWidth, 0);


  //// Get the brightest point
  //PVector loc = opencv.max();
  //points[counter] = loc;

  ////draw circle around brightest point detected
  //noFill();
  //ellipse(loc.x, loc.y, 10, 10);

  noFill();
  stroke(255, 0, 0);
  strokeWeight(3);
  for (Contour contour : opencv.findContours()) {
    contour.draw();
  }

  // Print the points
  //if (points.length>0) {
  //  for (int i = 0; i < numLeds; i++) {
  //    //print(points[i]);
  //    point(points[i].x, points[i].y);
  //  }
  //}

  //delay(30);
  //show counter
  //print(counter);

  counter++;
}