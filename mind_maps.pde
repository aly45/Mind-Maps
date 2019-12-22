// Read about force-directed graphs: https://natureofcode.com/book/chapter-5-physics-libraries/#chapter05_section18
import toxi.geom.*;
import toxi.physics2d.*;
import toxi.physics2d.behaviors.*;
import org.gicentre.handy.*;

VerletPhysics2D physics;

ArrayList<Node> nodes;  //array list of nodes
ArrayList<Connector> connectors;  //array list of connectors (arrows/lines)
PVector mouse, lastnode, draggedline;//lastline;
boolean sketchy = false;
float rectW = 80, rectH = 40;
String MODE = "PLACING_NODES"; // "NODE_SELECTED";
boolean overNode = false, nodeSelected = false;
Node selectedNode, draggedNode;

void setup() {
  size(600, 400);
  surface.setTitle("Mind Maps");
  surface.setResizable(true);
  surface.setLocation(100, 100);

  physics = new VerletPhysics2D();
  physics.setWorldBounds(new Rect(0, 0, width, height));
  physics.setDrag (0.05); //0.05

  nodes = new ArrayList<Node>();
  connectors = new ArrayList<Connector>();

  lastnode = new PVector(0, 0);
  draggedline = new PVector(0, 0);
}

void draw() {
  background(200); //10, 17, 60);
  physics.update ();

  mouse = new PVector(mouseX, mouseY);

  if (nodes.size() > 0) {
    overNode = nodes.get(0).mouseOver(nodes.get(0).x, nodes.get(0).y, rectW, rectH);
  }
  for (int i = 0; i < nodes.size(); i++) {    // goes through all the nodes
    overNode = overNode||(nodes.get(i).mouseOver(nodes.get(i).x, nodes.get(i).y, rectW, rectH));    // update global variable overNode
    nodes.get(i).addText(nodes.get(i).selected);     // add text to selected node
    
    if ((mousePressed)&&(nodes.get(i).selected)) {
      nodes.get(i).lock();
      nodes.get(i).set(mouseX, mouseY);
    } else {
      nodes.get(i).unlock();
    }
  }

  for (Node n : nodes) {  // for every node in the arrayList nodes,
    n.display();          // display the node
  }

  for (Connector c : connectors) {  // for every connector in the arrayList connectors,
    c.display();         // display the connector
  }

  println(overNode);
}

void mouseReleased() {
  if (mouseButton == LEFT) {
    println(nodes.size());
    if (!overNode) {
      //MODE = "PLACING_NODES";
      nodeSelected = false;
      //lastnode.set(mouseX, mouseY);
      nodes.add(new Node(new Vec2D(mouseX, mouseY), rectW, rectH, this));    // ADD a new NODE
      //      lastnode = nodes.get(nodes.size()-1);
      //      physics.addParticle(l);
      println(nodes.size());
    } else {
      for (Node n : nodes) {
        if (n.mouseOver(n.x, n.y, rectW, rectH)) {    // mouse is L-clicked on a node
          //MODE = "NODE_SELECTED";
          n.selected = !n.selected; //true;
          nodeSelected = !nodeSelected; //true;
          selectedNode = n;
        } else {
          n.selected = false;
        }
      }
    }
  }

  if (mouseButton == RIGHT) {
    if (nodeSelected) {
      //      VerletSpring2D spring = new VerletSpring2D(p1, p2, 160, 0.001);
      draggedline = mouse.sub(lastnode);  // difference between centre of last node and current mouse position
      connectors.add(new Connector(lastnode, lastnode, draggedline, draggedline));
    }
  }
}

void keyPressed() {
  if (key == BACKSPACE) {
    if (nodes.size() > 0) {
      println(nodes.get(nodes.size() - 1));
      nodes.remove(nodes.size() - 1);
    }
  }
}

//void mouseDragged() {
//  if (nodeSelected) {
//    selectedNode.set(mouseX, mouseY);
//  }
//}

//void mouseDragged(){
//  println(draggedline);
//  draggedline = mouse.sub(lastnode);  // difference between centre of last node and current mouse position
//  println(draggedline);
//  connectors.add(new Connector(lastnode, draggedline));
//}
