// The Fish class

class Fish {

  PVector loc;
  PVector vel;
  PVector acc;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  int health;
  float tailpos;

  Fish(PVector l, float ms, float mf) {
    acc = new PVector(0,0);
    vel = new PVector(random(-1,1),random(-1,1));
    loc = l.get();
    r = 3.0+random(-1,1);
    maxspeed = ms;
    maxforce = mf;
    health = 1;
    tailpos = 0;
  }
  
  void run(ArrayList fishes) {
    shoal(fishes);
    update();
    borders();
    render();
  }

  // We accumulate a new acceleration each time based on three rules
  void shoal(ArrayList fishes) {
    PVector sep = separate(fishes);   // Separation
    PVector ali = align(fishes);      // Alignment
    PVector coh = cohesion(fishes);   // Cohesion
    PVector bds = bounds();
    
    // Arbitrarily weight these forces
    sep.mult(3.0);
    ali.mult(1.0);
    coh.mult(1.0);
    bds.mult(1.5);
    
    // Add the force vectors to acceleration
    acc.add(sep);
    acc.add(ali);
    acc.add(coh);
    acc.add(bds);
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
    
    // do the tail
    tailpos = noise(vel.x, vel.y, vel.z)*-10;
    tailpos = tailpos + 5;
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
    // Draw an ellipse rotated in the direction of velocity and sized an colored according to health
    float theta = vel.heading2D() + PI/2;
    float rsize = r + health/3;
    fill(102, 102, health*10);
    float outline = 100 + 100* noise(loc.x, loc.y);
    stroke(outline, outline/2, health*100);
    pushMatrix();
    translate(loc.x,loc.y);
    rotate(theta);
    ellipse(0,0, rsize, rsize*2);
    triangle(0,rsize, 2, rsize*2, -2, rsize*2);
    line(0, rsize*2, tailpos, rsize*3);
    popMatrix();
  }
  
  // Wraparound
  void borders() {
    if (loc.x < -r) vel.x = -vel.x;
    if (loc.y < -r) vel.y = -vel.y;
    if (loc.x > width+r) vel.x = -vel.x;
    if (loc.y > height+r) vel.y = -vel.y;
  }

  PVector healthAtPoint(PVector hloc)
  {
    PVector hvec = new PVector(0,0,0);
    float neighbordist = 25.0;
    float d = loc.dist(hloc);
    if ((d > 0) && (d < neighbordist)) {
      hvec = vel.get();
      hvec.mult(health/(d));
    }
    
    return hvec;
  }

  // Separation
  // Method checks for nearby fishes and steers away
  PVector separate (ArrayList fishes) {
    float desiredseparation = 25.0;
    PVector sum = new PVector(0,0,0);
    int count = 0;
    // For every fish in the system, check if it's too close
    for (int i = 0 ; i < fishes.size(); i++) {
      Fish other = (Fish) fishes.get(i);
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
  // For every nearby fish in the system, calculate the average velocity
  PVector align (ArrayList fishes) {
    float neighbordist = 50.0;
    PVector sum = new PVector(0,0,0);
    int count = 0;
    for (int i = 0 ; i < fishes.size(); i++) {
      Fish other = (Fish) fishes.get(i);
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

  //bounds - be repelled by the boundries
  PVector bounds() {
    int gutter = 100;
    PVector ret = new PVector(0,0);
    if (loc.x < gutter) {
      ret.x = sq(gutter-loc.x)/sq(gutter);
    }
    if (loc.x > width - gutter) {
      ret.x = -sq((width - loc.x) -gutter)/sq(gutter);
    }
    
    if (loc.y < gutter) {
      ret.y = sq(gutter-loc.y)/sq(gutter);
    }
    if (loc.y > height - gutter) {
      ret.y = -sq((height - loc.y) -gutter)/sq(gutter);
    }
    
    ret.x = ret.x * noise(acc.x);
    ret.y = ret.y * noise(acc.y);  
    return ret;
  }

  // Cohesion
  // For the average location (i.e. center) of all nearby fishes, calculate steering vector towards that location
  PVector cohesion (ArrayList fishes) {
    float neighbordist = 50.0;
    float healthdist = 100.0;
    PVector sum = new PVector(0,0);   // Start with empty vector to accumulate all locations
    int count = 0;
    health = 0;
    float mouseInf = 100;
    
    PVector mouseV = new PVector(mouseX, mouseY);
    if (loc.dist(mouseV) < mouseInf && loc.dist(mouseV) > 15) {
    for (int i = 0 ; i < fishes.size(); i++) {
      Fish other = (Fish) fishes.get(i);
      float d = loc.dist(other.loc);
      if ((d > 0) && (d < neighbordist)) {
        health++;
      }
    }
    return steer (mouseV, false);
    }
    else { 
    for (int i = 0 ; i < fishes.size(); i++) {
      Fish other = (Fish) fishes.get(i);
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
    }
    return sum;
  }
}


