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
ArrayList<Button> buttons = new ArrayList<Button>();
ArrayList<Button> buttonsToKill = new ArrayList<Button>();

/*===CONSTANTS===*/
boolean debugMode = false;

final int MAIN_MENU_SCREEN = 0;
final int SELECT_SCREEN = 1;
final int GAME_SCREEN = 2;

// default screen
int screen;

final int CAT_SPEED = 8;
final float GUN_ROTATION_SPEED = 0.05;
final PVector GRAVITY = new PVector(0,0.8);
final PVector JUMP_VEL = new PVector(0,-18);
final int TERM_VEL_VAL = 30;
int DEFAULT_SPRITE_SIZE = 100;
final int COYOTE_TIME = 5;

final PVector velUp = new PVector(0,-CAT_SPEED);
final PVector velDown = new PVector(0,CAT_SPEED);
final PVector velLeft = new PVector(-CAT_SPEED,0);
final PVector velRight = new PVector(CAT_SPEED,0);
final PVector velUpRight = new PVector(CAT_SPEED,-CAT_SPEED);
final PVector velDownRight = new PVector(CAT_SPEED,CAT_SPEED);
final PVector velDownLeft = new PVector(-CAT_SPEED,CAT_SPEED);
final PVector velUpLeft = new PVector(-CAT_SPEED,-CAT_SPEED);

float hueValue = 0;

/*===DEFAULT OBJECTS===*/
Cat player1;
Cat player2;

/*===SPRITES===*/
PImage defaultSprite;

PImage player1Sprite;
PImage player2Sprite;

PImage gun1Sprite;
PImage gun2Sprite;

PImage bullet1Sprite;
PImage bullet2Sprite;

PImage mainMenuImage;


/*===WALL BUILDER===*/
boolean wallBuilderActive = false;
boolean mouseDown = false;
PVector wallBuilderCorner1;
PVector wallBuilderCorner2;

/*===BUTTONS===*/
//Button playButton = new Button("playButton",width*108/1710,height*149/1037 , width*437/1710,height*342/1037);
Button playButton = new Button("playButton",108,149 , 437,342);

/*===SETUP===*/
void setup() {
  // set up window
  windowTitle("Cat1Cat2");
  windowResize(displayWidth, displayHeight-75);
  windowMove(0,-100);
  
  // resize players
  DEFAULT_SPRITE_SIZE = displayWidth/20;
  
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
  
  // main menu
  mainMenuImage = loadImage("sprites/main_menu.png");
  
  // sets up game
  resetGame();
  
  setScreen(0);
  
}

void setScreen(int newScreen) {
  for (Button button : buttons) { buttonsToKill.add(button); } // clear buttons
  screen = newScreen;
  
  switch (newScreen) {
    case MAIN_MENU_SCREEN :
      buttons.add(playButton);
      break;
    case SELECT_SCREEN :
      //buttons.add(playButton);
      break;
  }
}

void resetGame() {
  cats.clear();
  bullets.clear();
  
  setupTest();
  
  // initialize players
  player1 = new Cat(width/3,height/2);  // starting location
  player1.sprite = player1Sprite;
  player2 = new Cat(2*width/3,height/2);
  player2.sprite = player2Sprite;
  
  cats.add(player1);
  cats.add(player2);
  
  // initialize walls
  loadMap("map1.txt");
  
  if (!debugMode) { noStroke(); }
}

void tickGame() {
  updateColor();
  handleCats();
  handleBullets();
  handleWalls();
  handleWallBuilder();
  handleKeyboardMovement();
  displayHealthBars();
  // TODO add ui updating (health and score and stuff)
}

void updateColor() {
  pushStyle();
  colorMode(HSB, 255);
  background(color(hueValue, 50, 255));
  hueValue += 0.05;
  if (hueValue > 255) {hueValue = 255-hueValue;}
  popStyle();
}

void displayHealthBars() {
  pushStyle(); pushMatrix(); rectMode(CORNERS);

  // player1 health
  fill(255,0,0); stroke(0); strokeWeight(4);
  rect(width/32,height/32,14*width/32,height/10);
  fill(0,255,0);
  rect(width/32,height/32,map(player1.health,0,100,width/32,14*width/32),height/10);

  
  //player 2 health
  fill(255,0,0);
  rect(width-width/32,height/32,width-(14*width/32),height/10);
  fill(0,255,0);
  rect(width-width/32,height/32,map(player2.health,0,100,width-width/32,width-(14*width/32)),height/10);
  
  popMatrix(); popStyle();
}

