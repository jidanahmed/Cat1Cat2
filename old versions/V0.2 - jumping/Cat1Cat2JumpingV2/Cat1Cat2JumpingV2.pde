/*

TO DO:
add proper ui with faces and health, have them be on top of walls

flip gun and cat when facing backwards (no more upside down gun)

add proper main menu screen

add buttons
*/

import java.util.ArrayList;  // the goat
import gifAnimation.*;

ArrayList<Cat> cats = new ArrayList<Cat>();
ArrayList<Bullet> bullets = new ArrayList<Bullet>();
ArrayList<Cat> catsToKill = new ArrayList<Cat>();
ArrayList<Bullet> bulletsToKill = new ArrayList<Bullet>();
ArrayList<Wall> walls = new ArrayList<Wall>();
ArrayList<Wall> wallsToKill = new ArrayList<Wall>();

// final variables used in calculations
final int CAT_SPEED = 5;  // 12 is good
final double ROTATION_SPEED = 0.1;  // 0.1 is good
final double GUN_COOLDOWN_SECONDS = 0.7;  // 0.1 is good
final int BULLET_SPEED = 18;  // 18 is good
final int BULLET_BOUNCES = 3;  // 3 is good
final int CAT_HITBOX_RADIUS = 40;
final int GRAVITY_STRENGTH = 10;
final int JUMP_DURATION = 100;

// keyboard controls
private char P1U = 'w';  // 0
private char P1L = 'a';  // 1
private char P1D = 's';  // 2
private char P1R = 'd';  // 3
private char P1S = 'x';  // 4
private char P1CW = 'g';  // 5
private char P1CCW = 'f';  // 6
private char P2U = 'i';  // 7
private char P2L = 'j';  // 8
private char P2D = 'k';  // 9
private char P2R = 'l';  // 10
private char P2S = ',';  // 11
private char P2CW = ']';  // 12
private char P2CCW = '[';  // 13
private char PAUSE = ' ';  // 14
private byte[] isPressed = new byte[15];  // uldr,shoot,cw,ccw
private char[] controls = new char[]{P1U,P1L,P1D,P1R,P1S,P1CW,P1CCW,P2U,P2L,P2D,P2R,P2S,P2CW,P2CCW};

private boolean mouseDown;

// explosion!!!
private Gif explosion;

// indicate main menu, pause, unpause
private int gameState;  // 0 = main menu, 1 = game, 2 = paused

// declare players
Cat player1;
Cat player2;

//===========================================================================================================================
//=====ENTITY CLASS=====
public class Entity {
  private int xPos, yPos, xVel, yVel;
  private PImage sprite;
  private double angle;
  
  // constructor
  Entity(int x, int y, String spritePath, double angle) {
    xPos = x;
    yPos = y;
    xVel = 0;
    yVel = 0;
    sprite = loadImage(spritePath);
    this.angle = angle;
  }
  
  // getters
  int getXPos() {
    return xPos;
  }
  int getYPos() {
    return yPos;
  }
  int getXVel() {
    return xVel;
  }
  int getYVel() {
    return yVel;
  }
  PImage getSprite() {
    return sprite;
  }
  double getAngle() {
    return angle;
  }

  // setters
  void setXPos(int newPos) {
    xPos = newPos;
  }
  void setYPos(int newPos) {
    yPos = newPos;
  }
  void setXVel(int newVel) {
    xVel = newVel;
  }
  void setYVel(int newVel) {
    yVel = newVel;
  }
  void setAngle(double newAngle) {
    angle = newAngle;
  }
  
  // methods
  double angleTo(int x, int y) {
    return Math.atan2((y-getYPos()),(x-getXPos()));
  }
  
  double distanceTo(Entity entity) {
    return Math.sqrt(Math.pow(getXPos()-entity.getXPos(),2) + Math.pow(getYPos()-entity.getYPos(),2));
  }
}

//===========================================================================================================================
//=====CAT CLASS=====
final class Cat extends Entity {
  private int health;
  private long lastShot;
  private PImage gunSprite;
  
  private int jumpFramesLeft;

  // constructor
  Cat(int x, int y, String spritePath, String gunPath, double angle) {
    super(x, y, spritePath, angle);
    health = 100;
    lastShot = (long) (-1000 * GUN_COOLDOWN_SECONDS);
    gunSprite = loadImage(gunPath);
    jumpFramesLeft = 0;
  }

  // getters
  int getHealth() {
    return health;
  }
  long getLastShot() {
    return lastShot;
  }
  PImage getGunSprite() {
    return gunSprite;
  }
  int getJumpFramesLeft() {
    return jumpFramesLeft;
  }

