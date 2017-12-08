// 3D Pixel Scraper

public class Scraper {
  LED[] leds; 
  int depth; // Z coordinate scaling
  Table table; // For loading CSV
  int sphereRadius = 15; 
  HashMap <Integer, Integer> addressMap = new HashMap<Integer, Integer>(); // LED Index:Adress  - Look up address to return the index of a given LED

  Scraper(LED[] ledArray) {  
    leds = ledArray; 
    for (int i = 0; i < leds.length; i++) {
      addressMap.put(i, leds[i].address);
    }
    depth = 800; // Z coordinate scaling
  }

  //show points in output window
  void display() {

    for (int i = 0; i < leds.length; i++) {
      pushMatrix(); 
      translate(leds[i].coord.x-width/2, leds[i].coord.y-height/2, leds[i].coord.z); 
      fill(255); 
      sphere(sphereRadius);  
      translate(0, 0, 10); 
      //fill(255, 0, 0); 
      //text(i, 0, 0); 

      popMatrix();
    }
  }

  //update colors to be sent for next network packet
  void update() {
    // Populate LEDs with colours
    // TODO: Make this not random
    for (int i = 0; i<leds.length; i++) {
      color c = color((int)random(255), (int)random(255), (int)random(255));
      leds[i].c = c;
    }
  }

  void updateColorAtIndex(color c, int index) {
    int ledAddress = addressMap.get(index); 
    //hm.put(address, c);
    leds[ledAddress].c = c;
  }
}