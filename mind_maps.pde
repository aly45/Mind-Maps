import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import org.gicentre.handy.*;

VerletPhysics2D physics;

Table nodeData = new Table(), connectorData = new Table();
ArrayList<Node> nodes;  //array list of nodes
ArrayList<Connector> connectors;  //array list of connectors (arrows/lines)
Vec2D mouse;//, lastnode, draggedline;//lastline;
float rectW = 70, rectH = 30;
float xAnchor, yAnchor;
String MODE = "PLACING_NODES"; // "NODE_SELECTED";
boolean overNode = false, nodeSelected = false, nodeMoved = false, drawing = false, sketchy = false, textLoaded = false, dragging = false;
Node selectedNode, someNode, startNode, endNode;
int sn, en;//startNodeIndex, endNodeIndex;
int maxWidth = 800, maxHeight = 600;
Menu m;

void settings() {
  size(maxWidth, maxHeight);
  smooth();
}

void setup() {
  surface.setTitle("Mind Maps");  // add file name to this, or "New mind map" if no file selected
  surface.setResizable(true);
  //surface.setLocation(100, 100); // location on device screen

  m = new Menu();    // Creates new menu

  physics = new VerletPhysics2D();
  physics.setDrag (1); //0.025  

  nodes = new ArrayList<Node>();
  connectors = new ArrayList<Connector>();

  nodeData.addColumn("x");    // adds columns to table nodeData
  nodeData.addColumn("y");
  nodeData.addColumn("w");
  nodeData.addColumn("h");
  nodeData.addColumn("text");

  connectorData.addColumn("# row number");
  connectorData.addColumn("starting node index");    // adds columns to table connectorData
  connectorData.addColumn("ending node index");
  connectorData.clearRows();                           // resets table
}

void draw() {
  background(150); //10, 17, 60);
  if (width > maxWidth) {
    maxWidth = width;
  }
  if (height > maxHeight) {
    maxHeight = height;
  }

  if (!m.showingMenu) {
    physics.setWorldBounds(new Rect(0, 0, maxWidth - 5, maxHeight - 5));  // should never shrink physics world bounds    

    try {
      physics.update ();    // common error is having a null particle
    } 
    catch (NullPointerException e) {
      println(someNode);
      exit();
    }

    mouse = new Vec2D(mouseX, mouseY);

    if (drawing) {
      stroke(0);
      line(xAnchor, yAnchor, mouseX, mouseY);
    }

    if (nodes.size() > 0) {
      overNode = nodes.get(0).mouseOver(nodes.get(0).x, nodes.get(0).y);
    }
    for (int i = 0; i < nodes.size(); i++) {    // goes through all the nodes
      overNode = overNode||(nodes.get(i).mouseOver(nodes.get(i).x, nodes.get(i).y));    // update global variable overNode
      nodes.get(i).sketch(nodes.get(i).selected);
      nodes.get(i).addText(nodes.get(i).selected && !textLoaded);
      textLoaded = true;

      if ((mousePressed)&&(mouseButton == LEFT)&&(nodes.get(i).mouseOver(nodes.get(i).x, nodes.get(i).y))) {
        nodes.get(i).lock();
        nodes.get(i).set(mouseX, mouseY);
      } else {
        nodes.get(i).unlock();
      }
    }
  }

  for (Connector c : connectors) {  // for every connector in the arrayList connectors,
    c.display();         // display the connector
  }

  for (Node n : nodes) {  // for every node in the arrayList nodes,
    n.display();          // display the node
  }

  // updates and displays menu:
  m.move(width, height);
  m.display();
}