  // setters
  void setLastShot(long newTime) {
    lastShot = newTime;
  }
  void setJumpFramesLeft(int j) {
    jumpFramesLeft = j;
  }

  // methods
  void takeDamage(int damage) {
    health -= damage;
    if (health<0) {
      health=0;
    }
  }
  void shoot() {
    if (millis() - getLastShot() > GUN_COOLDOWN_SECONDS*1000) {  // cooldown
      spawn(new Bullet(getXPos()+10*(int)Math.cos(getAngle()), getYPos()+10*(int)Math.sin(getAngle()), "bullet1.png", getAngle(), this));
      setLastShot(millis());
    }
  }
  void shoot(int x, int y) {  // variant of shoot that aims at a coordinate
    if (millis() - getLastShot() > GUN_COOLDOWN_SECONDS*1000) {  // cooldown
      spawn(new Bullet(getXPos(), getYPos(), "bullet1.png", angleTo(x,y), this));
      setLastShot(millis());
    }
  }
  void jump() {
     setJumpFramesLeft(JUMP_DURATION);
  }
}

//===========================================================================================================================
//=====BULLET CLASS=====
final class Bullet extends Entity {
  private int bounces;
  private int speed;
  private Cat owner;

  // constructor
  Bullet(int x, int y, String spritePath, double angle, Cat owner) {
    super(x, y, spritePath, angle);
    setAngle(angle);
    bounces = BULLET_BOUNCES;
    speed = BULLET_SPEED;
    setXVel((int) (Math.cos(angle) * speed));
    setYVel((int) (Math.sin(angle) * speed));
    this.owner = owner;
  }

  // getters
  int getBounces() {
    return bounces;
  }
  int getSpeed() {
    return speed;
  }
  Cat getOwner() {
    return owner;
  }

  // methods
  void hurt(Cat cat) {
    cat.takeDamage(10);
  }
  void bounceX() {
    setXVel(-1 * getXVel());
    setAngle(PI - getAngle());
    bounces--;
  }
  void bounceY() {
    setYVel(-1 * getYVel());
    setAngle(-1 * getAngle());
    bounces--;
  }
}

//===========================================================================================================================
//=====WALL CLASS=====
final class Wall {
  // top,bottom,left,right,color
  private int topY;
  private int bottomY;
  private int leftX;
  private int rightX;
  private PImage texture;
  
  // constructors
  Wall(int u, int d, int l, int r, String texturePath) {
    topY = u;
    bottomY = d;
    leftX = l;
    rightX = r;
    texture = loadImage(texturePath);
  }
  
  // getters
  int getTopY() {
    return topY;
  }
  int getBottomY() {
    return bottomY;
  }
  int getLeftX() {
    return leftX;
  }
  int getRightX() {
    return rightX;
  }
  PImage getTexture() {
    return texture;
  }
  
  // setters
  
  // methods
}
  
//===========================================================================================================================
//=====SPAWN METHODS=====
void spawn(Cat myCat) { cats.add(myCat); }
void spawn(Bullet myBullet) { bullets.add(myBullet); }
void buildWall(int u, int d, int l, int r) {
  walls.add(new Wall(u,d,l,r,"cobblestone.png"));
}

//===========================================================================================================================
//=====RENDER METHODS=====
void renderEntity(Cat cat) {
  // cat
  image(cat.getSprite(), cat.getXPos(), cat.getYPos(), 100, 100);       // draw centered at new origin
  // gun
  pushMatrix();
  translate(cat.getXPos(), cat.getYPos());        // move origin to gun center
  rotate((float) cat.getAngle()-0.2);             // rotate the gun
  image(cat.getGunSprite(), 15, 15, 100, 50);       // draw centered at new origin
  popMatrix();                                    // reset transformation
}
void renderEntity(Bullet bullet) {
  pushMatrix();
  translate(bullet.getXPos(), bullet.getYPos()); // move origin to bullet center
  rotate((float) bullet.getAngle());             // rotate the bullet
  image(bullet.getSprite(), 0, 0, 24, 12);       // draw centered at new origin
  popMatrix();                                    // reset transformation
}
// wall does not need a render method because it is so simple!

