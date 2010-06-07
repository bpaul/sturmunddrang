import processing.opengl.*;



// Set the font and its size (in units of pixels) 

int xWidth = 1024, yHeight = 768;

int total = 1000;
Jumble jumble;
Shoal shoal;
Sound sound;
PImage backgroundImage, backgroundImage2;

boolean clear = false;
boolean click = false;
boolean soundOn = false;
float index = 0;
int counter = 0;
int strokeVar = 5;

boolean makeMovie = false;
boolean useCamera = false;
import processing.video.*;

MovieMaker mm;

void setup() {
  // start the sound
  sound = new Sound();
  sound.init(this);

  size(xWidth,yHeight, JAVA2D);
  //size(1280,720);
  noStroke();
  fill(100);
  rect(0,0,width,height);
  backgroundImage = loadImage("background5.gif");
  backgroundImage2 = loadImage("background2.png");
  
  jumble = new Jumble();
  for (int i=0; i<total; i++){
    jumble.addBouncer(new Bouncer(random(width), height/2 + random(-50,50), random(-75,75), random(-2,2), random(-2,2)));
  }
  
  shoal = new Shoal();
  // Add an initial set of Fishs into the system
  for (int i = 0; i < 150; i++) {
    shoal.addFish(new Fish(new PVector(width*random(1),height*noise(i)),2.0+2.0*noise(i),0.05+0.025*noise(i)));
  }
  //smooth();
    // Save compressed
  if (makeMovie)
    mm = new MovieMaker(this, width, height, "sturmuntdrang.mov", 20, MovieMaker.VIDEO, MovieMaker.HIGH);

}
 
void draw() {
  drawState();
  
  float tinter = 255 * noise(index++);
  float xer, yer;
  //tint(255, 255, 255, 126);
  //image(backgroundImage2, 0, 0);
  //tint(200+tinter, 200+tinter, 200+tinter, 255);
  image(backgroundImage, 0, 0);

  
  if(keyPressed) { 
    if (key == '1') { 
      strokeVar = 1;
    } else    if (key == 's') { 
      soundOn = !soundOn;
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

  xer = 63 - tinter;
  yer = 63 - (126 * random(1));
  //tint(255, 255, 255, 200);
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
    if (soundOn)
      fill(50,  50*sound.level(), 50*sound.level());
    ellipse(width/2, height/2, width, height/2);
   }
}

void keyReleased () {
  if (key == ' ' && clear) { 
    clear = false;
  } else if (key == ' ' && !clear) {
    clear = true;
  }
}




