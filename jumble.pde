

// The Jumble (a list of bouncer objects)

class Jumble {
  ArrayList bouncers; // An arraylist for all the bouncers

  Jumble() {
    bouncers = new ArrayList(); // Initialize the arraylist
  }

  void run() {
    for (int i = 0; i < bouncers.size(); i++) {
      Bouncer b = (Bouncer) bouncers.get(i);  
      b.bounce();  
    }
  }

  void addBouncer(Bouncer b) {
    bouncers.add(b);
  }

}