//===========================================================================================================================
//=====HANDLERS=====
void handleBullets() {
  for (Bullet bullet : bullets) {
    // rendering
    renderEntity(bullet);
    // movement physics
    bullet.setXPos(bullet.getXPos()+bullet.getXVel());
    bullet.setYPos(bullet.getYPos()+bullet.getYVel());
    // bounce logic
    if (bullet.getXPos()-BULLET_SPEED<=0 || bullet.getXPos()+BULLET_SPEED>=width) {bullet.bounceX();}
    if (bullet.getYPos()-BULLET_SPEED<=0 || bullet.getYPos()+BULLET_SPEED>=height) {bullet.bounceY();}
    
    // wall bounces
    if (isInWall(bullet.getXPos()-BULLET_SPEED, bullet.getYPos()) || isInWall(bullet.getXPos()+BULLET_SPEED, bullet.getYPos())) {bullet.bounceX();}
    if (isInWall(bullet.getXPos(), bullet.getYPos()-BULLET_SPEED) || isInWall(bullet.getXPos(), bullet.getYPos()+BULLET_SPEED)) {bullet.bounceY();}
    
    // hurt cat logic
    for (Cat cat : cats) {
      if (bullet.distanceTo(cat) < CAT_HITBOX_RADIUS && bullet.getOwner() != cat) {
        bullet.hurt(cat);
        bulletsToKill.add(bullet);
      }
    }
    
    // death conditions
    if (bullet.getXPos()<0 || bullet.getXPos()>width || bullet.getYPos()<0 || bullet.getYPos()>height) {bulletsToKill.add(bullet);}
    if (bullet.getBounces() <= 0) {bulletsToKill.add(bullet);}
  }
  
  // graveyard
  for (Bullet bullet : bulletsToKill) {
    bullets.remove(bullet);
  }
  bulletsToKill.clear();  // might as well save on space
}

void handleCats() {
  for (Cat cat : cats) {
    
      System.out.println("\nyvel " + cat.getYVel());
      System.out.println("jumpFr " + cat.getJumpFramesLeft());
    // rendering
    renderEntity(cat);
    // movement physics
    cat.setYVel(cat.getYVel()+GRAVITY_STRENGTH);
    if (isInWall(cat.getXPos() + ((cat.getXVel()<0)?-1:1)*CAT_HITBOX_RADIUS + cat.getXVel(),cat.getYPos())){  // x collision
      cat.setXVel(0);
    }
    if (isInWall(cat.getXPos(),cat.getYPos() + ((cat.getYVel()<0)?-1:1)*CAT_HITBOX_RADIUS + cat.getYVel())){  // y collision
       cat.setYVel(0);
    }
    if (cat.getJumpFramesLeft() > 0) {  // jump physics
      if (isInWall(cat.getXPos(),cat.getYPos() + ((cat.getYVel()<0)?-1:1)*CAT_HITBOX_RADIUS + cat.getYVel())){  // y collision
       cat.setYVel(0);
      }
      cat.setYVel(cat.getYVel()-cat.jumpFramesLeft/5);
      cat.setJumpFramesLeft(cat.getJumpFramesLeft()-1);
    }
    else {
      cat.setJumpFramesLeft(0);
    }
    
    cat.setXPos(cat.getXPos()+cat.getXVel());
    cat.setYPos(cat.getYPos()+cat.getYVel());

    // death conditions
    if (cat.getXPos()<0 || cat.getXPos()>width || cat.getYPos()<0 || cat.getYPos()>height) {cat.takeDamage(cat.getHealth());}
    if (cat.getHealth() <= 0) { catsToKill.add(cat); }
  }
  // graveyard
  for (Cat cat : catsToKill) {
    // explosion gif and sound
    explode(cat);
    cats.remove(cat);
  }
  catsToKill.clear();  // might as well save on space
}

void handleWalls(){
  for (int i = 0; i < walls.size(); i++) {
    // rendering
    //imageMode(CORNERS);
    //image(wall.getTexture(),wall.getLeftX(),wall.getTopY(),wall.getRightX(),wall.getBottomY());
    rectMode(CORNERS);
    fill(color(hueValue, 255, 150));
    stroke(color(hueValue, 255, 150));
    rect(walls.get(i).getLeftX(),walls.get(i).getTopY(),walls.get(i).getRightX(),walls.get(i).getBottomY());
    //imageMode(CENTER);
    if (mouseDown) {
      noFill();
      rect(wallBuilderLeft,wallBuilderTop,mouseX,mouseY);
    }
    //imageMode(CENTER);
    rectMode(CENTER);
    
    // graveyard
    for (Wall wall : wallsToKill) {
      // explosion gif and sound
      walls.remove(wall);
    }
    wallsToKill.clear();  // might as well save on space
    }
}

