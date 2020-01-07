import toxi.geom.*; //<>//
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import org.gicentre.handy.*;

VerletPhysics2D physics;

Table nodeData = new Table(), connectorData = new Table();
ArrayList<Node> nodes;  //array list of nodes
ArrayList<Connector> connectors;  //array list of connectors (arrows/lines)
Vec2D mouse;//, lastnode, draggedline;//lastline;
float rectW = 70, rectH = 30;
float xAnchor, yAnchor, prevX, prevY;
String MODE = "PLACING_NODES"; // "NODE_SELECTED";
boolean overNode = false, nodeSelected = false, nodeMoved = false, drawing = false, sketchy = false, textLoaded = false, dragging = false;
Node selectedNode, someNode, sn, en; //startNode, endNode;
int sni, eni;//startNodeIndex, endNodeIndex;
int maxWidth = 800, maxHeight = 600;
Menu m;
//String path = dataPath("captures");    // current path to Data folder
String[] filenames;

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
  physics.setDrag (0.04); //1, 0.025  

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
    physics.setWorldBounds(new Rect(0, 0, maxWidth - 5, maxHeight - 5));  // should never shrink physics world bounds!   

    try {
      physics.update ();    // common error is having a null particle
    } 
    catch (NullPointerException e) {
      println(someNode);
      //exit();
    }

    mouse = new Vec2D(mouseX, mouseY);
    prevX = pmouseX;
    prevY = pmouseY;

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
    //if (c.mouseOver()){
    //  println("over a connector!");
    //}
    c.mouseOver();
    c.display();         // display the connector
  }

  for (Node n : nodes) {  // for every node in the arrayList nodes,
    n.display();          // display the node
  }

  // updates and displays menu:
  m.move(width, height);
  m.display();

  //println("YES is " + m.yesButton.isOver);    // (prints for debugging)
  //println("NO is " + m.noButton.isOver);
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
        m.saveButton.isOver = false;
      }
      if (m.loadButton.isOver) {
        m.menuMode = "LOAD";
        m.previousMode = "MAIN";
        m.loadButton.isOver = false;
      }
      if (m.newButton.isOver) {
        m.menuMode = "NEW";
        m.previousMode = "MAIN";
        m.newButton.isOver = false;
      }
    } else if (m.menuMode=="SAVE") {      // SAVE MENU CONTROLS
      if (m.yesButton.isOver) {
        m.filename = m.t1.text;
        // save file
        saveData(m.filename);
        // close menu
        m.showingMenu = false;
        m.menuMode = "MAIN";
        m.yesButton.isOver = false;
      }
      if (m.noButton.isOver) {
        m.filename = m.t1.text;
        // go back to typing
        m.t1.doneTyping = false;
        m.previousMode = "SAVE";
        m.noButton.isOver = false;
      }
      if ((m.backButton.isOver)) {
        println("entering back if statement");
        m.menuMode = "MAIN";
        m.t1.doneTyping = false;
      }
    } else if (m.menuMode=="LOAD") {      // LOAD MENU CONTROLS
      if (m.folderButton.isOver) {
        selectFolder("Select a folder to process:", "folderSelected");
        m.folderButton.isOver = false;
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
        m.yesButton.isOver = false;
      }
      if (m.noButton.isOver) {
        m.filename = m.t2.text;
        m.t2.doneTyping = false;
        m.previousMode = "SAVE";
        m.noButton.isOver = false;
      }
      if (m.backButton.isOver) {
        println("entering back if statement");      
        m.t2.doneTyping = false;
        m.menuMode = "MAIN";
        m.backButton.isOver = false;
      }
    } else if (m.menuMode=="NEW") {      // NEW MENU CONTROLS
      if (m.yesButton.isOver) {
        m.filename = m.t2.text;
        // reset current filename to ""
        // reset current work  
        m.menuMode = "MAIN";
        m.showingMenu = false;
        m.yesButton.isOver = false;
      }
      if (m.noButton.isOver) {
        m.filename = m.t2.text;
        m.menuMode = "MAIN";
        m.noButton.isOver = false;
      }
      if (m.backButton.isOver) {
        println("entering back if statement");
        m.menuMode = "MAIN";
        m.backButton.isOver = false;
      }
    }
  } 
  //else {
  //  leftMouseFunction();
  //}
}
void leftMouseFunction() {
  if (!overNode) {
    if (nodeSelected) {    // don't want to add nodes if a node is selected. Want to deselect current node.
      nodeSelected = false;
      for (Node n : nodes) {
        n.selected = false; //true;
        nodeSelected = nodeSelected||(n.selected);
      }
    } else {// May not need an else
      //MODE = "PLACING_NODES";
      nodeSelected = true;      //changed to true
      Node newNode = new Node(mouse, rectW, rectH, this);
      nodes.add(newNode);    // ADD a new NODE
      nodes.get(nodes.size()-1).selected = true;

      // Add new row to nodeData
      TableRow row = nodeData.addRow();
      row.setFloat("x", newNode.x);
      row.setFloat("y", newNode.y);
      row.setFloat("w", newNode.w);
      row.setFloat("h", newNode.h);
      row.setString("words", newNode.words);    // maybe just using StringList 'letters' as is would work too?
    }
  } else {  //if over a node
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

void mouseReleased() {
  if ((mouseButton == LEFT)&&((abs(mouseX - prevX) < 10)&&(abs(mouseY - prevY) < 10))) {    // 10 - the size of this number is proportional to how much speed the mouse can have while clicking, to create a node
    leftMouseFunction();
  } else if ((mouseButton == RIGHT)&&(nodes.size()>0)&&(!m.showingMenu)&&(overNode)) {
    xAnchor = mouseX;
    yAnchor = mouseY;

    if (!drawing) {
      TableRow row = connectorData.addRow();
      drawing = true;
      connectors.add(new Connector(new VerletParticle2D(xAnchor, yAnchor), new VerletParticle2D(xAnchor, yAnchor)));        // ADD a new CONNECTOR
      //startNode = connectors.get(connectors.size()-1).findClosestNode(nodes, new VerletParticle2D(xAnchor, yAnchor), false);       // find closest node 
      connectors.get(connectors.size()-1).startNode = connectors.get(connectors.size()-1).findClosestNode(nodes, new VerletParticle2D(xAnchor, yAnchor), false);       // find closest node //startNode;    // set connector startNode
      sn = connectors.get(connectors.size()-1).startNode;
      println(sn);

      connectors.get(connectors.size()-1).startNodeIndex = connectors.get(connectors.size()-1).getClosestIndex(nodes, new VerletParticle2D(xAnchor, yAnchor));       // return closest node index
      sni = connectors.get(connectors.size()-1).startNodeIndex;
      //connectors.get(connectors.size()-1).startNode = nodes.get(sn);    // set connector startNode
      row = connectorData.getRow(connectors.size()-1);
      row.setInt("starting node index", connectors.get(connectors.size()-1).startNodeIndex);
      println("Start node index is " + connectors.get(connectors.size()-1).startNodeIndex);
      connectors.set(connectors.size()-1, new Connector(connectors.get(connectors.size()-1).startNode, connectors.get(connectors.size()-1).startNode));  // set closest node as new starting node (for this connection)
    } else {
      TableRow row = connectorData.getRow(connectors.size()-1);
      drawing = false;
      //endNode = connectors.get(connectors.size()-1).findClosestNode(nodes, new VerletParticle2D(xAnchor, yAnchor), true);       // find closest node
      connectors.get(connectors.size()-1).endNode = connectors.get(connectors.size()-1).findClosestNode(nodes, new VerletParticle2D(xAnchor, yAnchor), true);//endNode;  // set connector endNode
      en = connectors.get(connectors.size()-1).endNode;
      println(en);

      connectors.get(connectors.size()-1).endNodeIndex = connectors.get(connectors.size()-1).getClosestIndex(nodes, new VerletParticle2D(xAnchor, yAnchor));       // return closest node index
      eni = connectors.get(connectors.size()-1).endNodeIndex;
      //connectors.get(connectors.size()-1).endNode = nodes.get(en);  // set connector endNode
      row.setInt("ending node index", connectors.get(connectors.size()-1).endNodeIndex);
      //println("End node index is " + connectors.get(connectors.size()-1).endNodeIndex);
      connectors.get(connectors.size()-1).setEndpoint(connectors.get(connectors.size()-1).endNode, connectors.get(connectors.size()-1).endNode);          // set closest node as end node (for this connection)

      connectors.get(connectors.size()-1).connect(sn, en, -15);            // connect the nodes together with a verletSpring
      Connector c = connectors.get(connectors.size()-1);                   // c is the last connection in the connectors ArrayList

      //println("c.curveBegin is ......." + c.curveBegin + ", and c.curveEnd is ......." + c.curveEnd);
      // Delete duplicate connectors:
      if (connectors.size()>1) {
        for (int i = connectors.size() - 2; i >= 0; i--) {                           // this loop removes duplicate connectors
          //if (c.curveBegin != c.curveEnd) {
          //println("INITIAL CONNECTORS SIZE: " + connectors.size());
          //println("connectors.get(i).curveBegin is ......." + connectors.get(i).curveBegin + ", and connectors.get(i).curveEnd is ......." + connectors.get(i).curveEnd);
          if (((connectors.get(i).curveBegin == c.curveBegin)&&(connectors.get(i).curveEnd == c.curveEnd))
            ||((connectors.get(i).curveBegin == c.curveEnd)&&(connectors.get(i).curveEnd == c.curveBegin))) {
            //delete connector from list and physics world:
            //connectors.get(i).delete();  // not even sure if this is necessary, or if it even works


            println("curveBegin = " + connectors.get(i).curveBegin);
            println("curveEnd = " + connectors.get(i).curveEnd);

            connectors.remove(i);        // removes connector from arraylist

            //delete connector i from table:
            connectorData.removeRow(i);            

            println("DELETED A CONNECTOR");
          }
          //}
          //println("FINAL CONNECTORS SIZE: " + connectors.size());
        }
      }

      //Deletes connectors connecting a node to itself
      if (connectors.size()>1) {
        println("INITIAL CONNECTORS SIZE: " + connectors.size());
        if (connectors.get(connectors.size()-1).curveBegin == connectors.get(connectors.size()-1).curveEnd) {
          //delete connector from list and physics world:
          //connectors.get(connectors.size()-1).delete();  // not even sure if this is necessary, or if it even works
          connectors.remove(connectors.size()-1);        // removes connector from arraylist

          //delete connector i from table:
          connectorData.removeRow(connectorData.getRowCount() - 1);  // should maybe use connectorData.getRowCount() here instead

          println("DELETED A CONNECTOR");
        }
        println("FINAL CONNECTORS SIZE: " + connectors.size());
      }

      // Update 'connections' list for each node
      for (int i = 0; i < nodes.size(); i++) {
        nodes.get(i).findAdjacentNodes(i, connectorData);
      }

      // Update startNodeIndex and endNodeIndex for each connector
      if (connectorData.getRowCount() > 0) {
        updateConnectedNodes(connectorData);
      }
    }
  }
}

// Sets all startNodeIndex and endNodeIndex values in ArrayList Connectors using a table (use connectorData)
void updateConnectedNodes(Table t) {  //input connectorData table
  int rowNum = 0;
  //println("***connectors size is____ " + connectors.size());
  //println("*** number of rows in connectorData is____ " + t.getRowCount());
  for (TableRow row : t.rows()) {          // for all rows in t
    //println("***table row " + rowNum + " is " + t.getRow(rowNum));    
    connectors.get(rowNum).startNodeIndex = int(row.getString("starting node index"));      // does .get().startNodeIndex actually set startNodeIndex?
    connectors.get(rowNum).endNodeIndex = int(row.getString("ending node index"));
    rowNum++;
  }
}

void keyTyped() {
  // type in menu text boxes
  if (m.showingMenu) {
    if (m.menuMode == "SAVE") {
      m.t1.addText(m.t1.doneTyping);
    } else if (m.menuMode == "LOAD") {
      m.t2.addText(m.t2.doneTyping);
    }
  } else {
    // type in node text areas
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
  if (keyCode == 123) {
    screenshot();
  }
  //if (key == 'a') {      // this is for testing purposes
  //  for (int i = 0; i <= nodes.size() - 1; i++) {
  //    nodes.get(i).findAdjacentNodes(i, connectorData);
  //    println("\n node " + i + " is connected to nodes:");
  //    for (int j = 0; j <= nodes.get(i).connections.size() - 1; j++) {
  //      println(nodes.get(i).connections.get(j));
  //    }
  //  }
  //}
  if (((key == BACKSPACE)||(key == DELETE))&&(overNode)) {      // FIX: when all nodes are deleted, can't add new nodes. Why?
    println("nodeData has " + nodeData.getRowCount() + " rows");
    println("_____________________________________________________");
    // Find and delete node:
    // Find the node to be deleted:
    if (nodes.size() > 0) {
      int i = 0;  // This is the index of the node to be deleted
      for (int n = nodes.size() - 1; n >= 0; n--) {      // for all nodes
        if (nodes.get(n).mouseOver(nodes.get(n).x, nodes.get(n).y)) {  // find the specific node that is moused over
          // Now we know which node we are deleting:
          i = n;
        }
      }

      // Remove node index i from all nodes' connections IntLists:
      println("REMOVING NODE " + i + " FROM CONNECTIONS INTLISTS");
      for (int j = nodes.size() - 1; j >= 0; j--) {      // for all nodes
        for (int c = nodes.get(j).connections.size() - 1; c >= 0; c--) {      // for all node(j)'s connections
          if (nodes.get(j).connections.get(c) == i) {
            println("removing node " + j + "'s connection int" + nodes.get(j).connections.get(c));
            nodes.get(j).connections.remove(c);
          }
        }
      }

      // Remove node i from nodes ArrayList:
      println("REMOVING NODE " + i + " FROM NODES ARRAYLIST");
      nodes.get(i).delete(i);
      nodes.remove(i);
      println("REMOVING NODE ROW " + i + " FROM TABLE nodeData");
      nodeData.removeRow(i);    // hopefully this is removing the correct row!
      println("nodeData has " + nodeData.getRowCount() + " rows");

      // Shift down connections ints for > i:
      println("SHIFTING DOWN ALL CONNECTIONS' INTS > " + i);
      for (int j = nodes.size() - 1; j >= 0; j--) {      // for all nodes
        for (int c = nodes.get(j).connections.size() - 1; c >= 0; c--) {            // for all node(j)'s connections
          if (nodes.get(j).connections.get(c) > i) {
            println("shifting down node " + nodes.get(j).connections.get(c) + " to ");
            nodes.get(j).connections.set(c, nodes.get(j).connections.get(c) - 1);   // decrement the cth connection
            println("become node " + nodes.get(j).connections.get(c));
          }
        }
      }

      updateConnectedNodes(connectorData);  //updates all startNodes and endNodes

      // Remove all connectors with startNode = i OR endNode = i:
      println("The size of connectors arraylist is: " + connectors.size());
      println("REMOVING ALL CONNECTORS FROM CONNECTORS ARRAYLIST WITH startNodeIndex = " + i + " OR endNodeIndex = " + i);
      for (int c = connectors.size() - 1; c >= 0; c--) {    // for all connectors
        println("Connector " + c + " has startNodeIndex " + connectors.get(c).startNodeIndex + " and endNodeIndex " +  connectors.get(c).endNodeIndex);
        // Check if startNodeIndex or endNodeIndex = i
        if ((connectors.get(c).startNodeIndex == i)||(connectors.get(c).endNodeIndex == i)) {

          //Delete physics for this connector:
          connectors.get(c).delete(c);
          //Remove this connector from connectors list:
          println("Removing connector " + c + " with startNodeIndex " + connectors.get(c).startNodeIndex + " and endNodeIndex " +  connectors.get(c).endNodeIndex);
          connectors.remove(c);
        }
      }
      println("The size of connectors arraylist is: " + connectors.size());

      // Delete connectors from table ConnectorData:
      println("DELETING CONNECTOR ROWS FROM TABLE ConnectorData");
      for (int r = connectorData.getRowCount() - 1; r >= 0; r--) {
        TableRow row = connectorData.getRow(r);    // row is the rth row of connectorData
        if ((int(row.getString("starting node index")) == i)||(int(row.getString("ending node index")) == i)) {
          connectorData.removeRow(r);
        }
      }

      // Shift down connectors' startNodes and endNodes in table ConnectorData:
      println("SHIFTING DOWN CONNECTOR startNodes AND endNodes IN TABLE ConnectorData");
      for (int r = connectorData.getRowCount() - 1; r >= 0; r--) {
        TableRow row = connectorData.getRow(r);    // row is the rth row of connectorData
        int prevInt = int(row.getString("starting node index"));
        if (prevInt > i) {
          row.setInt("starting node index", prevInt - 1);
        }
        prevInt = int(row.getString("ending node index"));
        if (prevInt > i) {
          row.setInt("ending node index", prevInt - 1);
        }
      }
    }
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
  saveTable(connectorData, filename + "/connectorData.csv");
}

void loadData(String filename) {        // FIX: loading a file when nodes/connectors are already present, results in strange things...

  nodes.clear();             // clear the nodes ArrayList
  connectors.clear();             // clear the connectors ArrayList
  physics.clear();

  // LOAD NODES
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
      nodes.get(i).k = t.length();
      nodes.get(i).letters.clear();
      for (int c = 0; c < t.length(); c++) {
        nodes.get(i).letters.append(str(t.charAt(c)));      // fills the letters ArrayList
      }
    }
  }
  println("Loaded " + nodes.size() + " nodes.");

  // LOAD CONNECTORS
  //connectors.clear();             // clear the connectors ArrayList
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
      connectors.add(new Connector(nodes.get(sni), nodes.get(sni)));    // ADD a new CONNECTOR
      connectors.get(connectors.size()-1).setEndpoint(nodes.get(eni), nodes.get(eni));          // set closest node as end node (for this connection)
      connectors.get(connectors.size()-1).connect(nodes.get(sni), nodes.get(eni));              // connect the nodes together with a verletSpring
    }
  }
  updateConnectedNodes(connectorData);  //updates all startNodes and endNodes
  println("Loaded " + connectors.size() + " connectors.");
}

