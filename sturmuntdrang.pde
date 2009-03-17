// Set the font and its size (in units of pixels) 

int xWidth = 1280, yHeight = 720;

int total = 1000;
Jumble jumble;
Shoal shoal;

boolean clear = true;
boolean click = false;

int counter = 0;
int strokeVar = 2;

boolean makeMovie = false;
boolean useCamera = false;
import processing.video.*;

MovieMaker mm;

void setup() {

  size(xWidth,yHeight);
  //size(1280,720);
  noStroke();
  fill(100);
  rect(0,0,width,height);

  jumble = new Jumble();
  for (int i=0; i<total; i++){
    jumble.addBouncer(new Bouncer(width/2, height/2 + random(-5,5), random(-75,75), random(-2,2), random(-2,2)));
  }
  
  shoal = new Shoal();
  // Add an initial set of Fishs into the system
  for (int i = 0; i < 150; i++) {
    shoal.addFish(new Fish(new PVector(width/2,height/2),2.0,0.05));
  }
  //smooth();
    // Save compressed
  if (makeMovie)
    mm = new MovieMaker(this, width, height, "sturmuntdrang.mov", 20, MovieMaker.VIDEO, MovieMaker.HIGH);

}
 
void draw() {
  drawState();
  if(keyPressed) { 
    if (key == '1') { 
      strokeVar = 1;
    } else if (key == '2') {
      strokeVar = 2;
    } else if (key == '3') {
      strokeVar = 3;
    } else if (key == '4') {
      strokeVar = 4;
    } else if (key == '5') {
      strokeVar = 5;
    }
  }
  
  if (mousePressed){
    click = true;
  }
  
  shoal.run();

  jumble.run(shoal);
  
  // Add window's pixels to movie
  if (makeMovie) mm.addFrame();

} 

void mouseReleased () {
  click = false;
}

void drawState(){
  if (clear){
    noStroke();
    fill(0);
    rect(0,0,width,height);
  }
}

void keyReleased () {
  if (key == ' ' && clear) { 
    clear = false;
  } else if (key == ' ' && !clear) {
    clear = true;
  }
}




