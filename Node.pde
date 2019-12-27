import org.gicentre.handy.*;
HandyRenderer HR;

class Node extends VerletParticle2D {
  boolean sketchy = false;
  float fontSize = 20, vertSpace = 20, w, h, maxWidth = 120, radius, strength = 2; //0.2;
  boolean selected = false, highlighted = false, wrapped = false;
  Vec2D displacement, velocity, acceleration; // initialised from draw screen origin (0,0)
  StringList letters = new StringList();
  String words = "";
  int k = 0;
  //Pfont font;

  Node(Vec2D loc, float tempw, float temph, PApplet pa) {
    super(loc);  // loc is an x, y vector (I think)
    //displacement = loc;
    velocity = this.getVelocity();
    physics.addParticle(this);

    w = tempw;  // width and height of node
    h = temph;

    physics.addBehavior(new AttractionBehavior2D(this, w + 3, -strength));

    // HANDY STUFF:
    HR = HandyPresets.createMarker(pa); //new HandyRenderer(this);
    HR.setHachurePerturbationAngle(12);
    HR.setRoughness(1.1);
    HR.setFillGap(5);
    HR.setFillWeight(2);
    HR.setStrokeWeight(1.5);
    //HR.setIsAlternating(true);
  }

  void display() {    // draws the node (rectangle)
    fill(255);
    rectMode(CENTER);
    HR.setIsHandy(sketchy);   // if node selected, make rectangle sketchy
    if (highlighted) {
      strokeWeight(2);
      stroke(0);
    } else {
      noStroke();
    }
    HR.rect(x, y, w, h);      // draw node as a rectangle
    fill(0);
    textAlign(CENTER);
    textSize(fontSize);
    textLeading(vertSpace);
    text(words, x, y, w, h);  // display typed text on rectangle location
    //if (keyPressed){
    //  println(letters);
    //}
  }

  void sketch(boolean selected) {
    if (selected) {
      sketchy = true;
    } else {
      sketchy = false;
    }
  }

  void addText(boolean selected) {
    if (selected) {
      if (key == BACKSPACE) {
        if (k>0) {
          letters.remove(k-1);
          k -= 1;
        }
      } else {
        letters.append(str(key)); 
        k += 1;
      }

      words = "";
      for (int i=0; i<letters.size(); i+=1) {  // build up words String out of letters StringList
        words += letters.get(i);
      }

      w = textWidth(words) + 5;    // resizes width of node and text area

      int lastIndex = 0;
      int numNewlines = 0;
      h = 25;
      if (words.contains("\n")) {
        for (int i = 0; i < words.length(); i++) {
          int n = words.indexOf("\n", i);
          if ((n > -1)&&(n != lastIndex)) {
            numNewlines += 1;
          }
          lastIndex = n;
        }
        println(numNewlines);
      }
      //} else if  ((w > maxWidth)&&(words.contains(" "))&&(!wrapped)) {    // wrap text in first line with any spaces
      //  wrapped = true;
      //  numNewlines += 1;
      //  w = maxWidth + 5;
      //}
      h += numNewlines*(fontSize);    // resizes height of node and text area
    }
  }

  boolean mouseOver(float tempx, float tempy) {
    if ((mouseX >= tempx - w/2)&&(mouseX <= tempx + w/2) && 
      (mouseY >= tempy - h/2)&&(mouseY <= tempy + h/2)) {
      highlighted = true;
      return true;
    } else {
      highlighted = false;
      return false;
    }
  }
}
