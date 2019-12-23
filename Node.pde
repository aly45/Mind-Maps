import org.gicentre.handy.*;
HandyRenderer HR;

class Node extends VerletParticle2D {

  boolean sketchy = false;
  float w, h, radius, strength = 1.3; //0.2;
  boolean selected = false, highlighted = false;
  Vec2D displacement, velocity, acceleration; // initialised from draw screen origin (0,0)

  Node(Vec2D loc, float tempw, float temph, PApplet pa) {
    super(loc);  // loc is an x, y vector (I think)
    //displacement = loc;
    velocity = this.getVelocity();
    physics.addParticle(this);
    physics.addBehavior(new AttractionBehavior2D(this, tempw, -strength));

    w = tempw;  // width and height of node
    h = temph;

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
    fill(230, 230, 200);
    rectMode(CENTER);
    HR.setIsHandy(sketchy);
    if (highlighted) {
      strokeWeight(2);
      stroke(0);
    } else {
      noStroke();
    }
    HR.rect(x, y, w, h);
  }

  void addText(boolean selected) {
    if (selected) {
      sketchy = true;
    } else {
      sketchy = false;
    }
  }

  boolean mouseOver(float tempx, float tempy, float tempw, float temph) {
    if ((mouseX >= tempx - tempw/2)&&(mouseX <= tempx + tempw/2) && 
      (mouseY >= tempy - temph/2)&&(mouseY <= tempy + temph/2)) {
      highlighted = true;
      return true;
    } else {
      highlighted = false;
      return false;
    }
  }
}
