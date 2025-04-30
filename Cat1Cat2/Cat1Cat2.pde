/*
4/24/25
V3 - restart from scratch to make code more good

goals: 
[ ] basic version with cat 1 and cat 2 in game
[ ] hitboxes
[ ] add missing texture to textures
[ ]
[ ]
[X] use pvectors instead of trying my own system
[ ] organize code into separate class files and data folders
[ ] have walls drawn, saved, and loaded based on fractions of width and height
[ ] add main menu screen, map select screen, win screen, cutscene??
[ ] figure out how to add good buttons, maybe as a class?
[ ] fix and properly add explosions
[ ] make proper hitbox and collision system
[ ] add different guns with different bullets
[ ] add character select screen
[ ] make map layouts more interesting - draw separately
[ ] add more map elements like doors
[ ] maybe add gun sights with lines
[ ] fix sprites in gimp to better represent hitbox
[ ] brainstorm how to best optimize handling keyboard
[ ] add images to repo
[ ] start blogging development
[ ] idea: bullets can bounce off each other

notes:
- keep methods and logic organized and clean
- study documentation to take advantage of all processing has to offer
- set up repo to document whole process(ing)
- figure out how to port to p5js for browser port
- commit to repo regularly
*/


/*===IMPORTS===*/
import java.util.ArrayList;  // the goat
import java.util.Scanner;
import java.io.File;
import java.io.FileNotFoundException;

/*===ARRAYLISTS===*/
ArrayList<Cat> cats = new ArrayList<Cat>();
ArrayList<Bullet> bullets = new ArrayList<Bullet>();
ArrayList<Cat> catsToKill = new ArrayList<Cat>();
ArrayList<Bullet> bulletsToKill = new ArrayList<Bullet>();
//ArrayList<Wall> walls = new ArrayList<Wall>();
//ArrayList<Wall> wallsToKill = new ArrayList<Wall>();

/*===CONSTANTS===*/


/*===DEFAULT OBJECTS===*/
PImage defaultSprite;
PImage player1Sprite;
PImage player2Sprite;
Cat player1;
Cat player2;

/*===SETUP===*/
void setup() {
  // set up window
  windowTitle("Cat1Cat2");
  windowResize(displayWidth, displayHeight);
  windowMove(0,0);
  
  // load images
  defaultSprite = loadImage("sprites/default.png");
  player1Sprite = loadImage("sprites/player1.png");
  player2Sprite = loadImage("sprites/player2.png");
  
  // initialize players
  player1 = new Cat(10,10);
  player1.setSprite(player1Sprite);
  player2 = new Cat(width-10,10);
  player2.setSprite(player2Sprite);
  resetGame();
}

void resetGame() {
  cats.clear();
  bullets.clear();
  
  cats.add(player1);
  cats.add(player2);
}

void tickGame() {
  
  handleCats();
  handleBullets();
}

void draw() {
    background(255);

  // add switch later for different screens
  tickGame();
}

/*===CLASSES===*/
/*ENTITY*/
class Entity {
  PVector pos;
  PVector vel;
  PVector acc;
  PImage sprite;
  PVector size;
  Entity(float x, float y) {
    pos = new PVector(x,y);
    vel = new PVector();
    acc = new PVector();
    sprite = defaultSprite;
    size = new PVector(25,25);
  }
  void display() {
    pushMatrix();
    imageMode(CENTER);
    image(sprite,pos.x,pos.y,size.x,size.y);
    popMatrix();
  }
  void move() {
    pos.add(vel);
  }
  void setSprite(PImage newSprite) {
    sprite = newSprite;
  }
  void setSize(float x, float y) {
    size.x = x;
    size.y = y;
  }
}

/*CAT*/
class Cat extends Entity {
  int health;
  long lastShot;
  Gun gun;
  Cat(int x, int y) {
    super(x,y);
    health = 100;
    gun = new Gun("gun1");
    gun.setOwner(this);
  }
  void move() {
    super.move();
    // add collisions
  }
  void setGun(Gun gun) {
    this.gun = gun;
    gun.setOwner(this);
  }
  void display() {
    super.display();
  }
}

/*BULLET*/
// TO DO: ADD BOUNCES
class Bullet extends Entity {
  int bulletDamageAmount;
  
  Bullet(float x, float y) {
    super(x,y);
  }
  
  void display() {
    // needs to rotate based on vel.heading
  }
}

/*GUN*/
class Gun {
  PImage sprite;
  String bulletSpritePath;
  int bulletDamageAmount;
  float bulletSpeed;
  float cooldown;
  Cat owner;
  Gun(String gunName) {
    switch (gunName) {
      case "gun1" :  // pistol
        sprite = loadImage("sprites/gun1.png");
        bulletSpritePath = "sprites/bullet1.png";
        bulletDamageAmount = 10;
        bulletSpeed = 12;
        cooldown = 0.5;
      case "gun2" :  // rifle
        sprite = loadImage("sprites/gun2.png");
        bulletSpritePath = "bullet2.png";
        bulletSpeed = 12;
        bulletDamageAmount = 6;
        cooldown = 0.2;
    }
  }
  void setOwner(Cat cat) {
    owner = cat;
  }
  void shoot() {
    Bullet b = new Bullet(owner.pos.x, owner.pos.y);
    b.vel.setMag(bulletSpeed);
    
  }
  void display(){}
}

class Wall {
  PVector topLeft;
  PVector bottomRight;
  
}

/*===RAHHHH===*/

/*===HANDLERS===*/
void handleCats() {
  for (Cat cat : cats) {
    cat.move();
    cat.display();
    // add: check health to die
  }
  
  // graveyard
  for (Cat cat : catsToKill) {cats.remove(cat);}
  catsToKill.clear();
}

void handleBullets() {
  for (Bullet bullet : bullets) {
    bullet.move();
    bullet.display();
  }
  
  // graveyard
  for (Bullet bullet : bulletsToKill) {bullets.remove(bullet);}
  bulletsToKill.clear();
}

/*===KEYBOARD===*/
void keyReleased() {
  //switch (key) {
  //  case '=' :
  //    break;
  //  case 'w' :
  //    break;
  //}
}






/*
List of classes:
Entity
- pos, vel, acc
- sprite
- hitbox size (vector of width,height)
- 



*/