void tickMainMenu() {
  pushStyle();
  imageMode(CORNERS);
  image(mainMenuImage, 0, 0, width, height);
  
  handleButtons();
  popStyle();
}

void tickSelectScreen() {
  updateColor();
  fill(0);
  text("test select screen", 600, 600);
}

void draw() {

  // TODO add switch later for different screens
  switch (screen) {
    case MAIN_MENU_SCREEN :
      tickMainMenu();
      break;
    case SELECT_SCREEN :
      tickSelectScreen();
      break;
    case GAME_SCREEN :
      tickGame();
      break;
  }
  if (debugMode) {
    printTests();
  }
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
    size = new PVector(DEFAULT_SPRITE_SIZE,DEFAULT_SPRITE_SIZE);  // TODO defalult cat size catwidthheight
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
  boolean onGround;
  long timeAirborne;
  // these following variables are updated based on the gun you use
  
  PImage gunSprite;
  float reloadTime;
  String bulletName;
  int bulletBounces;
  
  Cat(int x, int y) {
    super(x,y);
    health = 100;
    onGround = false;
    timeAirborne = 0;
    setGun("gun1");
  }
  void display() {
    pushStyle();
    pushMatrix();
      imageMode(CENTER);
      rectMode(CENTER);
      translate(pos.x,pos.y);
      
      if (!debugMode) { noFill(); }
      rect(0,0,size.x,size.y);  // represents hitbox?
      image(sprite,0,0,size.x,size.y);
  
      rotate(angle-0.15);
      image(gunSprite,75,25,100,50);
      
      //// rotate gun
      //angle += GUN_ROTATION_SPEED;
      if (angle > TWO_PI) {angle = 0;}
      if (angle < 0) {angle = TWO_PI + angle;}

    popMatrix();
    popStyle();
  }
  void shoot() {
    if (health > 0) {
      if (millis() - lastShot > reloadTime*1000) {
        Bullet b = new Bullet(bulletName, this);
        //angle -= GUN_ROTATION_SPEED*40;  // recoil
        lastShot = millis();
        bullets.add(b);
      }
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
  void jump() {
    if (timeAirborne < COYOTE_TIME) { vel.y = JUMP_VEL.y; }
  }
  void handleCollisions(){
    timeAirborne++;
    
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
            timeAirborne = 0;  // resets time airborne
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
    super((float)(owner.pos.x+owner.size.x * Math.cos(owner.angle)), (float)(owner.pos.y+owner.size.x * Math.sin(owner.angle)));
    this.owner = owner;
    sprite = defaultSprite;
    angle = owner.angle;
    
    vel.set(new PVector(1,0));
    vel.rotate(angle);
    
    switch (bulletName) {
      case "bullet1":
        vel.setMag(12);
        damageAmount = 5;
        bouncesLeft = 3;
        sprite = bullet1Sprite;
        size = new PVector(50,20);
        break;
      case "bullet2":
        vel.setMag(300);
        damageAmount = 10;
        bouncesLeft = 6;
        sprite = bullet2Sprite;
        size = new PVector(100,20);
        break;
    }
  }
  void setOwner(Cat cat){
    owner = cat;
  }
  
  // bullet
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
          vel.x = -vel.x;  // bounce x
          angle = PI - angle;
          bouncesLeft--;
        }
        else { // Resolve on Y axis
          if (pos.y < (wall.top + wall.bottom) / 2) {
            pos.y -= overlapY;
          }
          else {
            pos.y += overlapY;
          }
          vel.y = -vel.y;  // bounce y
          angle = TWO_PI - angle;
          bouncesLeft--;
        }
      }
    }
    for (Cat cat : cats) {
      float left   = cat.pos.x - cat.size.x / 2;
      float right  = cat.pos.x + cat.size.x / 2;
      float top    = cat.pos.y - cat.size.y / 2;
      float bottom = cat.pos.y + cat.size.y / 2;
      
      if (pos.x > left && pos.x < right && pos.y > top && pos.y < bottom) {
        cat.health -= damageAmount;
        bulletsToKill.add(this);
      }
    }
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
      //rect(0,0,size.x,size.y);  // represents hitbox?
      image(sprite,0,0,size.x,size.y);
      
    popStyle();
    popMatrix();

  }
  
  void hurtCat(Cat cat) {  // TODO: maybe delete this function and just put in bullet handler code
    cat.health -= damageAmount;
  }
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
  
  void display() { // BLAH
    pushStyle();
    rectMode(CORNERS);
    colorMode(HSB,255);
    fill(color(hueValue, 255, 150));
    rect(left,top,right,bottom);
    popStyle();
  }
}

