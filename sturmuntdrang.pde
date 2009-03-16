// Set the font and its size (in units of pixels) 

int xWidth = 1280, yHeight = 720;

int total = 1000;
Bouncer[] bouncer =  new Bouncer[total];
Flock flock;

boolean clear = true;
boolean click = false;

int counter = 0;
int strokeVar = 2;

boolean makeMovie = false;
boolean useCamera = false;
import processing.video.*;

MovieMaker mm;

void setup() {

  size(900,500);
  //size(1280,720);
  noStroke();
  fill(100);
  rect(0,0,width,height);

  for (int i=0; i<total; i++){
    bouncer[i] = new Bouncer(width/2, height/2 + random(-5,5), random(-75,75), random(-2,2), random(-2,2));
  }
  
  flock = new Flock();
  // Add an initial set of boids into the system
  for (int i = 0; i < 150; i++) {
    flock.addBoid(new Boid(new PVector(width/2,height/2),2.0,0.05));
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
  
  flock.run();

  for (int i=0; i<total; i++){
    bouncer[i].bounce();
  }
  
  // Add window's pixels to movie
  if (makeMovie) mm.addFrame();

} 

void mouseReleased () {
  click = false;
}

void drawState(){
  if (clear){
    noStroke();
    fill(100);
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

class Bouncer {
  float xPos;
  float yPos;
  float xOld = mouseX;
  float yOld = mouseY;
  float x2Old = mouseX;
  float y2Old = mouseY;
  float left = 0;
  float right = width;
  float floor = height/2 + random(-2,2);
  float ceiling = 0;
  float friction = random(0.3f,0.7f);
  float elastic = random(0.3f,0.7f);
  float gravity;
  float rot;
  float xd, yd;
  float xVel, newXVel;
  float yVel, newYVel;
  float xDelta, yDelta, distance;
  Bouncer (float xp, float yp, float rp, float xv, float yv) {
    xPos = xp;
    yPos = yp;
    rot = rp;
    xVel = xv;
    yVel = yv;
  }

  void bounce () {
    x2Old = xOld;
    y2Old = yOld;
    xOld = xPos;
    yOld = yPos;
    
    if (yPos > floor){
      gravity = -1;
    } else {
      gravity = 1;
    }
    
    yVel = yVel + (gravity * elastic);
    xPos = xPos + xVel;
    yPos = yPos + yVel;

      if (xPos > right){
        xPos = right;
        xVel = xVel * -elastic;
      } else if (xPos < left){
        xPos = left;
        xVel = xVel * -elastic;
      }
    if (!click){
      if (gravity == 1){
        if (yPos > floor){
          yVel = yVel * elastic;
          xVel = xVel * friction;
          gravity = -1;
        }
      } else {
        if (yPos < floor){
          yVel = yVel * elastic;
          xVel = xVel * friction;
          gravity = 1;
        }
      }
    }
    
    xDelta = mouseX - xPos;
    yDelta = mouseY - yPos;
    distance = sqrt(sq(xDelta) + sq(yDelta));
    
    if (!click && distance < 50){
      //gravity = gravity * -1;
      if (mouseX > pmouseX){
        xd = mouseX - pmouseX;
        if (xd > 20){
          xd = 20;
        }
        xVel = random(0,xd);
      } else if (pmouseX > mouseX){
        xd = mouseX - pmouseX;
        if (xd < -20){
          xd = -20;
        }
        xVel = random(xd,0);
      } else {
        xVel = random(-5,5);
      }
      
      if (mouseY > pmouseY){
        yd = mouseY - pmouseY;
        if (yd > 20){
          yd = 20;
        }
        yVel = random(0,yd);
      } else if (pmouseY > mouseY){
        yd = mouseY - pmouseY;
        if (yd < -20){
          yd = -20;
        }
        yVel = random(yd,0);
      } else {
        yVel = random(-5,5);
      }
      
    } else if (click && distance < 250){
      newXVel = xVel * elastic + (mouseX - xPos) * friction;
      newYVel = yVel * elastic + (mouseY - yPos) * friction;
      xVel = xVel - ((xVel - newXVel) * .05f);
      yVel = yVel - ((yVel - newYVel) * .05f);
    }
    

    strokeWeight(strokeVar);
    stroke((abs(yVel) + abs(xVel))*2);
    line(xPos, yPos, xOld, yOld);
    strokeWeight(strokeVar/2);
    stroke((abs(yVel) + abs(xVel))*4,0,0);
    line(xPos, yPos, xOld, yOld);
    strokeWeight(strokeVar/4);
    stroke((abs(yVel) + abs(xVel))*16,0,0);
    line(xOld, yOld, x2Old, y2Old);
  }
}



// The Boid class

class Boid {

  PVector loc;
  PVector vel;
  PVector acc;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  int health;

  Boid(PVector l, float ms, float mf) {
    acc = new PVector(0,0);
    vel = new PVector(random(-1,1),random(-1,1));
    loc = l.get();
    r = 2.0;
    maxspeed = ms;
    maxforce = mf;
    health = 0;
  }
  
  void run(ArrayList boids) {
    flock(boids);
    update();
    borders();
    render();
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    // Arbitrarily weight these forces
    sep.mult(2.0);
    ali.mult(1.0);
    coh.mult(1.0);
    // Add the force vectors to acceleration
    acc.add(sep);
    acc.add(ali);
    acc.add(coh);
  }
  
  // Method to update location
  void update() {
    // Update velocity
    vel.add(acc);
    // Limit speed
    vel.limit(maxspeed);
    loc.add(vel);
    // Reset accelertion to 0 each cycle
    acc.mult(0);
  }

  void seek(PVector target) {
    acc.add(steer(target,false));
  }
 
  void arrive(PVector target) {
    acc.add(steer(target,true));
  }

  // A method that calculates a steering vector towards a target
  // Takes a second argument, if true, it slows down as it approaches the target
  PVector steer(PVector target, boolean slowdown) {
    PVector steer;  // The steering vector
    PVector desired = target.sub(target,loc);  // A vector pointing from the location to the target
    float d = desired.mag(); // Distance from the target is the magnitude of the vector
    // If the distance is greater than 0, calc steering (otherwise return zero vector)
    if (d > 0) {
      // Normalize desired
      desired.normalize();
      // Two options for desired vector magnitude (1 -- based on distance, 2 -- maxspeed)
      if ((slowdown) && (d < 100.0)) desired.mult(maxspeed*(d/100.0)); // This damping is somewhat arbitrary
      else desired.mult(maxspeed);
      // Steering = Desired minus Velocity
      steer = target.sub(desired,vel);
      steer.limit(maxforce);  // Limit to maximum steering force
    } else {
      steer = new PVector(0,0);
    }
    return steer;
  }
  
  void render() {
    // Draw a triangle rotated in the direction of velocity
    float theta = vel.heading2D() + PI/2;
    float rsize = r + health/2;
    fill(102, 102, health*10);
    stroke(200, 100, health*10);
    pushMatrix();
    translate(loc.x,loc.y);
    rotate(theta);
//    beginShape(TRIANGLES);
//    vertex(0, -rsize);
//    vertex(-rsize, rsize+r);
//    vertex(rsize, rsize+r);
//    endShape();
    ellipse(0,0, rsize, rsize*2);
    popMatrix();
  }
  
  // Wraparound
  void borders() {
    if (loc.x < -r) loc.x = width+r;
    if (loc.y < -r) loc.y = height+r;
    if (loc.x > width+r) loc.x = -r;
    if (loc.y > height+r) loc.y = -r;
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList boids) {
    float desiredseparation = 25.0;
    PVector sum = new PVector(0,0,0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (int i = 0 ; i < boids.size(); i++) {
      Boid other = (Boid) boids.get(i);
      float d = loc.dist(other.loc);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = loc.sub(loc,other.loc);
        diff.normalize();
        diff.div(d);        // Weight by distance
        sum.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      sum.div((float)count);
    }
   
    return sum;
  }
  
  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (ArrayList boids) {
    float neighbordist = 50.0;
    PVector sum = new PVector(0,0,0);
    int count = 0;
    for (int i = 0 ; i < boids.size(); i++) {
      Boid other = (Boid) boids.get(i);
      float d = loc.dist(other.loc);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.vel);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      sum.limit(maxforce);
    }
    return sum;
  }

  // Cohesion
  // For the average location (i.e. center) of all nearby boids, calculate steering vector towards that location
  PVector cohesion (ArrayList boids) {
    float neighbordist = 50.0;
    float healthdist = 100.0;
    PVector sum = new PVector(0,0);   // Start with empty vector to accumulate all locations
    int count = 0;
    health = 0;
    for (int i = 0 ; i < boids.size(); i++) {
      Boid other = (Boid) boids.get(i);
      float d = loc.dist(other.loc);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.loc); // Add location
        count++;
      }
      if ((d > 0) && (d < neighbordist)) {
        health++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      return steer(sum,false);  // Steer towards the location
    }
    return sum;
  }
}




// The Flock (a list of Boid objects)

class Flock {
  ArrayList boids; // An arraylist for all the boids

  Flock() {
    boids = new ArrayList(); // Initialize the arraylist
  }

  void run() {
    for (int i = 0; i < boids.size(); i++) {
      Boid b = (Boid) boids.get(i);  
      b.run(boids);  // Passing the entire list of boids to each boid individually
    }
  }

  void addBoid(Boid b) {
    boids.add(b);
  }

}

