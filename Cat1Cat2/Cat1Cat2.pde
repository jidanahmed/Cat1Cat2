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
int CAT_SPEED = 8;
float GUN_ROTATION_SPEED = 0.03;
PVector GRAVITY = new PVector(0,0.4);
PVector JUMP_VEL = new PVector(0,-15);
int TERM_VEL_VAL = 30;


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
  windowMove(600,100);
  
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
  
  // initialize walls
  // TODO: ADD LOADING WALLS FROM SAVE FILE
  walls.add(new Wall(800,800,700,700));
}

void tickGame() {
  background(255);  // TODO change this to changing background color, make nice structure for how the color works
  handleCats();
  handleBullets();
  handleWalls();
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
    size = new PVector(30,12);  // TODO defalult cat size catwidthheight
  }
  void move() {
    vel.add(acc);
    if (vel.y > TERM_VEL_VAL) {vel.y = TERM_VEL_VAL;}
    pos.add(vel);
  }
  void applyForce(PVector force) {
    acc.add(force);
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
  
  boolean onGround;
  
  Cat(int x, int y) {
    super(x,y);
    health = 100;
    onGround = false;
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
      
      rect(0,0,size.x,size.y);  // represents hitbox?
      image(sprite,0,0,size.x,size.y);
  
      rotate(angle-0.15);
      image(gunSprite,75,25,100,50);
      
      // rotate gun
      //angle += GUN_ROTATION_SPEED;
      if (! onGround) {angle = vel.heading();}
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
  void handleCollisions(){
    for (Wall wall : walls) {
      float left   = pos.x - size.x / 2;
      float right  = pos.x + size.x / 2;
      float top    = pos.y - size.y / 2;
      float bottom = pos.y + size.y / 2;
          
      boolean isColliding =
        right > wall.left &&
        left < wall.right &&
        bottom > wall.top &&
        top < wall.bottom;
          
      if (isColliding) {
        float overlapX = Math.min(right, wall.right) - Math.max(left, wall.left);
        float overlapY = Math.min(bottom, wall.bottom) - Math.max(top, wall.top);
        
        if (overlapX < overlapY) { // Resolve on X axis
          if (pos.x < (wall.left + wall.right) / 2) {
            pos.x -= overlapX;
          } else {
            pos.x += overlapX;
          }
          vel.x = 0;
        }
        else { // Resolve on Y axis
          if (pos.y < (wall.top + wall.bottom) / 2) {
            pos.y -= overlapY;
            onGround = true;
          }
          else {
            pos.y += overlapY;
          }
          vel.y = 0;
        }
      }
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
      rect(0,0,size.x,size.y);  // represents hitbox?
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
  float top;
  float bottom;
  float left;
  float right;
  
  Wall(float x1, float y1, float x2, float y2) {
    left = Math.min(x1,x2);
    right = Math.max(x1,x2);
    top = Math.min(y1,y2);
    bottom = Math.max(y1,y2);
  }
  
  void display() {
    pushStyle();
    rectMode(CORNERS);
    fill(100,255,255);
    rect(left,top,right,bottom);
    popStyle();
  }
}

// TODO class Button

/*===RAHHHH===*/

/*===HANDLERS===*/
void handleCats() {
  for (Cat cat : cats) {
    if (cat.health <= 0) {catsToKill.add(cat);}
    if (cat.pos.y>height) {cat.applyForce(GRAVITY.copy().mult(-4));}  //TEST

    cat.onGround = false;
    cat.handleCollisions();
    if (! cat.onGround) {cat.applyForce(GRAVITY);}
    cat.display();
    cat.move();
    cat.acc = new PVector();
    
  }
  
  // graveyard
  for (Cat cat : catsToKill) {cats.remove(cat);}
  catsToKill.clear();
}

void handleBullets() {
  for (Bullet bullet : bullets) {
    bullet.move();
    bullet.display();
    if (bullet.bouncesLeft <= 0) {bulletsToKill.add(bullet);}
  }
  
  // graveyard
  for (Bullet bullet : bulletsToKill) {bullets.remove(bullet);}
  bulletsToKill.clear();
}

void handleWalls() {
  for (Wall wall : walls) {
    wall.display();
  }
}

void handleKeyboardMovement() {
  player1.vel.x = 0;
  player2.vel.x = 0;
  
  if (keys[0]) { player1.angle = 3*HALF_PI; 
    if (player1.onGround){ player1.vel.y = JUMP_VEL.y; }}
  if (keys[1]) { player1.angle = PI; player1.vel.x = velLeft.x; }
  if (keys[2]) { player1.angle = HALF_PI; }
  if (keys[3]) { player1.angle = 0; player1.vel.x = velRight.x; }
  if (keys[0] && keys[1]) { player1.angle = 5*QUARTER_PI; }
  if (keys[1] && keys[2]) { player1.angle = 3*QUARTER_PI; }
  if (keys[2] && keys[3]) { player1.angle = QUARTER_PI; }
  if (keys[3] && keys[0]) { player1.angle = 7*QUARTER_PI; }
  if (keys[4]) { player1.shoot(); }
  
  if (keys[5]) { player2.angle = 3*HALF_PI;
    if (player2.onGround){ player2.vel.y = JUMP_VEL.y; }}
  if (keys[6]) { player2.angle = PI; player2.vel.x = velLeft.x; }
  if (keys[7]) { player2.angle = HALF_PI; }
  if (keys[8]) { player2.angle = 0; player2.vel.x = velRight.x; }
  if (keys[5] && keys[6]) { player2.angle = 5*QUARTER_PI; }
  if (keys[6] && keys[7]) { player2.angle = 3*QUARTER_PI; }
  if (keys[7] && keys[8]) { player2.angle = QUARTER_PI; }
  if (keys[8] && keys[5]) { player2.angle = 7*QUARTER_PI; }
  if (keys[9]) { player2.shoot(); }
  
  //if (keys[0]) { player1.vel.y = velUp.y; player1.angle = 3*HALF_PI; }  // remove during gravity implementation
  //if (keys[1]) { player1.vel.x = velLeft.x; player1.angle = PI; }
  //if (keys[2]) { player1.vel.y = velDown.y; player1.angle = HALF_PI; }  // remove during gravity implementation
  //if (keys[3]) { player1.vel.x = velRight.x; player1.angle = 0; }
  //if (keys[0] && keys[1]) { player1.vel = velUpLeft; player1.angle = 5*QUARTER_PI; }
  //if (keys[1] && keys[2]) { player1.vel = velDownLeft; player1.angle = 3*QUARTER_PI; }
  //if (keys[2] && keys[3]) { player1.vel = velDownRight; player1.angle = QUARTER_PI; }
  //if (keys[3] && keys[0]) { player1.vel = velUpRight; player1.angle = 7*QUARTER_PI; }
  //if (keys[4]) { player1.shoot(); }
  
  //if (keys[5]) { player2.vel = velUp; }
  //if (keys[6]) { player2.vel = velLeft; }
  //if (keys[7]) { player2.vel = velDown; }
  //if (keys[8]) { player2.vel = velRight; }
  //if (keys[5] && keys[6]) { player2.vel = velUpLeft; }
  //if (keys[6] && keys[7]) { player2.vel = velDownLeft; }
  //if (keys[7] && keys[8]) { player2.vel = velDownRight; }
  //if (keys[8] && keys[5]) { player2.vel = velUpRight; }
  //if (keys[9]) { player2.shoot(); }
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
5/13/25

rewriting all these notes

bare minimum
shoot bullet, bullet hurts cat, cat dies
gravity
walls and platforms
proper wall collision


Plans:
new classes: button, more walls like destructible walls, let cats build temporary walls, 
map select screen with map previews when hover over
main menu screen
name input option
character select screen
*/

void printTests() {
  //System.out.println();

}
