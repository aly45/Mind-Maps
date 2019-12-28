class Connector {
  Vec2D curveBegin, anchor1, anchor2, curveEnd;
  //int connectedFrom; // node number in nodes ArrayList
  //int connectedTo;   // node number in nodes ArrayList
  Node startNode, endNode, closestNode;
  int startNodeIndex, endNodeIndex, n;
  //boolean drawing = false;    // is the connector currently being drawn?
  float dist;
  float springLength = 130;
  float springStrength = 0.002;

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

  void connect(VerletParticle2D n1, VerletParticle2D n2) { // add a spring between two connected nodes
    //springLength = dist*12;    // length at equilibrium
    //print(springLength);
    if (curveBegin != curveEnd) {
      physics.addSpring(new VerletSpring2D(n1, n2, springLength, springStrength));
    }
  }

  void display() {
    stroke(0);
    if ((curveBegin != null)&&(curveEnd != null)) {  // checks if curveBegin and curveEnd are actually assigned.
      if (curveBegin != curveEnd) {
        bezier(curveBegin.x, curveBegin.y, anchor1.x, anchor1.y, anchor2.x, anchor2.y, curveEnd.x, curveEnd.y);
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