// TODO class Button
class Button {
  String name;
  float top;
  float bottom;
  float left;
  float right;
  boolean isHovered;

  Button(String n, float x1, float y1, float x2, float y2) {
    name = n;
    left = Math.min(x1,x2);
    right = Math.max(x1,x2);
    top = Math.min(y1,y2);
    bottom = Math.max(y1,y2);
    isHovered = false;
  }
  
  void display() {
    pushStyle();
    rectMode(CORNERS);
    colorMode(HSB,255);
    fill(color(255, 0, 150));
    rect(left,top,right,bottom);
    popStyle();
  }
  
  String toString() {
    return left + "," + top + " " + right + "," + bottom;
  }
}

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
    if (bullet.bouncesLeft <= 0) {bulletsToKill.add(bullet);}
    bullet.handleCollisions();
    bullet.move();
    bullet.display();
  }
  // graveyard
  for (Bullet bullet : bulletsToKill) {bullets.remove(bullet);}
  bulletsToKill.clear();
}

void handleWalls() {
  for (Wall wall : walls) {
    wall.display();
  }
  // graveyard
  for (Wall wall : wallsToKill) {walls.remove(wall);}
  wallsToKill.clear();
}

// keyboard controls
void handleKeyboardMovement() {
  player1.vel.x = 0;
  player2.vel.x = 0;
  
  if (keys[0]) {  // w
    //player1.angle = 3*HALF_PI;
    player1.jump();
  }
  if (keys[1]) {  // a
    //player1.angle = PI;
    if (Math.cos(player1.angle) > 0) {
      player1.angle = PI - player1.angle;
    }
    player1.vel.x = velLeft.x;
  }
  if (keys[2]) {  // s
    //player1.angle = HALF_PI;
  }
  if (keys[3]) {  // d
    //player1.angle = 0;
    if (Math.cos(player1.angle) < 0) {
      player1.angle = PI - player1.angle;
    }
    player1.vel.x = velRight.x;
  }
  if (keys[0] && keys[1]) {  // wa
    //player1.angle = 5*QUARTER_PI;
  }
  if (keys[1] && keys[2]) {  // as
    //player1.angle = 3*QUARTER_PI;
  }
  if (keys[2] && keys[3]) {  // sd
    //player1.angle = QUARTER_PI;
  }
  if (keys[3] && keys[0]) {  // dw
    //player1.angle = 7*QUARTER_PI;
  }
  if (keys[4]) { player1.shoot(); }  // x
  if (keys[10]) { player1.angle += GUN_ROTATION_SPEED; }  // e
  if (keys[11]) { player1.angle -= GUN_ROTATION_SPEED; }  // q
  
  if (keys[5]) {
    //player2.angle = 3*HALF_PI;
    player2.jump();
  }  // i
  if (keys[6]) {  // j
    //player2.angle = PI;
    player2.vel.x = velLeft.x;
  }
  if (keys[7]) {  // k
    //player2.angle = HALF_PI;
  }
  if (keys[8]) {  // l
    //player2.angle = 0;
    player2.vel.x = velRight.x;
  }
  if (keys[5] && keys[6]) {  // ij
    //player2.angle = 5*QUARTER_PI;
  }
  if (keys[6] && keys[7]) {  // jk
    //player2.angle = 3*QUARTER_PI;
  }
  if (keys[7] && keys[8]) {  // kl
    //player2.angle = QUARTER_PI;
  }
  if (keys[8] && keys[5]) {  // li
    //player2.angle = 7*QUARTER_PI;
  }
  if (keys[9]) {player2.shoot(); }  // ,
  if (keys[12]) { player2.angle += GUN_ROTATION_SPEED; }  // u
  if (keys[13]) { player2.angle -= GUN_ROTATION_SPEED; }  // o
}

