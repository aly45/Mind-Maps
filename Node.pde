import org.gicentre.handy.*;
HandyRenderer HR;

class Node extends VerletParticle2D {
  color highlightColour = color(255, 255, 0);
  boolean sketchy = false;
  float fontSize = 20, vertSpace = 20, w = 70, h = 30, maxWidth = 120, radius, strength = 1; //0.2;
  PFont gulim = createFont("Gulim", fontSize);
  boolean selected = false, highlighted = false, wrapped = false;
  Vec2D displacement, velocity, acceleration; // initialised from draw screen origin (0,0)
  StringList letters = new StringList();
  String words = "";
  int k = 0;
  IntList connections = new IntList();    // array of node indices that this node is connected to
  String connectionMode;
  AttractionBehavior2D a;

  Node(Vec2D loc, float tempw, float temph, PApplet pa) {
    super(loc);  // loc is an x, y vector (I think)
    //displacement = loc;
    //velocity = this.getVelocity();
    physics.addParticle(this);

    w = tempw;  // width and height of node
    h = temph;

    a = new AttractionBehavior2D(this, 73, -strength);  // sets a to new 2D attraction behavior
    physics.addBehavior(a); // the second entry used to be: w + 3, but having differing attractionbehaviors makes things go crazy

    // HANDY STUFF:
    HR = HandyPresets.createMarker(pa); //new HandyRenderer(this);
    HR.setHachurePerturbationAngle(12);
    HR.setRoughness(1.1);
    HR.setFillGap(5);
    HR.setFillWeight(2);
    HR.setStrokeWeight(1.5);
    HR.setStrokeColour(color(0,255,255));
    //HR.setIsAlternating(true);
  }

  void display() {    // draws the node (rectangle)
    fill(255);
    rectMode(CENTER);
    HR.setIsHandy(sketchy);   // if node selected, make rectangle sketchy
    if (highlighted) {
      strokeWeight(2);
      stroke(highlightColour);
    } else {
      noStroke();
    }
    HR.rect(x, y, w, h);      // draw node as a rectangle
    fill(0);
    textAlign(CENTER);
    //textFont(gulim);
    textSize(fontSize);
    textLeading(vertSpace);
    if ((hasTyped) && (words.length() > 0)) {
      text(words, x, y, w, h);  // display typed text on rectangle location
      //println(words);
    }
  }

  void sketch(boolean selected) {
    if (selected) {
      sketchy = true;
    } else {
      sketchy = false;
    }
  }

  void addText(boolean selected) {
    if ((selected)&&(hasTyped)) {
      if (key == BACKSPACE) {
        if (k>0) {
          letters.remove(k-1);
          k -= 1;
        }
      } else {
        letters.append(str(key)); 
        k += 1;
      }
    }

    words = "";

    for (int i=0; i<letters.size(); i+=1) {  // build up words String out of letters StringList
      words += letters.get(i);
      String g = convertGreek(words);
      words = g;
    }

    if (letters.size()>0) {

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
      }
      h += numNewlines*(fontSize);    // resizes height of node and text area
    } else {
      w = 70;
      h = 30;
    }
  }

  String convertGreek(String t) {
    String g = "";   // new string with converted Greek letters
    String shortcut = ""; // Greek letter shortcut
    String gl = "";  // Greek letter key
    int dot = 0;   // start point
    boolean searchingGreek = false;

    //if (t.length() > 5) {
    for (int mark=0; mark < t.length(); mark++) {    // go through string t
      if (t.substring(mark, mark+1).equals("\\")) {  // if the string t contains a \ character, check for Greek letter key . Need to add 4 to both because \ is actually added as "null\" to the string. ?
        dot = mark;                                  // set starting check point dot
        gl = "";                                     // refreshes greek letter
        searchingGreek = true;
      }
      if ((searchingGreek) && (alphabet.hasKey(t.substring(dot, mark)))) {    // if the alphabet contains the substring key
        shortcut = t.substring(dot, mark);
        gl = alphabet.get(shortcut);      // stores the Greek letter shortcut in gl

        g = g.substring(0, g.length() - shortcut.length());  // removes the typed escaped Greek shortcut
        g += gl;                  // adds Greek letter code to string with Greek letters
        dot = mark;
        searchingGreek = false;                         // no longer searching
      } else {
      g += t.charAt(mark);  // adds letter as normal
    }
  }
  return g;
}

void findAdjacentNodes(int i, Table t) {  //input current node index, connectorData table
  //int numConnections = 0;
  connections.clear();
  //String lastIndex = "";
  int rowNum = 0;
  for (TableRow row : t.findRows(str(i), "starting node index")) {    // finds rows with starting node index i
    connectors.get(rowNum).startNodeIndex = int(row.getString("starting node index"));
    connectors.get(rowNum).endNodeIndex = int(row.getString("ending node index"));
    if ((int(row.getString("starting node index")) != int(row.getString("ending node index")))&&(!connections.hasValue(int(row.getString("ending node index"))))) {
      connections.append(int(row.getString("ending node index")));    // compiles list of nodes to which this node is connected
    }
    rowNum++;
  }
  rowNum = 0;
  //println(t.getRowCount() + " rows");
  for (TableRow row : t.findRows(str(i), "ending node index")) {    // finds rows with starting node index i
    //println(connectors.size());

    connectors.get(rowNum).startNodeIndex = int(row.getString("starting node index"));
    connectors.get(rowNum).endNodeIndex = int(row.getString("ending node index"));
    if ((int(row.getString("starting node index")) != int(row.getString("ending node index")))&&(!connections.hasValue(int(row.getString("starting node index"))))) {
      connections.append(int(row.getString("starting node index")));    // compiles list of nodes to which this node is connected
      //println(row.getString("ending node index") + " connects to " + row.getString("starting node index"));
    }
    rowNum++;
  }
}

boolean mouseOver(float tempx, float tempy) {    //tempx and tempy are the centre of the node (could just remove these args)
  if ((pmouseX >= tempx - w/2)&&(pmouseX <= tempx + w/2) && 
    (pmouseY >= tempy - h/2)&&(pmouseY <= tempy + h/2)) {
    highlighted = true;
    return true;
  } else {
    highlighted = false;
    return false;
  }
}

void delete(int i) {
  println("Deleting node " + i + " physics...");
  //if (this != null) {
  physics.removeBehavior(this.a); // delete node particle attraction behaviour
  physics.removeParticle(this);   // delete node particle
  //}
}
}
