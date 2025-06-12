/*===IMPORTS===*/
import java.util.ArrayList;  // the goat
import java.util.Scanner;
import java.io.File;
import java.io.FileNotFoundException;
import processing.sound.*;

SoundFile bgm;
SoundFile gunshot;
SoundFile buttonSound;

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
boolean paused;

final int MAIN_MENU_SCREEN = 0;
final int SELECT_SCREEN = 1;
final int GAME_SCREEN = 2;
final int VICTORY_SCREEN = 3;

int screen;

/*===BUTTONS===*/
// main menu
Button playButton;
// select
Button map1Button, map2Button, map3Button, map4Button, map5Button, map6Button, map7Button, map8Button, map9Button, map10Button;
Button player1Gun1Button, player1Gun2Button, player2Gun1Button, player2Gun2Button;
Button backButton, gameButton;
Button[] mapButtons;

// pause
Button mainMenuButton;

final int CAT_SPEED = 8;
final float GUN_ROTATION_SPEED = 0.1;
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

// used for the color changing background
float hueValue = 0;

/*===DEFAULT OBJECTS===*/
Cat player1;
Cat player2;

/*===SPRITES===*/
PImage defaultSprite, player1Sprite, player2Sprite, gun1Sprite, gun2Sprite, bullet1Sprite, bullet2Sprite;

PImage crownImage, mainMenuImage, player1GunSelectSprite, player2GunSelectSprite;

// map images
PImage noMapImage, displayedMap, map1Image, map2Image, map3Image, map4Image, map5Image, map6Image, map7Image, map8Image, map9Image, map10Image;

// button images
PImage backButtonImage, gameButtonImage;

/*===WALL BUILDER===*/
boolean wallBuilderActive = false;
boolean mouseDown = false;
PVector wallBuilderCorner1, wallBuilderCorner2;

String mapSelectedPath = "map1.txt";
String player1Gun = "gun1";
String player2Gun = "gun1";


/*===SETUP===*/
void setup() {
  // set up window
  windowTitle("Cat1Cat2");
  windowResize(displayWidth, displayHeight-75);
  windowMove(0,-100);
  
  // sounds
  bgm = new SoundFile(this, "audio/background1.mp3");
  buttonSound = new SoundFile(this, "audio/button.mp3");
  if (Math.random() < 0.25) {bgm = new SoundFile(this, "audio/background2.mp3");}
  gunshot = new SoundFile(this, "audio/gunshot.wav");
  bgm.loop();
  
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
  // crown
  crownImage = loadImage("sprites/crown.png");
  // main menu
  mainMenuImage = loadImage("sprites/main_menu.png");
  // select screen
  noMapImage = loadImage("sprites/default.png");
  displayedMap = noMapImage;
  map1Image = loadImage("sprites/maps/map1.png");
  map2Image = loadImage("sprites/maps/map2.png");
  map3Image = loadImage("sprites/maps/map3.png");
  map4Image = loadImage("sprites/maps/map4.png");
  map5Image = loadImage("sprites/maps/map5.png");
  map6Image = loadImage("sprites/maps/map6.png");
  map7Image = loadImage("sprites/maps/map7.png");
  map8Image = loadImage("sprites/maps/map8.png");
  map9Image = loadImage("sprites/maps/map9.png");
  map10Image = loadImage("sprites/maps/map10.png");
  backButtonImage = loadImage("sprites/back_button.png");
  gameButtonImage = loadImage("sprites/game_button.png");
  
  player1GunSelectSprite = gun1Sprite;
  player2GunSelectSprite = gun1Sprite;
  
  // buttons
  playButton = new Button("playButton", 108, 149, 437, 342);
  playButton.visible = false;
  
  map1Button = new Button("map1Button", 0, 0, 0, 0, map1Image);
  map2Button = new Button("map2Button", 0, 0, 0, 0, map2Image);
  map3Button = new Button("map3Button", 0, 0, 0, 0, map3Image);
  map4Button = new Button("map4Button", 0, 0, 0, 0, map4Image);
  map5Button = new Button("map5Button", 0, 0, 0, 0, map5Image);
  map6Button = new Button("map6Button", 0, 0, 0, 0, map6Image);
  map7Button = new Button("map7Button", 0, 0, 0, 0, map7Image);
  map8Button = new Button("map8Button", 0, 0, 0, 0, map8Image);
  map9Button = new Button("map9Button", 0, 0, 0, 0, map9Image);
  map10Button = new Button("map10Button", 0, 0, 0, 0, map10Image);
  mapButtons = new Button[] {map1Button,map2Button,map3Button,map4Button,map5Button,map6Button,map7Button,map8Button,map9Button,map10Button};

  for (int i = 0; i < mapButtons.length/2; i++) {
    mapButtons[i].top = 22*height/30;
    mapButtons[i].bottom = 25*height/30;
    mapButtons[i].left = 50 + i*200;
    mapButtons[i].right = mapButtons[i].left + 180;
    System.out.println(mapButtons[i].name);
  }
  
  for (int i = mapButtons.length/2; i < mapButtons.length; i++) {
    mapButtons[i].top = 26*height/30;
    mapButtons[i].bottom = 29*height/30;
    mapButtons[i].left = 50 + (i-mapButtons.length/2)*200;
    mapButtons[i].right = mapButtons[i].left + 180;
  }
  
  player2Gun1Button = new Button("player2Gun1Button", width-50, 300, width-200, 400, gun1Sprite);
  player2Gun2Button = new Button("player2Gun2Button", width-50, 500, width-200, 600, gun2Sprite);
  player1Gun1Button = new Button("player1Gun1Button", width-300, 300, width-450, 400, gun1Sprite);
  player1Gun2Button = new Button("player1Gun2Button", width-300, 500, width-450, 600, gun2Sprite);
  backButton = new Button("backButton", 10, 10, 50, 50, backButtonImage);
  gameButton = new Button("gameButton", width-450, height-300, width-100, height-100, gameButtonImage);

  resetGame();
  
  // default screen
  setScreen(0);
  
}

