import boofcv.processing.*;
import processing.video.*;
import java.util.*;
import org.ejml.*;
import java.io.*;
import boofcv.struct.calib.*;
import boofcv.io.calibration.CalibrationIO;
import boofcv.alg.geo.PerspectiveOps;
import georegression.*;

//SimpleFiducial detector;

Hexgrid hexGrid;
Arena arena;
Hexagon startHex;
Hexagon targetHex;
int startDirection;
AStar pathFinder;

int hexSize = 70;
int margin = 20;
color bg = color(0, 0, 0, 0);
color hover = color(255);
PGraphics gridOutlines;
PGraphics gridFill;
PGraphics arenaMask;

void setup() {
  frameRate(30);
  surface.setSize(1920, 1080); //have to do this manually for detector to work
  fullScreen(1);// specifying renderer here appears to break the detector
  initArena();




  //println("governor instantiated");
  gridOutlines = createGraphics(width, height);
  gridFill = createGraphics(width, height);
  hexGrid.drawOutlines(gridOutlines);
  println("setup complete");
  pathFinder = new AStar(hexGrid);
  mouseClicked();
}

void initArena() {
  arena = new Arena();
  PVector[] pxCorners = new PVector[6];
  int j = 0;
  for (int i = 0; i < 360; i+= 60) {
    float theta = radians(i);
    float x = .5*height * cos(theta);
    float y = .5*height * sin(theta);
    pxCorners[j] = new PVector(x, y);
    println(pxCorners[j]);
    j++;
  }
  arenaMask = arena.init(pxCorners);
  hexGrid = new Hexgrid(hexSize, arenaMask);
}

void draw() {
  background(255);
  ////canvas.beginDraw();
  //image(arenaMask, 0, 0, width, height);

  //startHex.drawHexFill(gridFill, 255);
  //targetHex.drawHexFill(gridFill, 255);
  hexGrid.drawHexes(gridFill);
  image(gridFill, 0, 0, width, height);
  image(gridOutlines, 0, 0, width, height);
  pathFinder.calculate();
  pathFinder.generatePath();
  pathFinder.displayPath();
  delay(100);
  //pushMatrix();
  //translate(startHex.pixelX, startHex.pixelY);
  //rotate(startDirection*(TWO_PI/6));
  //line(0, 0, 0, -hexSize);
  //popMatrix();
}

void mouseClicked() {

  hexGrid.seedMap(4);
  startHex = pickHex();
  //startDirection = int(random(0, 6));
  //println(startDirection);
  targetHex = pickHex();
  pathFinder.reset();
  pathFinder.setTargets(startHex, targetHex);


  //hexGrid.drawHexes(gridFill);

  pathFinder.calculate();
  pathFinder.displayPath();
}

Hexagon pickHex() {
  Hexagon h;
  Object[] keys = hexGrid.allHexes.keySet().toArray();
  do {
    Object randHexKey = keys[new Random().nextInt(keys.length)];
    h = hexGrid.getHex((PVector)randHexKey);
  } while ( h == targetHex || h == startHex || !h.passable);
  return h;
}