void mouseClicked() {
  //if ((mouseX==pmouseX)&&(mouseY==pmouseY)) { // stay still!  -- only need this if using mouseRelased() ?

  if (m.showingMenu) {
    if (m.X.isOver) {
      m.showingMenu = false;
      m.menuMode = "MAIN";
    } else if (m.menuMode=="MAIN") {      // MAIN MENU BUTTON CONTROLS
      if (m.saveButton.isOver) {
        m.menuMode = "SAVE";
        m.previousMode = "MAIN";
      }
      if (m.loadButton.isOver) {
        m.menuMode = "LOAD";
        m.previousMode = "MAIN";
      }
      if (m.newButton.isOver) {
        m.menuMode = "NEW";
        m.previousMode = "MAIN";
      }
    } else if (m.menuMode=="SAVE") {      // SAVE MENU CONTROLS
      if (m.yesButton.isOver) {
        m.filename = m.t1.text;
        // save file
        //menuMode = "END";
        m.showingMenu = false;
        m.menuMode = "MAIN";
      }
      if (m.noButton.isOver) {
        m.filename = m.t1.text;
        m.t1.doneTyping = false;
        m.previousMode = "SAVE";
      }
      if ((m.backButton.isOver)) {
        println("entering back if statement");
        m.menuMode = "MAIN";
        m.t1.doneTyping = false;
      }
    } else if (m.menuMode=="LOAD") {      // LOAD MENU CONTROLS
      if (m.folderButton.isOver) {
        selectFolder("Select a folder to process:", "folderSelected");
      }
      if (m.yesButton.isOver) {
        m.filename = m.t2.text;
        // LOAD FILE "filename"
        try {
          loadData(m.filename);
        } 
        catch (NullPointerException e) {
          e.printStackTrace();
        }

        for (int i = 0; i < nodes.size(); i++) {
          nodes.get(i).findAdjacentNodes(i, connectorData);
        }
        // menuMode = "END";
        m.menuMode = "MAIN";
        m.showingMenu = false;
      }
      if (m.noButton.isOver) {
        m.filename = m.t2.text;
        m.t2.doneTyping = false;
        m.previousMode = "SAVE";
      }
      if ((m.backButton.isOver)) {
        println("entering back if statement");      
        m.t2.doneTyping = false;
        m.menuMode = "MAIN";
      }
    } else if (m.menuMode=="NEW") {      // NEW MENU CONTROLS
      if (m.yesButton.isOver) {
        m.filename = m.t2.text;
        // reset current filename to ""
        // reset current work  
        m.menuMode = "MAIN";
        m.showingMenu = false;
      }
      if (m.noButton.isOver) {
        m.filename = m.t2.text;
        m.menuMode = "MAIN";
      }
      if ((m.backButton.isOver)) {
        println("entering back if statement");
        m.menuMode = "MAIN";
      }
    }
  } else {
    if (mouseButton == LEFT) {
      //println(nodes.size());
      if (!overNode) {
        //MODE = "PLACING_NODES";
        nodeSelected = false;
        nodes.add(new Node(mouse, rectW, rectH, this));    // ADD a new NODE    //edited this to use mouse Vec2D
      } else {
        nodeSelected = false;
        for (Node n : nodes) {
          if (n.mouseOver(n.x, n.y)) {    // mouse is L-clicked on a node
            //MODE = "NODE_SELECTED";
            n.selected = !n.selected; //true;
            nodeSelected = nodeSelected||(n.selected);
            selectedNode = n;
          } else {
            n.selected = false;
          }
        }
      }
    }
    //println(nodeSelected);

    if ((mouseButton == RIGHT)&&(nodes.size()>0)) {
      xAnchor = mouseX;
      yAnchor = mouseY;
      TableRow row = connectorData.addRow();


      if (!drawing) {
        drawing = true;
        connectors.add(new Connector(new VerletParticle2D(xAnchor, yAnchor), new VerletParticle2D(xAnchor, yAnchor)));    // ADD a new CONNECTOR
        startNode = connectors.get(connectors.size()-1).findClosestNode(nodes, new VerletParticle2D(xAnchor, yAnchor));       // find closest node 
        connectors.get(connectors.size()-1).startNodeIndex = connectors.get(connectors.size()-1).getClosestIndex(nodes, new VerletParticle2D(xAnchor, yAnchor));       // return closest node index
        sn = connectors.get(connectors.size()-1).startNodeIndex;
        row = connectorData.getRow(connectors.size()-1);
        row.setInt("starting node index", connectors.get(connectors.size()-1).startNodeIndex);
        println("Start node index is " + connectors.get(connectors.size()-1).startNodeIndex);
        connectors.set(connectors.size()-1, new Connector(startNode, startNode));  // set closest node as new starting node (for this connection)
      } else {
        row = connectorData.getRow(connectors.size()-1);
        drawing = false;
        endNode = connectors.get(connectors.size()-1).findClosestNode(nodes, new VerletParticle2D(xAnchor, yAnchor));       // find closest node
        connectors.get(connectors.size()-1).endNodeIndex = connectors.get(connectors.size()-1).getClosestIndex(nodes, new VerletParticle2D(xAnchor, yAnchor));       // return closest node index
        en = connectors.get(connectors.size()-1).endNodeIndex;
        row.setInt("ending node index", connectors.get(connectors.size()-1).endNodeIndex);
        println("End node index is " + connectors.get(connectors.size()-1).endNodeIndex);
        connectors.get(connectors.size()-1).setEndpoint(endNode, endNode);          // set closest node as end node (for this connection)
        connectors.get(connectors.size()-1).connect(startNode, endNode, -15);            // connect the nodes together with a verletSpring
        Connector c = connectors.get(connectors.size()-1);

        if (connectors.size()>1) {
          for (int i = connectors.size() - 2; i >= 0; i--) {                           // this loop removes duplicate connectors, but it doesn't quite work...
            if ((connectors.get(i).curveBegin == c.curveBegin)&&(connectors.get(i).curveEnd == c.curveEnd)) {
              connectors.remove(i);
              //println("DELETING A CONNECTOR");
            }
          }
        }
      }
    }
  }
}

