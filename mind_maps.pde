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
float xAnchor, yAnchor;
String MODE = "PLACING_NODES"; // "NODE_SELECTED";
boolean overNode = false, nodeSelected = false, nodeMoved = false, drawing = false, sketchy = false, textLoaded = false, dragging = false;
Node selectedNode, someNode, sn, en; //startNode, endNode;
int sni, eni;//startNodeIndex, endNodeIndex;
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
  } else {
    if (mouseButton == LEFT) {
      //println(nodes.size());
      if (!overNode) {
        if (nodeSelected) {    // don't want to add nodes if a node is selected. Want to deselect current node.
          nodeSelected = false;
          for (Node n : nodes) {
            //MODE = "NODE_DESELECTED";
            n.selected = false; //true;
            nodeSelected = nodeSelected||(n.selected);
          }
        } else { // may not need an else
          //MODE = "PLACING_NODES";
          nodeSelected = false;
          nodes.add(new Node(mouse, rectW, rectH, this));    // ADD a new NODE    //edited this to use mouse Vec2D
        }
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
  }
}

void mouseReleased() {
  if ((mouseButton == RIGHT)&&(nodes.size()>0)&&(!m.showingMenu)&&(overNode)) {
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
          //println("INITIAL CONNECTORS SIZE: " + connectors.size());
          //println("connectors.get(i).curveBegin is ......." + connectors.get(i).curveBegin + ", and connectors.get(i).curveEnd is ......." + connectors.get(i).curveEnd);
          if (((connectors.get(i).curveBegin == c.curveBegin)&&(connectors.get(i).curveEnd == c.curveEnd))
            ||((connectors.get(i).curveBegin == c.curveEnd)&&(connectors.get(i).curveEnd == c.curveBegin))) {
            //delete connector from list and physics world:
            connectors.get(i).delete();  // not even sure if this is necessary, or if it even works
            connectors.remove(i);        // removes connector from arraylist

            //delete connector i from table:
            connectorData.removeRow(i);

            println("DELETED A CONNECTOR");
          }
          //println("FINAL CONNECTORS SIZE: " + connectors.size());
        }
      }

      // Deletes connectors connecting a node to itself
      if (connectors.size()>1) {
        //println("INITIAL CONNECTORS SIZE: " + connectors.size());
        if (connectors.get(connectors.size()-1).curveBegin == connectors.get(connectors.size()-1).curveEnd) {
          //delete connector from list and physics world:
          connectors.get(connectors.size()-1).delete();  // not even sure if this is necessary, or if it even works
          connectors.remove(connectors.size()-1);        // removes connector from arraylist

          //delete connector i from table:
          connectorData.removeRow(connectors.size()-1);  // should maybe use connectorData.getRowCount() here instead

          println("DELETED A CONNECTOR");
        }
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
  if (key == 'a') {
    for (int i = 0; i <= nodes.size() - 1; i++) {
      println("\n node " + i + " is connected to nodes:");
      for (int j = 0; j <= nodes.get(i).connections.size() - 1; j++) {
        println(nodes.get(i).connections.get(j));
      }
    }
  }
  if (((key == BACKSPACE)||(key == DELETE))&&(overNode)) {      // FIX: when all nodes are deleted, can't add new nodes. Why?
    println("_____________________________________________________");
    // Find and delete node:
    if (nodes.size() > 0) {
      for (int i = nodes.size() - 1; i >= 0; i--) {      // for all nodes
        if (nodes.get(i).mouseOver(nodes.get(i).x, nodes.get(i).y)) {  // find the specific node that is moused over     
          println("Initial connections list is: " + nodes.get(i).connections);  // show connections to this node

          //Delete ALL attached connections:
          for (int c = nodes.get(i).connections.size() - 1; c >= 0; c--) {    // for all connections to this node

            //println("i is " + i);
            println("connections size is: " + nodes.get(i).connections.size());
            //println("c is " + c);
            println("The " + c + "th element of intlist connections of node " + i + " is " + nodes.get(i).connections.get(c));
            //println("Initial connectors size is: " + connectors.size());

            // for each node connections.get(c) in connections, delete all connectors going from node i to ni:
            for (int j = connectors.size() - 1; j >= 0; j--) {                // for all connectors,
              //println("The startNodeIndex of the " + j + "th connector is " + connectors.get(j).startNodeIndex);
              //println("The endNodeIndex of the " + j + "th connector is " + connectors.get(j).endNodeIndex);
              //println("The startNodeIndex of connector " + j + " is " + connectors.get(j).startNodeIndex);
              if ((connectors.get(j).startNodeIndex == i)||(connectors.get(j).endNodeIndex == i)) {  //if the startNodeIndex or endNodeIndex of the jth connector matches the cth element of connections,
                println("The startNodeIndex of connector " + j + " is " + connectors.get(j).startNodeIndex);
                println("**connections(c)** " + nodes.get(i).connections.get(c));
                println("*startNodeIndex* " + connectors.get(j).startNodeIndex);
                println("*endNodeIndex* " + connectors.get(j).endNodeIndex);

                connectors.get(j).delete(nodes.get(i), i);                                   // (delete physics particles and springs for this node) i is the node index moused over, nodes.get(i) is the node, connectors.get(j) is the jth connector
                //connectors.get(nodes.get(i).connections.get(c)).delete(nodes.get(i));   // (delete physics particles and springs for this node)
                connectors.remove(j); // removes the jth connector if its startNode or endNode matches the cth element of connections of the ith node
                //delete connector j from table:
                connectorData.removeRow(j);
              }
            }
            //nodes.get(i).connections.remove(c); // removes the cth connection of the ith node
            //println("Final connectors size is: " + connectors.size());    // should be 0 at the end!
          }
          nodes.get(i).findAdjacentNodes(i, connectorData);            // update connections list for this node. This is probably pointless since I'm just removing the node in the next line
          println("Final connections list is: " + nodes.get(i).connections);  // show connections to this node

          nodes.remove(i);                                             // removes the moused over node

          // Need to shift down all indexes > the index of the node just deleted:
          for (int n = nodes.size() - 1; n >= 0; n--) {        //n
            println("node " + n + " is connected to: ");
            for (int index = nodes.get(n).connections.size() - 1; index >= 0; index--) {    //index
              println("node " + nodes.get(n).connections.get(index));                  // + which becomes")

              //remove deleted index from connections
              if (nodes.get(n).connections.get(index) == i) {
                nodes.get(n).connections.remove(index); // removes the 'index'th connection of the nth node
                println("which gets deleted");
              }
              //shift all down by 1
              //println("nodes size is now..." + nodes.size());
              //println("trying to access index: " + n);
              //println(nodes.get(n).connections.get(index));

              //try {
                if ((nodes.get(n).connections.size() != index)&&(nodes.get(n).connections.get(index) > i)) {
                  nodes.get(n).connections.set(index, nodes.get(n).connections.get(index) - 1);
                  println("which becomes node " + nodes.get(n).connections.get(index));
                }
              //} 
              //catch (ArrayIndexOutOfBoundsException e) {
              //  println(e);
              //  println("connections size is now..." + nodes.get(n).connections.size());
              //  println("trying to access index: " + index);
              //}
              
              //nodes.remove(i);                                             // removes the moused over node
            }
          }

          //println("nodes list is: " + nodes);
        }
      }
    }
    // Find and delete connector:
    //if (connectors.size() > 0) {
    //  for (int i = connectors.size() - 1; i >= 0; i--) {  
    //    if (nodes.get(i).mouseOver(nodes.get(i).x, nodes.get(i).y)) {  // find the specific node that is moused over          
    //      nodes.remove(i);            // delete this node
    //      //println("nodes size is " + nodes.size());
    //      //nodes.get(i).connections
    //    }
    //  }
    //}
  }
  //if ((keyCode == CONTROL)&&(key == 's')) {
  //  saveData("test");
  //}
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
    }
    //else {
    //  m.filename = m.t2.text;
    //  println("No match found...");
    //}
    m.t2.text = m.filename;        // sets textbox text to file path
    m.t2.k = m.t2.text.length();   // sets number of characters in letters arraylist
    m.t2.letters.clear();
    for (int c = 0; c < m.t2.k; c++) {
      m.t2.letters.append(str(m.t2.text.charAt(c)));      // fills the letters ArrayList of the t2 textbox of menu m
    }
  }
}
