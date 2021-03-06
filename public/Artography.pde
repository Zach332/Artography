LocationSystem ls;
final int MAX_BUILDING_SIZE = 50;
final int MIN_BUILDING_SIZE = 30;
final int INITIAL_PEOPLE = 200;
double max_lat_dif = -1000000;
double min_lat = 1000000;
double max_lon_dif = -1000000;
double min_lon = 1000000;
boolean textDisplayed = false;

final int BUILDING_SIZE_CONSTANT = 13000;

void setup() {
  size(850, 600);
  ls = new LocationSystem();
  background(0);
}

void initializeAll() {
  setGlobals();
  for(int i = 0; i < ls.locations.size(); i++) {
      Location l = ls.locations.get(i);
      l.initialize();
  }
  for(int i = 0; i < ls.locations.size(); i++) {
      Location l = ls.locations.get(i);
      for(int j = 0; j < ls.locations.size(); j++) {
		if(ls.locations.get(j).isInside(l.getLocX()+l.sizeX/2, l.getLocY()+l.sizeY/2)) {
			ls.locations.remove(i);
			i--;
			break;
		}
	}
  }
  addPeople();
}

void setGlobals() {
  for(int i = 0; i < ls.locations.size(); i++) {
    Location l = ls.locations.get(i);
    if (l.lat-min_lat > max_lat_dif) max_lat_dif = l.lat-min_lat;
    if (l.lon-min_lon > max_lon_dif) max_lon_dif = l.lon-min_lon;
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
  ls.run();
}

void mouseClicked() {
  if(ls.locations.size()>0)ls.addPerson(mouseX, mouseY);
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
      l.eraseAllUnneededText();
    }
    textDisplayed = false;
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
  float slowdown = 5;
  int r, g, b;
  Person(PVector l) {
    position = l;
    target = ls.locations.get((int)random(ls.locations.size()));
    double velMultiplier = random(2.5,5)/dist(position.x, position.y, target.getLocX(), target.getLocY());
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
	stroke(0, 0, 0);
	fill(0, 0, 0);
	ellipse(position.x, position.y, 8, 8);
	if(slowdown<0) {
		if(slowdown<-5) {
			dead = true;
			ls.addPerson(position.x, position.y);
		}
		position.add(new PVector(velocity/(-1*slowdown/2), velocity/(-1*slowdown/2)));
		slowdown-=.5;
	} else {
		if(target.isInside(position.x, position.y)) {
		  slowdown = -1;
		}
		if(slowdown==0) {
			position.add(velocity);
		} else {
			position.add(new PVector(velocity/(slowdown/2), velocity/(slowdown/2)));
			slowdown-=.5;
		}
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
    locX = (float)((lon - min_lon) / max_lon_dif) * (width - MAX_BUILDING_SIZE);
	locY = (float)(((lat - min_lat) * -1) / max_lat_dif) * (height - MAX_BUILDING_SIZE) + (height - MAX_BUILDING_SIZE);
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
    if(x<getLocX()+sizeX/2&&x>getLocX()-sizeX/2&&y<getLocY()+sizeY/2&&y>getLocY()-sizeY/2)return true;
    return false;
  }
  
  void eraseAllUnneededText() {
	  if(!isInside(mouseX, mouseY)) {
		  fill(0, 0, 0);
		  text(name, locX+sizeX/2, locY+sizeY+10);
		}
	}
  
  void display() {
    noStroke();
	fill(r, g, b);
    rect(locX, locY, sizeX, sizeY);
    stroke(0,0,0);
	line(locX,locY+sizeY, locX+sizeX/2,locY+sizeY/2);
	line(locX+sizeX/2,locY+sizeY/2, locX+sizeX, locY+sizeY);
	line(locX, locY+sizeY/2, locX+sizeX/2, locY);
	line(locX+sizeX/2, locY, locX+sizeX, locY+sizeY/2);
	if(!textDisplayed&&isInside(mouseX, mouseY)) {
		  textDisplayed = true;
		  textAlign(CENTER, CENTER);
		  text(name, locX+sizeX/2, locY+sizeY+10);
	}
  }
}
