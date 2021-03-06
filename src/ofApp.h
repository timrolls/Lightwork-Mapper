#pragma once

#include "ofMain.h"
#include "ofxCv.h"
#include "ofxGui.h"
#include "ofxOPC.h"
#include "ofxEditableSvg.h"
#include "ofxJSON.h"

class ofApp : public ofBaseApp{

	public:
		void setup();
		void update();
		void draw();

		void keyPressed(int key);
		void keyReleased(int key);
		void mouseMoved(int x, int y );
		void mouseDragged(int x, int y, int button);
		void mousePressed(int x, int y, int button);
		void mouseReleased(int x, int y, int button);
		void mouseEntered(int x, int y);
		void mouseExited(int x, int y);
		void windowResized(int w, int h);
		void dragEvent(ofDragInfo dragInfo);
		void gotMessage(ofMessage msg);
    
        void chaseAnimation();
		void test();
		void drawMask();
        void setAllLEDColours(ofColor col);
        void generateSVG(vector <ofPoint> points);
        void generateJSON(vector <ofPoint> points);
    
        // OPC
        ofxOPC              opcClient;
        Effects             defaultEffects;
        vector <ofColor>    pixels;
    
        int                 ledIndex;
        int                 numLeds;
        bool                isMapping;
		bool				isTesting;
        int                 ledBrightness;
		ofPolyline			line;
		bool				isMasking;
    
        // Input
        ofVideoGrabber cam;
    
        // Background subtraction
        ofxCv::RunningBackground background;
        ofImage thresholded;
    
        // GUI
        ofxPanel gui;
        ofParameter<bool> resetBackground;
        ofParameter<float> learningTime, thresholdValue;
    
        // Contours
        float                   threshold;
        ofxCv::ContourFinder    contourFinder;
        bool                    showLabels;
        vector <ofPoint>        centroids;
    
        // SVG
        ofxEditableSVG svg;
        
    
};
