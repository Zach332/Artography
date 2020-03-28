LocationSystem ls;
final int MAX_BUILDING_SIZE = 50;
final int MIN_BUILDING_SIZE = 30;
final int INITIAL_PEOPLE = 200;
double max_lat_dif = -1000000;
double min_lat = 1000000;
double max_lon_dif = -1000000;
double min_lon = 1000000;

final int BUILDING_SIZE_CONSTANT = 13000;

void setup() {
  size(1400, 800);
  ls = new LocationSystem();
}

void initializeAll() {
  setGlobals();
  for(int i = 0; i < ls.locations.size(); i++) {
      Location l = ls.locations.get(i);
      l.initialize();
  }
  addPeople();
}

void setGlobals() {
  for(int i = 0; i < ls.locations.size(); i++) {
    Location l = ls.locations.get(i);
    if(l.lat-min_lat>max_lat_dif)max_lat_dif = l.lat-min_lat;
    if(l.lon-min_lon>max_lon_dif)max_lon_dif = l.lon-min_lon;
  }
}

void addLocation(float lat, float lon, int xLen, int yLen, String name) {
  ls.addLocation(lat, lon, xLen, yLen, name);
}

void addPeople() {
  for(int i = 0; i < INITIAL_PEOPLE; i++) {
    ls.addPerson();
  }
}
  

void draw() {
  background(0);
  ls.run();
}

void mouseClicked() {
  ls.addPerson(mouseX, mouseY);
}


// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 

class LocationSystem {
  ArrayList<Person> people;
  ArrayList<Location> locations;
  PVector origin;

  LocationSystem() {
    people = new ArrayList<Person>();
    locations = new ArrayList<Location>();
  }

  void addPerson() {
    people.add(new Person());
  }
  
  void addPerson(float x, float y) {
    people.add(new Person(x, y));
  }
  
  void addLocation(double lat, double lon, int sizeX, int sizeY, String name) {
    locations.add(new Location(lat, lon, sizeX, sizeY, name));
    if(lat<min_lat)min_lat = lat;
    if(lon<min_lon)min_lon = lon;
  }

  void run() {
    for(int i = 0; i < locations.size(); i++) {
      Location l = locations.get(i);
      l.run();
    }
    for (int i = people.size()-1; i >= 0; i--) {
      Person p = people.get(i);
      p.run();
      if (p.isDead()) {
        people.remove(i);
      }
    }
  }
}

class Person {
  PVector position;
  PVector velocity;
  Location target;
  boolean dead = false;
  int r, g, b;
  Person(PVector l) {
    position = l.copy();
    target = ls.locations.get((int)random(ls.locations.size()));
    double velMultiplier = random(.005,.01);
    velocity = new PVector((float)((target.getLocX() - position.x)*velMultiplier), (float)((target.getLocY() - position.y)*velMultiplier));
    r = target.r;
    g = target.g;
    b = target.b;
  }
  
  Person() {
    this(new PVector(width/2, height/2));
  }
  
  Person(float x, float y) {
    this(new PVector(x, y));
  }

  void run() {
    update();
    display();
  }

  // Method to update position
  void update() {
    position.add(velocity);
    if(target.isInside(position.x, position.y)) {
      dead = true;
      ls.addPerson(position.x, position.y);
    }
  }

  // Method to display
  void display() {
    stroke(r, g, b);
    fill(r, g, b);
    ellipse(position.x, position.y, 8, 8);
  }

  // Is the particle still useful?
  boolean isDead() {
    return dead;
  }
}

class Location {
  String name;
  double lat;
  double lon;
  float locX;
  float locY;
  int sizeX;
  int sizeY;
  int r, g, b;
  public Location(double lat, double lon, int sizeX, int sizeY, String name) {
    this.lat = lat;
    this.lon = lon;
    this.sizeX = sizeX;
    this.sizeY = sizeY;
    this.name = name;
    r = int(random(128,256));
    g = int(random(128,256));
    b = int(random(128,256));
  }
  
  void initialize() {
    locX = (float)((lat-min_lat)/max_lat_dif)*(width-MAX_BUILDING_SIZE);
    locY = (float)((lon-min_lon)/max_lon_dif)*(height-MAX_BUILDING_SIZE);
  }
  
  public float getLocX() {
    return locX+sizeX/2;
  }
  
  public float getLocY() {
    return locY+sizeY/2;
  }
  
  void run() {
    display();
  }
  
  boolean isInside(float x, float y) {
    if(x<getLocX()+sizeX&&x>getLocX()-sizeX&&y<getLocY()+sizeY&&y>getLocY()-sizeY)return true;
    return false;
  }
  
  void display() {
    noStroke();
    fill(r, g, b);
    rect(locX, locY, sizeX, sizeY);
    textAlign(CENTER, CENTER);
    text(name, locX+sizeX/2, locY+sizeY+10);
  }
}
