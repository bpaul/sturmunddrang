

// The Jumble (a list of bouncer objects)

class Jumble {
  ArrayList bouncers; // An arraylist for all the bouncers

  Jumble() {
    bouncers = new ArrayList(); // Initialize the arraylist
  }

  void run(Shoal shoal) {
    for (int i = 0; i < bouncers.size(); i++) {
      Bouncer b = (Bouncer) bouncers.get(i);  
      b.bounce(shoal);  
    }
  }

  void addBouncer(Bouncer b) {
    bouncers.add(b);
  }

}
