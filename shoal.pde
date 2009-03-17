// The Shoal (a list of fish objects)

class Shoal {
  ArrayList fishes; // An arraylist for all the fishes

  Shoal() {
    fishes = new ArrayList(); // Initialize the arraylist
  }

  void run() {
    for (int i = 0; i < fishes.size(); i++) {
      Fish f = (Fish) fishes.get(i);  
      f.run(fishes);  // Passing the entire list of fishes to each fish individually
    }
  }
  
  PVector healthAtPoint(PVector loc)
  {
    PVector overall = new PVector(0,0);
    for (int i = 0; i < fishes.size(); i++) {
      Fish f = (Fish) fishes.get(i);  
      overall.add(f.healthAtPoint(loc));  
    }
    
    return overall;
  }

  void addFish(Fish f) {
    fishes.add(f);
  }

}