void handleButtons() {
  for (Button button : buttons) { // checks each button for if hovered and does actions
    button.isHovered = false;
    if (debugMode) { button.display(); }
    if (mouseX > button.left && mouseX < button.right && mouseY > button.top && mouseY < button.bottom) {
      button.isHovered = true;
    }
  }
  // graveyard
  for (Button button : buttonsToKill) {buttons.remove(button);}
  buttonsToKill.clear();
}
/*===KEYBOARD INTERPRETER===*/
boolean[] keys = new boolean[20];  // wasdxijkl,

void keyPressed() {
  setKeyPressed(key, true);
  
  switch (key) {
    case 'r' :
      resetGame();
      break;
    case ' ' :
      // TODO: ADD PAUSING
      break;
    case '`' :
      debugMode = !debugMode;
      break;
  }
  
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
    case 'e' :
      keys[10] = isPressed;
      break;
    case 'q' :
      keys[11] = isPressed;
      break;
    case 'o' :
      keys[12] = isPressed;
      break;
    case 'u' :
      keys[13] = isPressed;
      break;
  }
}

/*===WALL BUILDER===*/

void mousePressed() {
  if (screen == GAME_SCREEN) {
    if (! debugMode) {return;}
    mouseDown = false;
    boolean removedWall = false;
    for (Wall wall : walls) {
      if (mouseX > wall.left && mouseX < wall.right && mouseY > wall.top && mouseY < wall.bottom) {
        wallsToKill.add(wall);
        removedWall = true;
        System.out.println("RAHHHH" + millis());
      }
    }
    if (! removedWall){
      mouseDown = true;
      wallBuilderCorner1 = new PVector(mouseX, mouseY);
    }
  }
  
}

void mouseReleased() {
  // press button
  for (Button button : buttons) {
    if (button.isHovered){   
      System.out.println("mouseReleeased " + button);
      setScreen(1);
      //screen = 1;
      
      // TODONOW switch case for every possible button in the game
      switch (button.name) {
        case "playButton" :
          screen = 1;
          break;
        case "blahhh" :
          // rahhhh
          break;
      }
    }
  }
  
  //if (! debugMode) {return;}
  //else { System.out.println("x"+mouseX+"/"+width + " y"+mouseY+"/"+height);}

  if (screen == GAME_SCREEN) {
    if (mouseDown) {
      mouseDown = false;
      wallBuilderCorner2 = new PVector(mouseX, mouseY);
      
      if (! wallBuilderCorner1.equals(wallBuilderCorner2)) {
        walls.add(new Wall(wallBuilderCorner1.x,wallBuilderCorner1.y,wallBuilderCorner2.x,wallBuilderCorner2.y));
      }
    }
  }
}

void handleWallBuilder() {
  if (mouseDown) {
    pushStyle();
    rectMode(CORNERS);
    fill(hueValue, 10);
    rect(wallBuilderCorner1.x,wallBuilderCorner1.y,mouseX,mouseY);
    popStyle();
  }
}

/*===SAVE AND LOAD MAPS===*/

void loadMap(String mapFileName) {
  try {
    File myFile = new File(sketchPath("maps/" + mapFileName));
    Scanner myScanner = new Scanner(myFile);
    walls.clear();
    
    while (myScanner.hasNextLine()) {
      String coords = myScanner.nextLine();
      Scanner s = new Scanner(coords);
      float top = parseFloat(s.next()) * height / 1000;
      float bottom = parseFloat(s.next()) * height / 1000;
      float left = parseFloat(s.next()) * width / 1600;
      float right = parseFloat(s.next()) * width / 1600;

      walls.add(new Wall(left,top,right,bottom));
      s.close();
    }
    myScanner.close();
  } catch (FileNotFoundException e){
    System.err.println("Could not find file " + mapFileName + " in maps folder:" + e.getMessage());
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
  System.out.println(playButton.isHovered);

}

void setupTest() {

}
