class Spot extends Hexagon {  
  float f = 0;
  float g = 0;
  float heuristic = 0;
  Hexagon parent;

  boolean passable;

  List<PVector> neighborIDs = new ArrayList<PVector>();

  Spot previous = null;

  Spot(Hexgrid hexgrid_, int hexQ_, int hexR_) {
    super(hexgrid_, hexQ_, hexR_);
    parent = hexGrid.getHex(this.id);
    this.passable = parent.passable;
  }
  Spot(Hexgrid hexGrid_, Hexagon h){
    super(hexGrid_, h.hexQ, h.hexR);
    parent = h;
  }
  void addNeighbors() {
    Hexagon[] neighbors_ = hexGrid.getNeighbors(this);
    for (int i = 0; i < neighbors_.length; i++) {
      PVector hexKey = neighbors_[i].getKey();
      if (hexGrid.checkHex(hexKey) && hexGrid.passable(hexKey)) {
        neighborIDs.add(hexKey);
      }
    }
  }
  Hexagon getParent(){
   return parent; 
  }
}
