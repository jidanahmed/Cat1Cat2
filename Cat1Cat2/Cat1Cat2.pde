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
ArrayList<Wall> walls = new ArrayList<Wall>();
ArrayList<Wall> wallsToKill = new ArrayList<Wall>();

/*===CONSTANTS===*/
int CAT_SPEED = 5;
float GUN_ROTATION_SPEED = 0.03;

PVector velUp = new PVector(0,-CAT_SPEED);
PVector velDown = new PVector(0,CAT_SPEED);
PVector velLeft = new PVector(-CAT_SPEED,0);
PVector velRight = new PVector(CAT_SPEED,0);
PVector velUpRight = new PVector(CAT_SPEED,-CAT_SPEED);
PVector velDownRight = new PVector(CAT_SPEED,CAT_SPEED);
PVector velDownLeft = new PVector(-CAT_SPEED,CAT_SPEED);
PVector velUpLeft = new PVector(-CAT_SPEED,-CAT_SPEED);

/*===DEFAULT OBJECTS===*/
PImage defaultSprite;
// players
PImage player1Sprite;
PImage player2Sprite;
//guns
PImage gun1Sprite;
PImage gun2Sprite;
//bullets
PImage bullet1Sprite;
PImage bullet2Sprite;

// player objects
Cat player1;
Cat player2;

/*===SETUP===*/
void setup() {
  // set up window
  windowTitle("Cat1Cat2");
  windowResize(displayWidth, displayHeight);
  windowMove(500,400);
  
  // load images
  defaultSprite = loadImage("sprites/default.png");
  // players
  player1Sprite = loadImage("sprites/player1.png");
  player2Sprite = loadImage("sprites/player2.png");
  // guns
  gun1Sprite = loadImage("sprites/gun1.png");
  gun2Sprite = loadImage("sprites/gun2.png");
  // bullets
  bullet1Sprite = loadImage("sprites/bullet1.png");
  bullet2Sprite = loadImage("sprites/bullet2.png");
  
  // sets up game
  resetGame();
  
}

void resetGame() {
  cats.clear();
  bullets.clear();
  
  // initialize players
  player1 = new Cat(width/3,height/2);  // starting location
  player1.sprite = player1Sprite;
  player2 = new Cat(2*width/3,height/2);
  player2.sprite = player2Sprite;
  
  cats.add(player1);
  cats.add(player2);
}

void tickGame() {
  background(255);  // TODO change this to changing background color, make nice structure for how the color works
  handleCats();
  handleBullets();
  handleKeyboardMovement();
  // TODO add ui updating (health and score and stuff)
}

void draw() {

  // TODO add switch later for different screens
  tickGame();
  
  printTests();
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
    size = new PVector(120,120);
  }
  void move() {
    pos.add(vel);
  }
}

/*CAT*/
class Cat extends Entity {
  int health;
  long lastShot;
  float angle;
  // these following variables are updated based on the gun you use
  
  PImage gunSprite;
  float reloadTime;
  String bulletName;
  int bulletBounces;
  
  Cat(int x, int y) {
    super(x,y);
    health = 100;
    setGun("gun1");
  }
  void move() {
    super.move();
    // add collisions
  }
  void display() {
    pushStyle();
    pushMatrix();
      imageMode(CENTER);
      rectMode(CENTER);
      translate(pos.x,pos.y);
      
      ellipse(0,0,size.x,size.y);  // represents hitbox?
      image(sprite,0,0,size.x,size.y);
  
      rotate(angle-0.15);
      image(gunSprite,75,25,100,50);
      
      // rotate gun
      angle += GUN_ROTATION_SPEED;
      if (angle > TWO_PI) {angle = 0;}
    popMatrix();
    popStyle();
  }
  void shoot() {
    if (millis() - lastShot > reloadTime*1000) {
      Bullet b = new Bullet(bulletName, this);
      angle-=PI/16;
      lastShot = millis();
      bullets.add(b);
    }
  }
  void setGun(String gunName) {
    switch (gunName) {
      case "gun1" :
        gunSprite = gun1Sprite;
        reloadTime = 0.5;
        bulletName = "bullet1";
        bulletBounces = 3;
        break;
      case "gun2" :
        gunSprite = gun2Sprite;
        reloadTime = 2;
        bulletName = "bullet2";
        bulletBounces = 6;
        break;
    }
  }
}

/*BULLET*/
class Bullet extends Entity {
  Cat owner;
  int damageAmount;
  int bouncesLeft;
  float angle;
  
