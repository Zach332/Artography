LocationSystem ls;
final int MAX_BUILDING_SIZE = 50;
final int MIN_BUILDING_SIZE = 30;
double max_lat_dif = Double.MIN_VALUE;
double min_lat = Double.MAX_VALUE;
double max_lon_dif = Double.MIN_VALUE;
double min_lon = Double.MAX_VALUE;

void setup() {
  size(1400, 800);
  ls = new LocationSystem();
  parseFile("json");
}

void parseFile(String fileName) {
  JSONArray places = loadJSONObject(fileName).getJSONArray("results");
  for (int i = 0; i < places.size(); i++) {
    JSONObject place = places.getJSONObject(i);
    if (validPlace(place)) {
      JSONObject location = place.getJSONObject("geometry").getJSONObject("location");
      ls.addLocation(location.getFloat("lat"), location.getFloat("lng"));
    }
  }
}

boolean validPlace(JSONObject place) {
  JSONArray types = place.getJSONArray("types");
  for (int i = 0; i < types.size(); i++) {
    if (types.getString(i).equals("locality")) return false;
    if (types.getString(i).equals("political")) return false;
  }
  return true;
}
  

void draw() {
  background(0);
  ls.addPerson();
  ls.run();
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
  
  void addLocation(double lat, double lon) {
    locations.add(new Location(lat, lon));
    if(lat<min_lat)min_lat = lat;
    if(lon<min_lon)min_lon = lon;
    if(lat-min_lat>max_lat_dif)max_lat_dif = lat-min_lat;
    if(lon-min_lon>max_lon_dif)max_lon_dif = lon-min_lon;
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
  PVector acceleration;
  float lifespan;

  Person(PVector l) {
    acceleration = new PVector(0, 0.05);
    velocity = new PVector(random(-1, 1), random(-2, 0));
    position = l.copy();
    lifespan = 255.0;
  }
  
  Person() {
    this(new PVector(width/2, height/2));
  }
  

  void run() {
    update();
    display();
  }

  // Method to update position
  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    lifespan -= 1.0;
  }

  // Method to display
  void display() {
    stroke(255, lifespan);
    fill(255, lifespan);
    ellipse(position.x, position.y, 8, 8);
  }

  // Is the particle still useful?
  boolean isDead() {
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}

class Location {
  double lat;
  double lon;
  int sizeX;
  int sizeY;
  int r, g, b;
  public Location(double lat, double lon, int sizeX, int sizeY) {
    this.lat = lat;
    this.lon = lon;
    this.sizeX = sizeX;
    this.sizeY = sizeY;
    r = int(random(0,256));
    g = int(random(0,256));
    b = int(random(0,256));
  }
  
  public Location(double lat, double lon) {
    this(lat, lon, (int)random(MIN_BUILDING_SIZE, MAX_BUILDING_SIZE),(int)random(MIN_BUILDING_SIZE, MAX_BUILDING_SIZE));
  }
  
  void run() {
    display();
  }
  
  void display() {
    noStroke();
    fill(r, g, b);
    println(lat + " " + min_lat + " " + max_lat_dif);
    rect((float)((lat-min_lat)/max_lat_dif)*height, (float)((lon-min_lon)/max_lon_dif)*width, sizeX, sizeY);
  }
}
