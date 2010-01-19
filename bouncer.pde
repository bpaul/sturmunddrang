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

  void bounce (Shoal shoal) {
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
    
    PVector fishHealth = shoal.healthAtPoint(new PVector(int(xPos),int(yPos)));
    if (fishHealth.x != 0 || fishHealth.y != 0) {
       xVel += fishHealth.x/5;
      yVel += fishHealth.y/5; 
    }

    float gray = (abs(yVel) + abs(xVel));
    if (gray > 0)      gray = 255;
    gray = gray * noise(xPos, yPos);
    strokeWeight(strokeVar);
    stroke(gray, gray/2, 31);
    //line(xPos, yPos, xOld, yOld);
    triangle(xPos-2, yPos-2, xPos + 2, yPos +2, xOld, yOld);//xOld +2, yOld +2, xOld, yOld);
    strokeWeight(strokeVar/2);
    stroke((abs(yVel) + abs(xVel))*2,8,0);
    line(xPos, yPos, xOld, yOld);
    strokeWeight(strokeVar/4);
    stroke((abs(yVel) + abs(xVel))*8,68,30);
    line(xOld, yOld, x2Old, y2Old);
  }
}