  Bullet(String bulletName, Cat owner) {
    super((float)(owner.pos.x+130 * Math.cos(owner.angle)), (float)(owner.pos.y+130 * Math.sin(owner.angle)));
    this.owner = owner;
    sprite = defaultSprite;
    angle = owner.angle;
    
    vel.set(new PVector(1,0));
    vel.rotate(angle);
    
    switch (bulletName) {
      case "bullet1":
        vel.setMag(12);
        damageAmount = 1;
        bouncesLeft = 3;
        sprite = bullet1Sprite;
        size = new PVector(50,20);
        break;
      case "bullet2":
        vel.setMag(300);
        damageAmount = 2;
        bouncesLeft = 6;
        sprite = bullet2Sprite;
        size = new PVector(100,20);
        break;
    }
  }
  void setOwner(Cat cat){
    owner = cat;
  }
  
  void display() {
    pushMatrix();
    pushStyle();
      if (owner == player1) {tint(255,0,0);}  // tint red
      if (owner == player2) {tint(0,0,255);}  // tint blue
      
      translate(pos.x,pos.y);
      imageMode(CENTER);
      rectMode(CENTER);
      
      rotate(angle);
      ellipse(0,0,size.x,size.y);  // represents hitbox?
      image(sprite,0,0,size.x,size.y);
      
    popStyle();
    popMatrix();

  }
  
  void hurtCat(Cat cat) {  // TODO: maybe delete this function and just put in bullet handler code
    cat.health -= damageAmount;
  }
  
  // TODO add bullet bounces
  void bounceX(){}
  void bounceY(){}
}

class Wall {
  PVector topLeft;
  PVector bottomRight;
  
}

// TODO class Button

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

void handleKeyboardMovement() {
  player1.vel = new PVector();
  player2.vel = new PVector();

  if (keys[0]) { player1.vel = velUp; player1.angle = 3*HALF_PI; }  // remove during gravity implementation
  if (keys[1]) { player1.vel = velLeft; player1.angle = PI; }
  if (keys[2]) { player1.vel = velDown; player1.angle = HALF_PI; }  // remove during gravity implementation
  if (keys[3]) { player1.vel = velRight; player1.angle = 0; }
  if (keys[0] && keys[1]) { player1.vel = velUpLeft; player1.angle = 5*QUARTER_PI; }
  if (keys[1] && keys[2]) { player1.vel = velDownLeft; player1.angle = 3*QUARTER_PI; }
  if (keys[2] && keys[3]) { player1.vel = velDownRight; player1.angle = QUARTER_PI; }
  if (keys[3] && keys[0]) { player1.vel = velUpRight; player1.angle = 7*QUARTER_PI; }
  if (keys[4]) { player1.shoot(); }
  
  if (keys[5]) { player2.vel = velUp; }
  if (keys[6]) { player2.vel = velLeft; }
  if (keys[7]) { player2.vel = velDown; }
  if (keys[8]) { player2.vel = velRight; }
  if (keys[5] && keys[6]) { player2.vel = velUpLeft; }
  if (keys[6] && keys[7]) { player2.vel = velDownLeft; }
  if (keys[7] && keys[8]) { player2.vel = velDownRight; }
  if (keys[8] && keys[5]) { player2.vel = velUpRight; }
  if (keys[9]) { player2.shoot(); }
}
/*===KEYBOARD INTERPRETER===*/
boolean[] keys = new boolean[10];  // wasdxijkl,

void keyPressed() {
  setKeyPressed(key, true);
  // Pause Button
  
  // Map Selection TODO: make this only available on a map selection screen, add a button class.
}

void keyReleased() {
  setKeyPressed(key, false);
}

void setKeyPressed(char myKey, boolean isPressed) {  // SET CONTROLS HERE
  switch (myKey) {
    case 'w' :
      keys[0] = isPressed;
      break;
    case 'a' :
      keys[1] = isPressed;
      break;
    case 's' :
      keys[2] = isPressed;
      break;
    case 'd' :
      keys[3] = isPressed;
      break;
    case 'x' :
      keys[4] = isPressed;
      break;
    case 'i' :
      keys[5] = isPressed;
      break;
    case 'j' :
      keys[6] = isPressed;
      break;
    case 'k' :
      keys[7] = isPressed;
      break;
    case 'l' :
      keys[8] = isPressed;
      break;
    case ',' :
      keys[9] = isPressed;
      break;
  }
}



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

void printTests() {

}