// helper method
boolean isInWall(int x, int y) {
  for (Wall wall : walls) {
    if (x>=wall.getLeftX() && x<=wall.getRightX() && y>=wall.getTopY() && y<=wall.getBottomY()){ return true; }
  }
  return false;
}
void removeWallAt(int x, int y) {
  for (Wall wall : walls) {
    if (x>=wall.getLeftX() && x<=wall.getRightX() && y>=wall.getTopY() && y<=wall.getBottomY()){ wallsToKill.add(wall); }
  }
}
 
//===========================================================================================================================
//=====HANDLE KEYPRESSES=====
// update isPressed
void keyPressed() {
  for (int i = 0; i<controls.length; i++) {
    if (key == controls[i]) {isPressed[i] = 1;}
    if (key == controls[0]) {player1.jump();}
    if (key == controls[7]) {player2.jump();}
  }
}

void keyReleased() {for (int i = 0; i<controls.length; i++) {if (key == controls[i]) {isPressed[i] = 0;}}  if(key==PAUSE){gameState = ((gameState==2)?1:2);}}
void handleKeyboard() {
  // player1 wasda shoot
  player1.setYVel(0);
  player1.setXVel(0);
  if (isPressed[0]==1) {  // w    // using this for jumping instead
    //player1.setYVel(-CAT_SPEED);
    if (player1.getJumpFramesLeft()%5==0){  // this is just so it still decreases
      player1.setJumpFramesLeft(player1.getJumpFramesLeft()+1);  // holding up extends air time
    }
    player1.setAngle(-PI/2);
  }
  if (isPressed[1]==1 && !(isPressed[0]==1 || isPressed[2]==1)) {  // a
    player1.setXVel(-CAT_SPEED);  
    player1.setAngle(PI);
  }
  if (isPressed[2]==1 && !(isPressed[1]==1 || isPressed[3]==1)) {  // s
    player1.setYVel(CAT_SPEED);  
    player1.setAngle(PI/2);
  }
  if (isPressed[3]==1 && !(isPressed[0]==1 || isPressed[2]==1)) {  // d
    player1.setXVel(CAT_SPEED);  
    player1.setAngle(0);
  }
  if (isPressed[0]==1 && isPressed[1]==1) {  // wa
    //player1.setYVel(-CAT_SPEED);
    player1.setXVel(-CAT_SPEED);
    player1.setAngle(-3*PI/4);
  }
  if (isPressed[1]==1 && isPressed[2]==1) {  // as
    player1.setXVel(-CAT_SPEED);  
    player1.setYVel(CAT_SPEED);  
    player1.setAngle(3*PI/4);
  }
  if (isPressed[2]==1 && isPressed[3]==1) {  // sd
    player1.setYVel(CAT_SPEED);  
    player1.setXVel(CAT_SPEED);  
    player1.setAngle(PI/4);
  }
  if (isPressed[3]==1 && isPressed[0]==1) {  // dw
    player1.setXVel(CAT_SPEED);  
    //player1.setYVel(-CAT_SPEED);  
    player1.setAngle(-PI/4);
  }
  if (isPressed[4] == 1 && player1.getHealth()>0) {player1.shoot();}  // x
  // ROTATION SYSTEM TURNED OFF FOR NOW.
  //if (isPressed[5] == 1) {player1.setAngle(player1.getAngle()+ROTATION_SPEED);}  // f
  //if (isPressed[6] == 1) {player1.setAngle(player1.getAngle()-ROTATION_SPEED);}  // g
  
  // player2 ijkl shoot
  player2.setYVel(0);
  player2.setXVel(0);
  if (isPressed[7]==1) {  // i  // using i for jump instead
    //player2.setYVel(-CAT_SPEED);  
    player2.setJumpFramesLeft(player2.getJumpFramesLeft()+1);  // holding up extends air time
    player2.setAngle(-PI/2);
  }
  if (isPressed[8]==1 && !(isPressed[7]==1 || isPressed[9]==1)) {  // j
    player2.setXVel(-CAT_SPEED);  
    player2.setAngle(PI);
  }
  if (isPressed[9]==1 && !(isPressed[8]==1 || isPressed[10]==1)) {  // k
    player2.setYVel(CAT_SPEED);  
    player2.setAngle(PI/2);
  }
  if (isPressed[10]==1 && !(isPressed[7]==1 || isPressed[9]==1)) {  // l
    player2.setXVel(CAT_SPEED);  
    player2.setAngle(0);
  }
  if (isPressed[7]==1 && isPressed[8]==1) {  // ij
    //player2.setYVel(-CAT_SPEED);
    player2.setXVel(-CAT_SPEED);
    player2.setAngle(-3*PI/4);
  }
  if (isPressed[8]==1 && isPressed[9]==1) {  // jk
    player2.setXVel(-CAT_SPEED);  
    player2.setYVel(CAT_SPEED);  
    player2.setAngle(3*PI/4);
  }
  if (isPressed[9]==1 && isPressed[10]==1) {  // kl
    player2.setYVel(CAT_SPEED);  
    player2.setXVel(CAT_SPEED);  
    player2.setAngle(PI/4);
  }
  if (isPressed[10]==1 && isPressed[7]==1) {  // li
    player2.setXVel(CAT_SPEED);  
    //player2.setYVel(-CAT_SPEED);  
    player2.setAngle(-PI/4);
  }
  if (isPressed[11] == 1 && player2.getHealth()>0) {player2.shoot();}  // ;
  // ROTATION SYSTEM TURNED OFF FOR NOW.
  //if (isPressed[12] == 1) {player2.setAngle(player2.getAngle()+ROTATION_SPEED);}  // [
  //if (isPressed[13] == 1) {player2.setAngle(player2.getAngle()-ROTATION_SPEED);}  // ]
  
}


