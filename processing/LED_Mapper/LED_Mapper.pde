// //<>//
//  LED_Mapper.pde
//  Lightwork-Mapper
//
//  Created by Leo Stefansson and Tim Rolls 
//
//  This sketch uses computer vision to automatically generate mapping for LEDs.
//  Currently, Fadecandy is supported.

import processing.video.*; 
import gab.opencv.*;

OPC opc;
Capture cam;
OpenCV opencv;
Animator animator;

int counter = 0;

boolean isMapping=false;

color on = color(255, 255, 255);
color off = color(0, 0, 0);

int camWidth =640;
int camHeight =480;
float camAspect = (float)camWidth / (float)camHeight;

//LED defaults
String IP = "fade1.local";
int ledsPerStrip =50;
int strips = 3;
int numLeds = ledsPerStrip*strips;
int ledBrightness = 50;

PVector[] points = new PVector[numLeds];

void setup()
{
  size(640, 960);

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
  opencv.threshold(10);
  opencv.startBackgroundSubtraction(0, 5, 0.5); //int history, int nMixtures, double backgroundRatio
  //opencv.startBackgroundSubtraction(50, 30, 1.0);

  opc = new OPC(this, IP, 7890);
  opc.setPixelCount(numLeds);

  animator =new Animator (ledsPerStrip, strips, ledBrightness); //ledsPerstrip, strips, brightness
  animator.setMode(animationMode.OFF);
  animator.setFrameSkip(10);
  animator.setAllLEDColours(off); // Clear the LED strips

  background(0);
}

void draw()
{

  // Display the camera input and processed binary image
  if (cam.available()) {
    cam.read();
    image(cam, 0, 0, camWidth, camHeight);

    opencv.loadImage(cam);
    // Gray channel
    opencv.gray();
    opencv.contrast(1.35);
    opencv.updateBackground();

    //these help close holes in the binary image
    opencv.dilate();
    opencv.erode();
    opencv.blur(2);
    //opencv.
    image(opencv.getSnapshot(), 0, camHeight);
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

  //cam.read();
  //opencv.loadImage(cam);
  //opencv.updateBackground();

  ////these help close holes in the binary image
  //opencv.dilate();
  //opencv.erode();
  //opencv.blur(2);


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