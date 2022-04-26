/* //<>// //<>// //<>//
 Hex grid calculations are based on the excellent interactive Hexagonal Grids guide
 from Amit Patel at Red Blob Games (https://www.redblobgames.com/grids/hexagons)
 
 There is also an implementation guide, which I did not see until I had done a lot of things the ugly way.
 If there is time, I will refactor this class into something resembling the more elegant version at:
 https://www.redblobgames.com/grids/hexagons/implementation.html
 */
class Hexgrid {
  HashMap<PVector, Hexagon> allHexes;
  PVector[] neighbors;
  
  //variables to constrain the cube grid parameters 
  int qMin = -100;   //the q axis corresponds to the x axis on the screen. Higher values are further right
  int qMax = 100;
  int rMin = -100;   //the r axis is 30 degrees counterclockwise to the q/x axis. Higher values are down and to the left
  int rMax = 100;
  int hexSize;
  Hexagon r1Hex;




  Hexgrid(int hexSize_, PGraphics mask) {
    neighbors = new PVector[6]; //pre-compute the 3D transformations to return adjacent hexes in 2D grid
    neighbors[0] = new PVector(0, 1, -1); // N
    neighbors[1] = new PVector(1, 0, -1); // NE
    neighbors[2] = new PVector(1, -1, 0); // SE
    neighbors[3] = new PVector(0, -1, 1); // S
    neighbors[4] = new PVector(-1, 0, 1); // SW
    neighbors[5] = new PVector(-1, 1, 0); // NW

    hexSize = hexSize_;

    mask.loadPixels();
    allHexes = new HashMap<PVector, Hexagon>();
    for (int q = qMin; q <= qMax; q++) {
      for (int r = rMin; r <= rMax; r++) {
        int y = -q - r;
        PVector loc = (hexToPixel(q, r));
        if (loc.x > hexSize/2 && loc.x < mask.width-hexSize/2 && loc.y > hexSize/2 && loc.y < mask.height-hexSize/2) {
          if (mask.get((int)loc.x, (int)loc.y)== -1) {
            PVector hexID = new PVector(q, y, r);
            Hexagon h = new Hexagon(this, q, r);
            //println(hexID);
            allHexes.put(hexID, h);
          }
        }
      }
    }
  }

  void drawOutlines(PGraphics buffer) {
    buffer.beginDraw();
    buffer.clear();
    buffer.noFill();
    buffer.strokeWeight(10);
    buffer.stroke(0, 0, 255);
    //println(allHexes.entrySet());
    for (Map.Entry<PVector, Hexagon> me : allHexes.entrySet()) {
      Hexagon h = me.getValue();
      h.drawHexOutline(buffer);  
      //println("drawing hexagon: " + h + " at " + h.pixelX + ", " + h.pixelY);
    }
    buffer.endDraw();
  }

  void drawHexes(PGraphics buffer) {
    buffer.beginDraw();
    buffer.clear();
    buffer.noFill();
    buffer.noStroke();
    //println(allHexes.entrySet());
    color c;
    for (Map.Entry<PVector, Hexagon> me : allHexes.entrySet()) {
      Hexagon h = me.getValue();
      if (h.passable) {
        c = color(0, 255, 0);
      } else {
        c = color(255, 0, 0);
      }
      h.drawHexFill(buffer, c);
    }
    startHex.drawHexFill(buffer, 255);
    targetHex.drawHexFill(buffer, 255);
    buffer.endDraw();
  }

  void seedMap(int i) { //low i == more passable hexes
    float j;
    for (Map.Entry<PVector, Hexagon> me : allHexes.entrySet()) {
      j = random(10);
      Hexagon h = me.getValue();
      if (i>=j) {
        h.impassable();
      } else {
        h.passable();
      }
    }
  }


  //void drawHexFill(PGraphics buffer, Hexagon h, color c) {
  //  buffer.beginDraw();
  //  h.
  //}
  //void updateRoverLocation(int roverID, FiducialFound f) {
  //}
  //PVector getHexKeyfromHex(Hexagon h){

  //}

  Hexagon getHex(PVector hexKey) {   //hashmap lookup to return hexagon from PVector key
    Hexagon h = allHexes.get(hexKey);
    return(h);
  }
  PVector getXY(PVector hexKey) {   //hashmap lookup to return hexagon from PVector key
    Hexagon h = allHexes.get(hexKey);
    PVector hxy = h.getXY();
    return(hxy);
  }

  PVector getXY(Hexagon h) {
    PVector hxy = h.getXY();
    return (hxy);
  }

  //Hexagon getHex(Point2D_F64 hexKey_) {   //hashmap lookup to return hexagon from PVector key
  //  PVector hexKey = new PVector((float)hexKey_.x, (float)hexKey_.y);
  //  Hexagon h = allHexes.get(hexKey);
  //  return(h);
  //}