void setScreen(int newScreen) {
  screen = newScreen;
  for (Button button : buttons) { button.isHovered = false; buttonsToKill.add(button); } // clear buttons
  
  switch (newScreen) {
    case MAIN_MENU_SCREEN :
      buttons.add(playButton);
      break;
    case SELECT_SCREEN :
      // add map buttons, 
      buttons.add(backButton);
      for (Button button : mapButtons) { buttons.add(button); }
      buttons.add(gameButton);
      buttons.add(player1Gun1Button);
      buttons.add(player1Gun2Button);
      buttons.add(player2Gun1Button);
      buttons.add(player2Gun2Button);
      break;
    case GAME_SCREEN :
      resetGame();
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
  player1.setGun(player1Gun);
  player2 = new Cat(2*width/3,height/2);
  player2.sprite = player2Sprite;
  player2.setGun(player2Gun);

  cats.add(player1);
  cats.add(player2);
  
  // initialize walls
  loadMap(mapSelectedPath);
  
  if (!debugMode) { noStroke(); }
}

void tickGame() {
  updateColor();
  handleWalls();
  handleCats();
  handleBullets();
  handleWallBuilder();
  handleKeyboardMovement();
  displayHealthBars();
}

void tickPaused() {
  handleButtons();

  pushStyle();
  fill(100, 15);
  rect(0,0,width,height);
  fill(255);
  textSize(200); 
  textAlign(CENTER);
  text("PAUSED",width/2,height/2);
  popStyle();
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
  backButton.isHovered = false;
  pushStyle();
  imageMode(CORNERS);
  image(mainMenuImage, 0, 0, width, height);
  
  handleButtons();
  popStyle();
}

void tickSelectScreen() {
  playButton.isHovered = false;
  updateColor();
  // logic for map button hovered over changes the pimage
  image(displayedMap,50,50,2*width/3,2*height/3);
  if (map1Button.isHovered) { image(map1Image,50,50,2*width/3,2*height/3); }
  if (map2Button.isHovered) { image(map2Image,50,50,2*width/3,2*height/3); }
  if (map3Button.isHovered) { image(map3Image,50,50,2*width/3,2*height/3); }
  if (map4Button.isHovered) { image(map4Image,50,50,2*width/3,2*height/3); }
  if (map5Button.isHovered) { image(map5Image,50,50,2*width/3,2*height/3); }
  if (map6Button.isHovered) { image(map6Image,50,50,2*width/3,2*height/3); }
  if (map7Button.isHovered) { image(map7Image,50,50,2*width/3,2*height/3); }
  if (map8Button.isHovered) { image(map8Image,50,50,2*width/3,2*height/3); }
  if (map9Button.isHovered) { image(map9Image,50,50,2*width/3,2*height/3); }
  if (map10Button.isHovered) { image(map10Image,50,50,2*width/3,2*height/3); }


  
  // gun select options
  pushStyle();
  imageMode(CORNERS);
  rectMode(CORNERS);

  image(player1Sprite, width-300, 50, width-450, 200);
  image(player1GunSelectSprite, width-275, 100, width-400, 200);
  fill(255,100,100);
  rect(width-300, 300, width-450, 400);  //p1g1
  rect(width-300, 500, width-450, 600);  //p1g2

  image(player2Sprite, width-50, 50, width-200, 200);
  image(player2GunSelectSprite, width-25, 100, width-150, 200);
  fill(100,100,255);
  rect(width-50, 300, width-200, 400);  //p2g1
  rect(width-50, 500, width-200, 600);  //p2g2

  popStyle();
  
  // hovered buttons have outlines
  for (Button button : buttons) {
    if (button.isHovered) {
      pushStyle();
      noFill();
      stroke(255);
      strokeWeight(10);
      rectMode(CORNERS);
      rect(button.left,button.top,button.right,button.bottom);
      popStyle();
    }
  }
  handleButtons();
}

void draw() {
  switch (screen) {
    case MAIN_MENU_SCREEN :
      tickMainMenu();
      break;
    case SELECT_SCREEN :
      tickSelectScreen();
      break;
    case GAME_SCREEN :
      if (! paused) {
        tickGame();
      }
      else {
        tickPaused();
      }
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
      
      // victory screen!
      if (cats.size() == 1) {
        // display crown
        image(crownImage,0,-size.y/2, size.x, size.y);
      }
  
      rotate(angle-0.15);
      image(gunSprite,75,25,100,50);
      
      //// rotate gun
      //angle += GUN_ROTATION_SPEED;
      if (angle > TWO_PI) {angle = 0;}
      if (angle < 0) {angle = TWO_PI + angle;}

    popMatrix();
    popStyle();
    
    if (cats.size() == 1) {
      // victory text
      int winner = (cats.get(0).equals(player1) ? 1 : 2);
      fill(0);
      textSize(30);
      textAlign(CENTER);
      text("Player " + winner + " wins!!!", width/2, height/3);
      text("Press R to restart", width/2, height/2.5);

    }
  }
  void shoot() {
    if (health > 0) {
      if (millis() - lastShot > reloadTime*1000) {
        Bullet b = new Bullet(bulletName, this);
        //angle -= GUN_ROTATION_SPEED*40;  // recoil
        lastShot = millis();
        bullets.add(b);
        gunshot.amp(0.2);  //quieter
        gunshot.play();  // gunshot sound
      }
    }
  }
  void setGun(String gunName) {  // workhere
    switch (gunName) {
      case "gun1" :  // fast but weak
        gunSprite = gun1Sprite;
        reloadTime = 0.2;
        bulletName = "bullet1";
        bulletBounces = 15;
        break;
      case "gun2" :  // slow but strong
        gunSprite = gun2Sprite;
        reloadTime = 0.6;
        bulletName = "bullet2";
        bulletBounces = 12;
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
    
    switch (bulletName) {  // fast but weak
      case "bullet1":
        vel.setMag(20);
        damageAmount = 3;
        bouncesLeft = 8;
        sprite = bullet1Sprite;
        size = new PVector(50,20);
        break;
      case "bullet2":  // slow but strong
        vel.setMag(10);
        damageAmount = 12;
        bouncesLeft = 12;
        sprite = bullet2Sprite;
        size = new PVector(60,20);
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
  PImage image;
  boolean visible;

  Button(String n, float x1, float y1, float x2, float y2) {
    name = n;
    left = Math.min(x1,x2) * (width/1710);
    right = Math.max(x1,x2) * (width/1710);
    top = Math.min(y1,y2) * (height/1037);
    bottom = Math.max(y1,y2) * (height/1037);
    isHovered = false;
    image = defaultSprite;
    visible = true;
  }
  
  Button(String n, float x1, float y1, float x2, float y2, PImage image) {
    this(n,x1,y1,x2,y2);
    this.image = image;
  }
  
  void display() {
    pushStyle();
    if (visible) {
      imageMode(CORNERS);
      image(image,left,top,right,bottom);
    }
    
    if (debugMode) {
      rectMode(CORNERS);
      //colorMode(HSB,255);
      fill(color(255, 100, 100));
      rect(left,top,right,bottom);
      textAlign(CENTER);
      textSize((bottom-top)/4);
      fill(0);
      text(name,left,top+5,right,bottom);
    }
    popStyle();
  }
  
  void displayImage() {
    
  }
  
  String toString() {
    //return left + "," + top + " " + right + "," + bottom;
    return name;
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

void handleButtons() {
  for (Button button : buttons) { // checks each button for if hovered
    button.isHovered = false;
    button.display();
    if (buttons.contains(button) && mouseX > button.left && mouseX < button.right && mouseY > button.top && mouseY < button.bottom) {
      button.isHovered = true;
    }
  }
  // graveyard
  for (Button button : buttonsToKill) {buttons.remove(button);}
  buttonsToKill.clear();
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
      if (screen == GAME_SCREEN) {
        buttons.clear();
        buttons.add(backButton);
        paused = (paused ? false : true);
      }
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

void setKeyPressed(char myKey, boolean isPressed) {  // SET CONTROLS HERE (keybinds)
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
    case 'f' :
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
    case 'h' :
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
  if (playButton.isHovered){ setScreen(SELECT_SCREEN); buttonSound.play(); } 
  if (backButton.isHovered){ setScreen(MAIN_MENU_SCREEN); }
  if (map1Button.isHovered){ displayedMap = map1Image; mapSelectedPath = "map1.txt"; buttonSound.play(); }
  if (map2Button.isHovered){ displayedMap = map2Image; mapSelectedPath = "map2.txt"; buttonSound.play(); }
  if (map3Button.isHovered){ displayedMap = map3Image; mapSelectedPath = "map3.txt"; buttonSound.play(); }
  if (map4Button.isHovered){ displayedMap = map4Image; mapSelectedPath = "map4.txt"; buttonSound.play(); }
  if (map5Button.isHovered){ displayedMap = map5Image; mapSelectedPath = "map5.txt"; buttonSound.play(); }
  if (map6Button.isHovered){ displayedMap = map6Image; mapSelectedPath = "map6.txt"; buttonSound.play(); }
  if (map7Button.isHovered){ displayedMap = map7Image; mapSelectedPath = "map7.txt"; buttonSound.play(); }
  if (map8Button.isHovered){ displayedMap = map8Image; mapSelectedPath = "map8.txt"; buttonSound.play(); }
  if (map9Button.isHovered){ displayedMap = map9Image; mapSelectedPath = "map9.txt"; buttonSound.play(); }
  if (map10Button.isHovered){ displayedMap = map10Image; mapSelectedPath = "map10.txt"; buttonSound.play(); }
  if (player1Gun1Button.isHovered){ player1GunSelectSprite = gun1Sprite; player1Gun="gun1"; buttonSound.play(); }
  if (player1Gun2Button.isHovered){ player1GunSelectSprite = gun2Sprite; player1Gun="gun2"; buttonSound.play(); }
  if (player2Gun1Button.isHovered){ player2GunSelectSprite = gun1Sprite; player2Gun="gun1"; buttonSound.play(); }
  if (player2Gun2Button.isHovered){ player2GunSelectSprite = gun2Sprite; player2Gun="gun2"; buttonSound.play(); }
  if (gameButton.isHovered){ setScreen(GAME_SCREEN); buttonSound.play(); }

  //if (! debugMode) {return;}
  //else { System.out.println("x"+mouseX+"/"+width + " y"+mouseY+"/"+height);}

  // wallbuilder
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
6/12/24
turning in project for apcsa
*/

void printTests() {
  System.out.println();
}

void setupTest() {

}
