import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

class Sound {
  Minim minim;
  AudioPlayer hbbeat;
 
   Sound () {
     
   }
 
  void init (processing.core.PApplet parent) 
  {
      minim = new Minim(parent);
    // load a file, default sample buffer size is 1024
    hbbeat = minim.loadFile("heartbeat_slow.wav");
    // play the file
    hbbeat.play();
    hbbeat.loop();

  }
  
  float level ()
  {
      return hbbeat.left.level();
  }

  protected void finalize() 
  {
   // always close audio I/O classes
  hbbeat.close();
  // always stop your Minim object
  minim.stop();

  }
}
