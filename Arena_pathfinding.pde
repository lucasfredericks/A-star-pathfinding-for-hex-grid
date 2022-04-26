import processing.video.*;
import java.util.*;
import org.ejml.*;
import java.io.*;
import boofcv.struct.calib.*;
import boofcv.io.calibration.CalibrationIO;
import boofcv.alg.geo.PerspectiveOps;
import georegression.*;

Hexgrid hexGrid;
Arena arena;
Hexagon startHex;
Hexagon targetHex;
int startDirection;
AStar pathFinder;


PGraphics gridOutlines;
PGraphics gridFill;
PGraphics arenaMask;

//Settings variables
int impassableRate = 4; //set between 0 and 10. Higher numbers increase the rate of impassable hexes
int hexSize = 20; //
int stepDelay = 10;

void setup() {
  frameRate(30);
  surface.setSize(1920, 1080);
  fullScreen(1);

  initArena();
  gridOutlines = createGraphics(width, height);
  gridFill = createGraphics(width, height);
  hexGrid.drawOutlines(gridOutlines);
  pathFinder = new AStar(hexGrid);
  mouseClicked();
}

void initArena() { // Create a mask to determine where hexes will be drawn
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
  hexGrid.drawHexes(gridFill);
  image(gridFill, 0, 0, width, height);
  image(gridOutlines, 0, 0, width, height);
  pathFinder.calculate();
  pathFinder.generatePath();
  pathFinder.displayPath();
  delay(stepDelay);
}

void mouseClicked() {

  hexGrid.seedMap(impassableRate); //assign impassable/passable to each hex
  startHex = pickHex(); //random start
  targetHex = pickHex(); //random target
  pathFinder.reset();
  pathFinder.setTargets(startHex, targetHex);
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