  Hexagon pixelToHex(int xPixel, int yPixel) {   //find which hex a specified pixel lies in
    PVector hexID = new PVector();
    hexID.x = (2./3*xPixel)/hexSize;
    hexID.z = (-1./3 * xPixel + sqrt(3)/3 * yPixel)/hexSize;
    hexID.y = (-hexID.x - hexID.z);
    hexID = cubeRound(hexID);
    Hexagon h = allHexes.get(hexID);
    return h;
  }
  Hexagon pixelToHex(PVector location) {   //find which hex a specified pixel lies in
    PVector hexID = new PVector();
    hexID.x = (2./3*location.x)/hexSize;
    hexID.z = (-1./3 * location.x + sqrt(3)/3 * location.y)/hexSize;
    hexID.y = (-hexID.x - hexID.z);
    hexID = cubeRound(hexID);
    Hexagon h = allHexes.get(hexID);
    return h;
  }

  PVector pixelToKey(PVector location) {
    PVector hexID = new PVector();
    hexID.x = (2./3*location.x)/hexSize;
    hexID.z = (-1./3 * location.x + sqrt(3)/3 * location.y)/hexSize;
    hexID.y = (-hexID.x - hexID.z);
    hexID = cubeRound(hexID);
    return hexID;
  }

  Hexagon[] getNeighbors(Hexagon h) {   //return an array of the 6 neighbor cells. If the neighbor is out of bounds, its array location will be null
    Hexagon[] neighborList = new Hexagon[6];
    PVector hexID = h.getKey();
    for (int i = 0; i < 6; i++) {
      PVector neighborID = hexID.copy();
      neighborID = neighborID.add(neighbors[i]);
      Hexagon neighbor = getHex(neighborID);
      if (neighbor == null) {
        neighborList[i] = null;
      } else {
        neighborList[i] = neighbor;
      }
    }
    return(neighborList);
  }
  PVector[] getNeighborIDs(PVector hexID) {
    PVector[] neighborList = new PVector[6];
    PVector neighborID = new PVector();
    for (int i = 0; i < 6; i++) {
      neighborID.set(hexID);
      neighborID = neighborID.add(neighbors[i]);
      neighborList[i] = neighborID;
    }
    return(neighborList);
  }

  boolean checkHex(PVector hexKey_) {
    return (allHexes.containsKey(hexKey_));
  }
  
  boolean passable(PVector hexKey_){
   Hexagon h = getHex(hexKey_);
   return h.passable;
  }

  Hexagon getNeighbor(Hexagon h, int neighbor) {
    PVector hexID = h.getKey();
    PVector neighborID = hexID.copy();
    neighborID = neighborID.add(neighbors[neighbor]);
    Hexagon neighborHex = getHex(neighborID);
    return h;
  }

  Hexagon[] getNeighbors(PVector hexID) {   //overloaded method to accept a pvector key instead of a Hexagon object
    Hexagon[] neighborList = new Hexagon[6];
    for (int i = 0; i < 6; i++) {
      PVector neighborID = hexID.copy();
      neighborID = neighborID.add(neighbors[i]);
      Hexagon neighbor = getHex(neighborID);
      if (neighbor == null) {
        neighborList[i] = null;
      } else {
        neighborList[i] = neighbor;
      }
    }
    return(neighborList);
  }

  PVector hexToPixel(int q, int r) {
    PVector temp = new PVector(0, 0);
    temp.x = hexSize * (3./2. * q);
    temp.y = hexSize * (sqrt(3)/2. * q + sqrt(3) * r);
    return(temp);
  }

  PVector cubeRound(PVector hexID) {
    int rx = round(hexID.x);
    int ry = round(hexID.y);
    int rz = round(hexID.z);

    float xdiff = abs(rx - hexID.x);
    float ydiff = abs(ry - hexID.y);
    float zdiff = abs(rz - hexID.z);

    if (xdiff > ydiff && xdiff > zdiff) {
      rx = -ry-rz;
    } else if (ydiff > zdiff) {
      ry = -rx-rz;
    } else {
      rz = -rx-ry;
    }
    PVector rHexID = new PVector(rx, ry, rz);
    return(rHexID);
  }
  float normalizeRadians(float theta) {
    while (theta < 0 || theta > TWO_PI) {
      if (theta < 0) {
        theta += TWO_PI;
      }
      if (theta > TWO_PI) {
        theta -= TWO_PI;
      }
    }
    return theta;
  }
  Float cubeDistance(Hexagon a, Hexagon b) {
    PVector vec = cubeSubtract(a,b);
    return (abs(vec.x) + abs(vec.y) + abs(vec.z))/2;
  }

  PVector cubeSubtract(Hexagon a, Hexagon b) {
    PVector sub = new PVector(a.hexQ - b.hexQ, a.hexR - b.hexR, a.hexS - b.hexS);
    return sub;
  }
}