//===========================================================================================================================
//=====EXPLODE!!! (idk. FIX THIS METHOD LATER)=====
int explosionX = 0;
int explosionY = 0;
void explode(Entity entity) {
  explosionX = entity.getXPos();
  explosionY = entity.getYPos();
}

void handleExplosions(){
  //while (explosion.isPlaying()) {
  //  image(explosion,explosionX,explosionY,200,200);
  //}
}


//===========================================================================================================================
void startGame(){
  spawn(new Cat(width/8, height/3, "player1.png", "gun1.png", 0));
  spawn(new Cat(7*width/8, 2*height/3, "player2.png", "gun1.png", PI));
  player1 = cats.get(0);
  player2 = cats.get(1);
  
  // draw walls
  buildWall(0,50,0,width);
  buildWall(height-100,height,0,width);
  buildWall(0,height,0,50);
  buildWall(0,height,width-50,width);
  
  // start game
  gameState = 1;  // unpaused
}

float hueValue = 0;
// draw background, healths, 
void drawBackground(){
  // rainbow background
  background(color(hueValue, 50, 255));
  hueValue += 0.05;
  if (hueValue > 255) {hueValue = 0;}
  // healths ()
  fill(hueValue,255,50);
  textSize(104); 
  text(player1.getHealth(), width/3, 4*height/5);
  text(player2.getHealth(), 2*width/3, 4*height/5);  // text only for now, get health bars later
}

void drawMainMenu(){
  // title screen
}

void drawGame() {
  drawBackground();
  handleWalls();
  handleCats();
  handleBullets();
  handleKeyboard();
  handleExplosions();
}

void drawPauseScreen() {
  // draw buttons
  fill(100, 15);
  rect(width/2,height/2,width,height);
  fill(255);
  text("PAUSED",width/2,height/2);
}



//===========================================================================================================================
void setup() {
  size(1600, 1000);
  imageMode(CENTER);
  rectMode(CENTER);
  colorMode(HSB, 255); 
  textAlign(CENTER);
  explosion = new Gif(this, "explosion.gif");
  explosion.play();
  
  startGame();
}

void draw() {
  switch (gameState) {
    case 0:
      drawMainMenu();
      break;
    case 1:
      drawGame();
      break;
    case 2:
      drawPauseScreen();
      break;
  }
  //explode(player1);  // not working
}


//===========================================================================================================================
int wallBuilderTop, wallBuilderBottom, wallBuilderLeft, wallBuilderRight;
void mousePressed() {
  if (isInWall(mouseX,mouseY)) {
    
  }
  else {
    mouseDown = true;
    wallBuilderTop = mouseY;
    wallBuilderLeft = mouseX;
  }
}

void mouseReleased(){
  mouseDown = false;
  if (isInWall(mouseX,mouseY)) {
    removeWallAt(mouseX,mouseY);
  }
  else {
    wallBuilderBottom = mouseY;
    wallBuilderRight = mouseX;
    if (wallBuilderTop != wallBuilderBottom && wallBuilderLeft != wallBuilderRight){
       buildWall(Math.min(wallBuilderTop,wallBuilderBottom),Math.max(wallBuilderTop,wallBuilderBottom),Math.min(wallBuilderLeft,wallBuilderRight),Math.max(wallBuilderLeft,wallBuilderRight));
    }
  }

}
