// The Fish class

class Fish {

  PVector loc;
  PVector vel;
  PVector acc;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  int health;

  Fish(PVector l, float ms, float mf) {
    acc = new PVector(0,0);
    vel = new PVector(random(-1,1),random(-1,1));
    loc = l.get();
    r = 2.0;
    maxspeed = ms;
    maxforce = mf;
    health = 0;
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
    // Draw an ellipse rotated in the direction of velocity and sized an colored according to health
    float theta = vel.heading2D() + PI/2;
    float rsize = r + health/2;
    fill(102, 102, health*10);
    stroke(200, 100, health*10);
    pushMatrix();
    translate(loc.x,loc.y);
    rotate(theta);
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

  PVector healthAtPoint(PVector hloc)
  {
    PVector hvec = new PVector(0,0,0);
    float neighbordist = 25.0;
    float d = loc.dist(hloc);
    if ((d > 0) && (d < neighbordist)) {
      hvec = vel.get();
      hvec.mult(health/sq(d));
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

  // Cohesion
  // For the average location (i.e. center) of all nearby fishes, calculate steering vector towards that location
  PVector cohesion (ArrayList fishes) {
    float neighbordist = 50.0;
    float healthdist = 100.0;
    PVector sum = new PVector(0,0);   // Start with empty vector to accumulate all locations
    int count = 0;
    health = 0;
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
    return sum;
  }
}


