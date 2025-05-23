/*

TO DO:
flip gun when facing backwards (no more upside down gun)

implement bullets hurting cats and disappearing when they do

implement wall class with cat and bullet collision
  wall owns topY, bottomY, leftX, rightX
  constructor uses these to make a rectangle
  
  in handle for cats and bullets, have them loop through all walls
  bullets check left and right like they do for width and height
  
  
add in walls with a construct walls method

*/




import java.util.ArrayList;  // the goat
import gifAnimation.*;  // explode!!!

ArrayList<Cat> cats = new ArrayList<Cat>();
ArrayList<Bullet> bullets = new ArrayList<Bullet>();
ArrayList<Cat> catsToKill = new ArrayList<Cat>();
ArrayList<Bullet> bulletsToKill = new ArrayList<Bullet>();

final double GUN_COOLDOWN_SECONDS = 0.7;  // 0.1 is good
final int BULLET_BOUNCES = 3;  // 3 is good
final int BULLET_SPEED = 18;  // 18 is good
final int CAT_SPEED = 5;  // 12 is good
final int CAT_HITBOX_RADIUS = 40;
final double ROTATION_SPEED = 0.1;  // 0.1 is good
private byte[] isPressed = new byte[14];  // udlr,aimcw,aimccw,shoot , udlr,aimcw,aimccw,shoot, 7 controls each player
private char[] controls = new char[]{'w','a','s','d','g','f',' ','i','j','k','l',']','[',';'};

private Gif explosion; // explode!!!

private int gameState;  // 0 = main menu, 1 = game, 2 = paused

Cat player1;
Cat player2;

//===========================================================================================================================
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
final class Cat extends Entity {
  private int health;
  private long lastShot;
  private PImage gunSprite;

  // constructor
  Cat(int x, int y, String spritePath, String gunPath, double angle) {
    super(x, y, spritePath, angle);
    health = 100;
    lastShot = (long) (-1000 * GUN_COOLDOWN_SECONDS);
    gunSprite = loadImage(gunPath);
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

  // setters
  void setLastShot(long newTime) {
    lastShot = newTime;
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
}

//===========================================================================================================================
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
// spawn methods
void spawn(Cat myCat) { cats.add(myCat); }
void spawn(Bullet myBullet) { bullets.add(myBullet); }

//===========================================================================================================================
// render methods
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

//===========================================================================================================================
// handlers
void handleBullets() {
  for (Bullet bullet : bullets) {
    // rendering
    renderEntity(bullet);
    // movement
    bullet.setXPos(bullet.getXPos()+bullet.getXVel());
    bullet.setYPos(bullet.getYPos()+bullet.getYVel());
    // bounce logic
    if (bullet.getXPos()-BULLET_SPEED<=0 || bullet.getXPos()+BULLET_SPEED>=width) {bullet.bounceX();}
    if (bullet.getYPos()-BULLET_SPEED<=0 || bullet.getYPos()+BULLET_SPEED>=height) {bullet.bounceY();}
     // need to add stuff for walls

    // hurt logic
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
    // rendering
    renderEntity(cat);
    // movement
    cat.setXPos(cat.getXPos()+cat.getXVel());
    cat.setYPos(cat.getYPos()+cat.getYVel());
    // death conditions
    if (cat.getXPos()<0 || cat.getXPos()>width || cat.getYPos()<0 || cat.getYPos()>height) {catsToKill.add(cat);}
    if (cat.getHealth() <= 0) { catsToKill.add(cat); }
  }
  // graveyard
  for (Cat cat : catsToKill) {
    // explosion gif and sound
    image(explosion,cat.getXPos(),cat.getYPos(),200,200);
    cats.remove(cat);
  }
  catsToKill.clear();  // might as well save on space
}


//===========================================================================================================================
// handle keypresses
void keyPressed() {
  for (int i = 0; i<controls.length; i++) {
    if (key == controls[i]) {isPressed[i] = 1;}
  }
}
void keyReleased() {
  for (int i = 0; i<controls.length; i++) {
    if (key == controls[i]) {isPressed[i] = 0;}
  }
}
void handleKeyboard() {
  // player1 wasda
  player1.setYVel(0);
  player1.setXVel(0);
  if (isPressed[0]==1 && !(isPressed[1]==1 || isPressed[3]==1)) {  // w
    player1.setYVel(-CAT_SPEED);  
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
    player1.setYVel(-CAT_SPEED);
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
    player1.setYVel(-CAT_SPEED);  
    player1.setAngle(-PI/4);
  }
  //if (isPressed[4] == 1) {player1.setAngle(player1.getAngle()+ROTATION_SPEED);}  // f
  //if (isPressed[5] == 1) {player1.setAngle(player1.getAngle()-ROTATION_SPEED);}  // g
  // player1 shoot
  if (isPressed[6] == 1) {player1.shoot();}  // space
  
  player2.setYVel(0);
  player2.setXVel(0);
  if (isPressed[7]==1 && !(isPressed[8]==1 || isPressed[10]==1)) {  // i
    player2.setYVel(-CAT_SPEED);  
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
    player2.setYVel(-CAT_SPEED);
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
    player2.setYVel(-CAT_SPEED);  
    player2.setAngle(-PI/4);
  }
  //if (isPressed[4] == 1) {player2.setAngle(player2.getAngle()+ROTATION_SPEED);}  // [
  //if (isPressed[5] == 1) {player2.setAngle(player2.getAngle()-ROTATION_SPEED);}  // ]
  // player2 shoot
  if (isPressed[13] == 1) {player2.shoot();}  // ;
}


//===========================================================================================================================
void explode(Entity entity) {
  gameState = 2;  // pause
  image(explosion,entity.getXPos(),entity.getYPos(),200,200);
  delay(1);
  gameState = 1;  // unpause
}


//===========================================================================================================================
float hueValue = 0;
// draw background, healths, 
void drawUI(){
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

void startGame(){
  spawn(new Cat(width/3, height/3, "player1.png", "gun1.png", 0));
  spawn(new Cat(2*width/3, 2*height/3, "player2.png", "gun1.png", PI));
  player1 = cats.get(0);
  player2 = cats.get(1);
  gameState = 1;  // unpaused
  //explosion = new Gif(this, "explosion.gif");
}

void drawGame() {
  drawUI();
  handleCats();
  handleBullets();
  handleKeyboard();
}

void drawPauseScreen() {
  // draw buttons
  
}

//===========================================================================================================================
void setup() {
  size(1600, 1000);
  imageMode(CENTER);
  rectMode(CENTER);
  colorMode(HSB, 255); 
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

}






//===========================================================================================================================
