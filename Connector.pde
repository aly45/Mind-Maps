class Connector {
  Vec2D curveBegin, anchor1, anchor2, curveEnd, node1Pos, node2Pos, connectorVector, VirtualPos1, VirtualPos2;
  //int connectedFrom; // node number in nodes ArrayList
  //int connectedTo;   // node number in nodes ArrayList
  Node startNode, endNode, closestNode;
  int startNodeIndex, endNodeIndex, n;
  //boolean drawing = false;    // is the connector currently being drawn?
  float dist;
  float springLength = 130;
  float springStrength = 0.002;//0.002;
  //float strength = 2;
  String connectionMode;
  VerletParticle2D v1, v2;

  Connector(VerletParticle2D p1, VerletParticle2D p2) { //add extra two PVector positions if using bezier
    curveBegin = p1;
    anchor1 = p2;    // where the curve start should be next
  }

  Node findClosestNode(ArrayList<Node> candidates, VerletParticle2D anchor) {    // finds closest node to connector end(s)
    float minDist = width*height;
    for (int i = candidates.size()-1; i >= 0; i--) {
      dist = sqrt(sq(candidates.get(i).x - anchor.x) + sq(candidates.get(i).y - anchor.y));
      if ((dist < minDist)) { //&&(dist != 0)
        minDist = dist;
        //if (minDist < 20) {      // limit to some radius
        closestNode = candidates.get(i);
        //n = i;
        //if (isStart) {
        //  startNodeIndex = i;
        //  startNode = closestNode;
        //  n = startNodeIndex;
        //} else {
        //  endNodeIndex = i;
        //  endNode = closestNode;
        //  n = endNodeIndex;
        //}
        //}
      }
    }
    //println(n);
    return closestNode;  // should check for closestNode == null (if limiting minDist to some radius)
  }

  int getClosestIndex(ArrayList<Node> candidates, VerletParticle2D anchor) {    // returns closest node index. No idea why cloestNode is always 0 if I try to extract it without using this function.
    float minDist = width*height;
    for (int i = candidates.size()-1; i >= 0; i--) {
      dist = sqrt(sq(candidates.get(i).x - anchor.x) + sq(candidates.get(i).y - anchor.y));
      if ((dist < minDist)) { //&&(dist != 0)
        minDist = dist;
        //if (minDist < 20) {      // limit to some radius
        closestNode = candidates.get(i);
        n = i;
        //if (isStart) {
        //  startNodeIndex = i;
        //  startNode = closestNode;
        //  x = startNodeIndex;
        //} else {
        //  endNodeIndex = i;
        //  endNode = closestNode;
        //  x = endNodeIndex;
        //}
        //}
      }
    }
    //println(n);
    return n;  // should check for closestNode == null (if limiting minDist to some radius)
  }

  void setEndpoint(VerletParticle2D p3, VerletParticle2D p4) {
    anchor2 = p3;    // where the curve end point should be next
    curveEnd = p4;
  }

  // Connects nodes with connectors from tables
  void connect(Node n1, Node n2) { // add a spring between two connected nodes
    float nodesDist = sqrt(sq(n1.x - n2.x) + sq(n1.y - n2.y));
    node1Pos = new Vec2D(n1.x, n1.y); // node 1 position vector
    node2Pos = new Vec2D(n2.x, n2.y); // node 2 position vector
    connectorVector = node2Pos.sub(node1Pos); // hopefully this is pointing from node 1 to node 2
    //Vec2D connectionVector = new Vec2D(n2.x - n1.x, n2.y - n1.y); // points from node 1 to node 2    
    VirtualPos1 = node1Pos.add(connectorVector.scale(0.2));  // position vector of virtual particle 1
    VirtualPos2 = node2Pos.sub(connectorVector.scale(0.2));  // position vector of virtual particle 2

    if (curveBegin != curveEnd) {
      v1 = new VerletParticle2D(VirtualPos1);
      physics.addBehavior(new AttractionBehavior2D(v1, n1.w + 3, -n1.strength));
      physics.addParticle(v1);
      v2 = new VerletParticle2D(VirtualPos2);
      physics.addParticle(v2);
      physics.addBehavior(new AttractionBehavior2D(v2, n2.w + 3, -n2.strength));
      physics.addSpring(new VerletSpring2D(n1, v1, nodesDist*0.1, springStrength));  // mini spring from first node
      //println("node 1 is at " + n1.x + ", " + n1.y);      

      //println("virtual particle 1 is at: " + VirtualPos1.x + ", " + VirtualPos1.y);
      physics.addSpring(new VerletSpring2D(v1, v2, nodesDist*0.9, springStrength*0.2));  // main verlet spring

      //println("virtual particle 2 is at: " + VirtualPos2.x + ", " + VirtualPos2.y);
      physics.addSpring(new VerletSpring2D(v2, n2, nodesDist*0.1, springStrength));  // mini spring from second node
      //println("node 2 is at " + n2.x + ", " + n2.y);
    }
  }

  // Connects nodes with connectors by clicking
  // want to add an additional verlet particle connection to each node connection
  void connect(Node n1, Node n2, float tempLength) { // add a spring between two connected nodes
    float nodesDist = sqrt(sq(n1.x - n2.x) + sq(n1.y - n2.y));
    // calculate where virtual particles are:
    node1Pos = new Vec2D(n1.x, n1.y); // node 1 position vector
    node2Pos = new Vec2D(n2.x, n2.y); // node 2 position vector
    connectorVector = node2Pos.sub(node1Pos); // points from node 1 to node 2  
    VirtualPos1 = node1Pos.add(connectorVector.scale(0.2));  // position vector of virtual particle 1
    VirtualPos2 = node2Pos.sub(connectorVector.scale(0.2));  // position vector of virtual particle 2

    if (curveBegin != curveEnd) {
      v1 = new VerletParticle2D(VirtualPos1);
      physics.addBehavior(new AttractionBehavior2D(v1, n1.w + 3, -n1.strength));
      physics.addParticle(v1);
      v2 = new VerletParticle2D(VirtualPos2);
      physics.addBehavior(new AttractionBehavior2D(v2, n2.w + 3, -n2.strength));
      physics.addParticle(v2);
      physics.addSpring(new VerletSpring2D(n1, v1, nodesDist*0.1, springStrength));  // mini spring from first node
      println("node 1 is at " + n1.x + ", " + n1.y);      

      println("virtual particle 1 is at: " + VirtualPos1.x + ", " + VirtualPos1.y);
      physics.addSpring(new VerletSpring2D(v1, v2, nodesDist*0.9 + tempLength, springStrength));  // main verlet spring

      println("virtual particle 2 is at: " + VirtualPos2.x + ", " + VirtualPos2.y);
      physics.addSpring(new VerletSpring2D(v2, n2, nodesDist*0.1, springStrength));  // mini spring from second node
      println("node 2 is at " + n2.x + ", " + n2.y);
    }
  }

  void display() {
    strokeWeight(2);
    noFill();
    if ((curveBegin != null)&&(curveEnd != null)) {  // checks if curveBegin and curveEnd are actually assigned.
      if (curveBegin != curveEnd) {
        stroke(0);
        bezier(curveBegin.x, curveBegin.y, v1.x, v1.y, v2.x, v2.y, curveEnd.x, curveEnd.y);
        stroke(255);
        ellipse(v1.x, v1.y, 5, 5);
        ellipse(v2.x, v2.y, 5, 5);
      }
    }
  }

  boolean mouseOver(float tempx, float tempy, float tempw, float temph) {
    if (((mouseX >= tempx)&&(mouseX <= tempx+tempw)) && 
      ((mouseY >= tempy)&&(mouseY <= tempy+temph))) {
      return true;
    } else {
      return false;
    }
  }
}