void keyTyped() { 
  if (m.showingMenu) {
    if (m.menuMode == "SAVE") {
      m.t1.addText(m.t1.doneTyping);
    } else if (m.menuMode == "LOAD") {
      m.t2.addText(m.t2.doneTyping);
    }
  } else {
    //if (key == CONTROL) {
    //  println("starting node: " + sn);    
    //  println("ending node: " + en);
    //}
    textSize(20);
    for (int i = 0; i < nodes.size(); i++) {    // goes through all the nodes
      nodes.get(i).addText(nodes.get(i).selected);     // add text to selected node
    }
  }
}

void keyPressed() {
  if (key == ESC) {
    key = 0;  // clears current key to override usual exit function
    if (m.showingMenu) {
      m.menuMode = "MAIN";
    }
    m.showingMenu = !m.showingMenu;
  }
  if ((keyCode == CONTROL)&&(key == 's')) {
    saveData("test");
  }
}

void saveData(String filename) {
  nodeData.clearRows();                      // resets table
  for (int i = 0; i < nodes.size(); i++) {   // fills rows of table
    TableRow row = nodeData.addRow();
    row.setFloat("x", nodes.get(i).x);
    row.setFloat("y", nodes.get(i).y);
    row.setFloat("w", nodes.get(i).w);
    row.setFloat("h", nodes.get(i).h);
    row.setString("words", nodes.get(i).words);    // maybe just using StringList 'letters' as is would work too?
  }
  saveTable(nodeData, filename + "/nodeData.csv");

  //connectorData.clearRows();                         // resets table
  //for (int i = 0; i < connectors.size(); i++) {        // fills rows of table
  //  TableRow row = connectorData.getRow(i);
  //  //row.setString("# row number", "#" + i+1);        // this is useless atm...
  //  //println("starting nodes....." + connectors.get(i).startNodeIndex);
  //  //  row.setInt("ending node index", connectors.get(i).endNodeIndex);
  //  //println("ending nodes....." + connectors.get(i).endNodeIndex);
  //}
  saveTable(connectorData, filename + "/connectorData.csv");
}

void loadData(String filename) {

  // LOAD NODES
  nodes.clear();             // clear the nodes ArrayList
  nodeData = loadTable(filename + "/nodeData.csv", "header");
  //connectorData = loadTable(filename + "/connectorData.csv", "header");

  for (int i = 0; i<nodeData.getRowCount(); i++) {
    // Iterate over all the rows in table rowData
    TableRow row = nodeData.getRow(i);

    // Access the fields via their column name (or index)
    float x = row.getFloat("x");
    float y = row.getFloat("y");
    float w = row.getFloat("w");
    float h = row.getFloat("w");
    String t = row.getString("words");

    // Turn each row into a node
    if (x > 0) { // this makes sure blank rows aren't being turned into nodes (checks validity of x position)
      nodes.add(new Node(new Vec2D(x, y), w, h, this));    // ADD a new NODE
      for (int c = 0; c < t.length(); c++) {
        nodes.get(i).letters.append(str(t.charAt(c)));      // fills the letters ArrayList
      }
    }
  }
  println("Loaded " + nodes.size() + " nodes.");

  // LOAD CONNECTORS
  connectors.clear();             // clear the connectors ArrayList
  connectorData = loadTable(filename + "/connectorData.csv", "header");

  for (int i = 0; i<connectorData.getRowCount(); i++) {
    // Iterate over all the rows in table connectorData
    TableRow row = connectorData.getRow(i);

    // Access the fields via their column name (or index)
    //String rowNum = row.getString("# row number");
    int sni = row.getInt("starting node index");
    int eni = row.getInt("ending node index");

    // Turn each row into a connector
    if (sni != eni) {    // a node can't be connected to itself
      //if (rowNum.charAt(0) == '#') { // this makes sure blank rows aren't being turned into connectors (checks validity of start node index. EDIT: checks if row number starts with #). EDIT: I can't get this to work...
      connectors.add(new Connector(nodes.get(sni), nodes.get(sni)));    // ADD a new CONNECTOR
      connectors.get(connectors.size()-1).setEndpoint(nodes.get(eni), nodes.get(eni));          // set closest node as end node (for this connection)
      connectors.get(connectors.size()-1).connect(nodes.get(sni), nodes.get(eni));              // connect the nodes together with a verletSpring
    }
  }
  println("Loaded " + connectors.size() + " connectors.");
  // Could also set the node locations back to what they are in nodeData.csv if I wanted them to be exactly the same as what was saved
}

void folderSelected(File selection) {
  if (selection == null) {
    println("You folde(re)d.");
  } else {
    String filePath = selection.getAbsolutePath();
    println("You selected: " + filePath);
    m.filename = filePath;
    m.t2.text = m.filename;
  }
}

//void keyPressed() {
//  if (key == BACKSPACE) {
//    if (nodes.size() > 0) {
//      println(nodes.get(nodes.size() - 1));
//      nodes.remove(nodes.size() - 1);
//    }
//  }
//}