void folderSelected(File selection) {
  if (selection == null) {
    println("You folde(re)d.");
  } else {
    String filePath = selection.getAbsolutePath();
    println("You selected: " + filePath);
    String[] match = match(filePath, "([^\\\\]*)$");
    if (match != null) {
      m.filename = match[0];
      println("match found is: " + m.filename);
      //path = filePath;            // should update path somehow
    }

    m.t2.text = m.filename;        // sets textbox text to file path
    m.t2.k = m.t2.text.length();   // sets number of characters in letters arraylist
    m.t2.letters.clear();
    for (int c = 0; c < m.t2.k; c++) {
      m.t2.letters.append(str(m.t2.text.charAt(c)));      // fills the letters ArrayList of the t2 textbox of menu m
    }
  }
}

void screenshot() {
  String path = sketchPath();//sketchPath("Data");    // current path to Data folder
  println("Saving capture to " + path);
  String[] filenames = listFileNames(path);
  int numCaptures = 0;
  for (int i = 0; i < filenames.length; i++) {
    if (filenames[i].length() > 7) {
      println(filenames[i].substring(0, 7));
      if (filenames[i].substring(0, 7).equals("capture")) {
        numCaptures++;
      }
    }
  }
  printArray(filenames);
  println("number of capture files is " + numCaptures);
  save("capture-" + numCaptures + ".png");    // this actually saves to the sketch folder unless save(path + "capture-" + numCaptures + ".png"); is used instead
}

// Listing file names (Daniel Shiffman):
String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    return null;
  }
}
