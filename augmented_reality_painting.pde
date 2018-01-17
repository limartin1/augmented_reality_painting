/* DÉBUT DE LA ZONE DE RÉGLAGES */
// Mode de détection de couleur (0 : un pixel / 1 : 9 pixels (centre plus tout autour) / 2 : un carré de pixels de rayon ray autour du pixel central / 3 : un carré de pixels de rayon 5)
int modeDetection = 0;

// Réglage sensibilité différence de couleur
int sensibilite = 85;
int margeErreur = 80;
// Marge autour du point de coordonnées pxPOI, pyPOI dans laquelle on cherche le nouveau pointeur
final int marge = 100; 

// Ici il faut mettre le code de la touche que l'on veut affecter à une des 3 actions
boolean afficheKeyCode = false;
final int boutonForm = 70; // 70 = lettre f // 33 = bouton gauche pointeur
final int boutonCoul = 67; // 67 = lettre c // 34 = bouton droit pointeur
final int boutonEffac = 32; // 32 = barre espace // 66 = bouton haut pointeur
final int boutonReinit = 73; // 73 = lettre i
/* FIN DE LA ZONE DE REGLAGES */


// Importation des paquets pour la gestion de la webcam
import processing.video.*;
// Déclaration de la variable webcam
Capture cam;
// Déclaration de la zone de dessin
PGraphics dessin;

// Dimensions de la fenêtre et autres tailles
final int largeur = 640, hauteur = 480;
final int bandeau = 80; // Hauteur de la bande en haut de la fenêtre

// Booleens
boolean initialise = false; // Vaut false tant que l'initialisation par l'utilisateur n'est pas faite
boolean aTrouve = false; // Vaut false quand le système ne détecte pas le pointeur laser lors de l'utilisation du programme
                         
// Coordonnées pour redimensionner l'écran
int X1, X2, X3, X4;
int Y1, Y2, Y3, Y4;
// Image redimensionnée
PImage img;
PImage img1;

// Coordonnées du centre du laser étalon
int X5, Y5;
// Variable de dimensions du laser étalon
int dia = 0, ray = 0;
// Poids de couleur du laser étalon
int poidsRef;
// Type de laser (Rouge : 0, Vert : 1 ou Bleu : 2)
int typeLaser;

// Variable comptant le nombre de clics sur l'écran (pour l'initialisation)
int nbPoint = 0;

// Variables pour la gestion des couleurs
int r = 52, v = 196, b = 0;
color couleur;

// Variables pour l'intéraction entre la télécommande et le programme
int selectForm = 0;
int selectCoul = 1;

// Variables stockant les coordonnées précédentes du point laser détecté
int pxPOI = 0, pyPOI = 0;


void setup()
{
  size(640, 560); // (largeur, hauteur + bandeau);
  surface.setTitle("MARTIN Lilian - Projet ZZ1");
  
  colorMode(RGB, 255, 255, 255);
  String[] cameras = Capture.list();
  if (cameras.length == 0) 
  {
    println("Il n'y a pas de caméra disponible pour la capture");
    exit();
  }
  else
  {
    cam = new Capture(this, largeur, hauteur);
    cam.start();
    dessin = createGraphics(largeur, hauteur);
    img1  = createImage(largeur, hauteur, RGB);
    dessin.beginDraw();
    dessin.background(255);
    dessin.endDraw();
    smooth();
  }
}



void draw()
{
  if (!initialise)
  {
    initialisation();
  }
  else
  {
    if (cam.available())
    {
      cam.read();
      image(cam, 0, bandeau);
      
      recadrage();
      
      couleur = color(r,v,b);
      changeCouleur();
      changeForme();
      
      detectionLaser();
      
      image(dessin, 0, bandeau);
    }
  }
}



void initialisation()
{
  color coulRef = 0;
  int Rref = 0;
  int Gref = 0;
  int Bref = 0;
  
  if (nbPoint < 4) // Les 4 points de l'image n'ont pas encore été selectionnés pour le recadrage
  {
    if (cam.available())
    {
      cam.read();
      noFill();
      couleur = color(r,v,b);
      changeCouleur();
      changeForme();
      
      image(cam, 0, bandeau); // On affiche la webCam à l'écran
      
      stroke(couleur); // Le contour des formes est de la couleur actuelle
      
      switch(nbPoint) // Permet de faire choisir les endroits où cliquer sur l'écran
      {
        case 0:
          text("Sélectionnez le coin haut gauche", 10, 45);
          break;
        case 1:
          text("Sélectionnez le coin haut droit", 10, 45);
          ellipse(X1,Y1,10,10);
          break;
        case 2:
          text("Sélectionnez le coin bas droit", 10, 45);
          ellipse(X1,Y1,10,10);
          ellipse(X2,Y2,10,10);
          break;
        case 3:
          text("Sélectionnez le coin bas gauche", 10, 45);
          ellipse(X1,Y1,10,10);
          ellipse(X2,Y2,10,10);
          ellipse(X3,Y3,10,10);
          break;
      }
    }
  }
  
  else if (nbPoint == 4)
  {
    if (cam.available())
    {
      cam.read();
      image(cam, 0, bandeau);
      recadrage();
      
      couleur = color(r,v,b);
      changeCouleur();
      changeForme();
      
      text("Pointez le laser et cliquez", 10, 45);
    }
  }
  
  else if (nbPoint == 5) // On définit le centre du point laser
  {
    changeCouleur();
    changeForme();
    text("Cliquez au centre du laser", 10, 45);  
  }
  
  else if (nbPoint == 6 && modeDetection == 2) // On entoure le laser afin de calculer la valeur du laser étalon
  {
    image(img1, 0, bandeau);
    couleur = color(r,v,b);
    changeCouleur();
    changeForme();
    text("Glissez la souris pour entourer le laser", 10, 45);

    ellipseMode(CENTER); // On fait tracer un cercle autour du centre du pointeur pour délimiter son champ d'action
    dia = 2*(mouseX - X5);
    ray = dia/2;
    ellipse(X5, Y5, dia, dia);
  }
 
  else if (nbPoint == 6 && modeDetection == 3) // De cette manière, on fixe le rayon du moyennage à 5 pixels
  {
    ray = 5;
    nbPoint++;
  }
  
  else if (nbPoint == 6)
  {
    nbPoint++;
  }
  
  else if (nbPoint == 7)
  { 
    coulRef = calculCoul(X5,Y5-bandeau, img1);
    Rref = (int) red(coulRef);
    Gref = (int) green(coulRef);
    Bref = (int) blue(coulRef);
    
    println("R : " + Rref + " V : " + Gref + " B : " + Bref); 
    
    if (Rref >= Gref && Rref >= Bref)
    {
      poidsRef = 3*abs(255-Rref) + Gref + Bref;
      println("Couleur dominante : rouge");
    }
    else if (Gref >= Rref && Gref >= Bref)
    {
      poidsRef = Bref + 3*abs(255-Gref) + Bref;
      println("Couleur dominante : vert");
    }
    else if (Bref >= Rref && Bref >= Gref)
    {
      poidsRef = Bref + Gref + 3*abs(255-Bref);
      println("Couleur dominante : bleue");
    }
    
    println("PoidsRef : "+poidsRef);
    
    initialise = true;
  }
}



void recadrage() // Cette fonction sert à recadrer l'image afin de ne pas prendre en compte la zone autour de l'image du projecteur
{
  float ratio_x;
  float ratio_y;
  float xo, yo;
  float xmin, xmax;
  
  saveFrame("origine.jpg");
  img = loadImage("origine.jpg");
  
  for(float yi=0; yi<hauteur; yi++)
  {
    ratio_y = yi/hauteur;
    yo = (1-ratio_y)*Y1 + ratio_y*Y4;
    xmin = (1-ratio_y)*X1 + ratio_y*X4;
    xmax = (1-ratio_y)*X2 + ratio_y*X3;
    
    for(float xi=0; xi<largeur; xi++)
    {
      ratio_x = xi/largeur;
      xo = (1-ratio_x)*xmin + ratio_x*xmax;
      img1.pixels[largeur*round(yi)+round(xi)] = img.pixels[largeur*round(yo)+round(xo)];
    }
  }
    
  img1.updatePixels(); // L'image fait largeur * hauteur
  image(img1, 0, bandeau);
}



color calculCoul(int x, int y, PImage imgTrav)
{
  color res = 0;
  int i = x + y*largeur;
  int compte;
  if (modeDetection == 0) // Valeur du pixel
  {
    res = imgTrav.pixels[i];
  }
  else if (modeDetection == 1) // Valeur du pixel moyennée avec les pixels un cran autour
  {
    res = (imgTrav.pixels[i-largeur-1]+imgTrav.pixels[i-largeur]+imgTrav.pixels[i-largeur+1]+imgTrav.pixels[i-1]+imgTrav.pixels[i]+imgTrav.pixels[i+1]+imgTrav.pixels[i+largeur-1]+imgTrav.pixels[i+largeur]+imgTrav.pixels[i+largeur+1])/9;
  }
  else if (modeDetection == 2) // Valeur du pixel moyennée avec les pixels ray crans autour
  {
    compte = 1;
    for (int a = 0; a < ray; a++)
    {
      for (int b = 1; b < ray; b++)
      {
        if (a!=0)
        {
          res += imgTrav.pixels[i+a*largeur-b]+imgTrav.pixels[i+a*largeur+b];
          compte+=2;
        }
        res += imgTrav.pixels[i-a*largeur-b] + imgTrav.pixels[i-a*largeur+b];
        compte+=2;
      }
    }
    res += imgTrav.pixels[i];
        
    res/=compte;
  }
  
  else if (modeDetection == 3) // Valeur du pixel moyennée avec les pixels 5 crans autour
  {
    compte = 1;
    for (int a = 0; a < 6; a++)
    {
      for (int b = 1; b < 6; b++)
      {
        if (a!=0)
        {
          res += imgTrav.pixels[i+a*largeur-b]+imgTrav.pixels[i+a*largeur+b];
          compte+=2;
        }
        res += imgTrav.pixels[i-a*largeur-b] + imgTrav.pixels[i-a*largeur+b];
        compte+=2;
      }
    }
    res += imgTrav.pixels[i];
        
    res/=compte;
  }
 
  return res;
}



void detectionLaser()
{
  int xx, yy;
  color currColor;
  
  int xPOI = 0;
  int yPOI = 0;
  
  int R = 0;
  int G = 0;
  int B = 0;
  
  int poidsCour = 0;
  int poidsPOI = 3*255*255; 
  
  int rechX = 0, rechY = bandeau;
  
  if (!aTrouve) // Aucun point n'est encore trouvé
  {
    for (yy = 1 + ray; yy < hauteur - 1 - ray; yy++)
    { 
      for (xx = 1 + ray; xx < largeur - 1 - ray; xx++)
      {
        currColor = calculCoul(xx, yy, img1);
      
        R = (int) red(currColor);
        G = (int) green(currColor);
        B = (int) blue(currColor);
        
        switch(typeLaser)
        {
          case 0:
            poidsCour = 3*abs(255-R) + G + B;
            break;
          case 1:
            poidsCour = R + 3*abs(255-G) + B;
            break;
          case 2:
            poidsCour = R + G + 3*abs(255-B);
            break;
          default:
            println("Attention, la couleur étalon n'a pas l'air d'être sélectionnée");
        }
        
        if(poidsCour < poidsPOI)
        {
          poidsPOI = poidsCour;
          xPOI = xx;
          yPOI = yy;
        }
        
      }
    }
    println("Poids Ref : " + poidsRef + " Poids Actuel !aTrouve : " + poidsCour);
    
    if (poidsCour > poidsRef - sensibilite && poidsCour < poidsRef + sensibilite && abs(xPOI - pxPOI) < margeErreur && abs(yPOI - pyPOI) < margeErreur)
    {
      aTrouve = true;
      dessin.beginDraw();
      dessin.stroke(couleur);
      if(selectForm == 0)
      {
        dessin.line(pxPOI, pyPOI, xPOI, yPOI);
      }
      else if (selectForm == 1)
      {
        dessin.rect(xPOI, yPOI, 5, 5);
      }
      else if (selectForm == 2)
      {
        dessin.ellipse(xPOI, yPOI, 5, 5);
      }
      dessin.endDraw();
    }
    
    pxPOI = xPOI;
    pyPOI = yPOI;
  }
  
  else // Ici, on vient déjà de trouver un point
  {
    if (pxPOI < marge)
    {
      rechX = marge;
    }
    else if (pxPOI > (largeur - marge))
    {
      rechX = largeur - marge;
    }
    else
    {
      rechX = pxPOI;
    }
    if (pyPOI < marge)
    {
      rechY = marge;
    }
    else if (pyPOI > (hauteur - marge))
    {
      rechY = hauteur - marge;
    }
    else
    {
      rechY = pyPOI;
    }
    
    for (yy = rechY + 1 - marge + ray; yy < rechY + marge - ray - 1; yy++)
    {
      for (xx = rechX + 1 - marge + ray; xx < rechX + marge - ray - 1; xx++)
      {
        currColor = calculCoul(xx, yy, img1);
        
        R = (int) red(currColor);
        G = (int) green(currColor);
        B = (int) blue(currColor);
        
        switch(typeLaser)
        {
          case 0:
            poidsCour = 3*abs(255-R) + G + B;
            break;
          case 1:
            poidsCour = R + 3*abs(255-G) + B;
            break;
          case 2:
            poidsCour = R + G + 3*abs(255-B);
            break;
          default:
            println("Attention, la couleur étalon n'a pas l'air d'être sélectionnée");
        }
        
        if(poidsCour < poidsPOI)
        {
          poidsPOI = poidsCour;
          xPOI = xx;
          yPOI = yy;
        }
      }
    }
    
    println("Poids Ref : " + poidsRef + " Poids Actuel aTrouve : " + poidsCour);
    
    if (poidsCour > poidsRef - sensibilite && poidsCour < poidsRef + sensibilite && abs(xPOI - pxPOI) < margeErreur && abs(yPOI - pyPOI) < margeErreur)
    {
      dessin.beginDraw();
      dessin.stroke(couleur);
      if(selectForm == 0)
      {
        dessin.line(pxPOI, pyPOI, xPOI, yPOI);
      }
      else if (selectForm == 1)
      {
        dessin.rect(xPOI, yPOI, 5, 5);
      }
      else if (selectForm == 2)
      {
        dessin.ellipse(xPOI, yPOI, 5, 5);
      }
      dessin.endDraw();
    }
    else
    {
      aTrouve = false;
    }
    
    pxPOI = xPOI;
    pyPOI = yPOI;
  }
}



void changeCouleur() // Fonction qui permet de régler la couleur du dessin ou de l'affichage en fonction de la variable selectCoul
{ 
  noStroke();
  fill(couleur);
  rect(0, 0, largeur-bandeau, bandeau);
  
  switch (selectCoul)
  {
    case 0 : 
      r = 237;
      v = 0;
      b = 0;
      break;
    case 1 :
      r = 52;
      v = 196;
      b = 0;
      break;
    case 2 :
      r = 45;
      v = 24;
      b = 222;
      break;    
  }
}



void changeForme() // Fonction qui permet d'indiquer la forme du dessin en fonction de la variable selectForm
{
  noStroke();
  fill(255);
  rect(largeur-bandeau, 0, largeur, bandeau);
  
  noFill();
  stroke(0);
  
  switch (selectForm)
  {
    case 0 : 
      curve(largeur-bandeau-20, 1, largeur-bandeau+5, 5, largeur-20, bandeau-5, largeur-bandeau, bandeau+5);
      break;
    case 1 :
      rect(largeur-bandeau+5,5,bandeau-10, bandeau-10);
      break;
    case 2 :
      ellipseMode(CORNER);
      ellipse(largeur-bandeau+5,5,bandeau-10, bandeau-10);
      break;    
  }
}



void mousePressed() // Cette fonction permet de faire les différentes actions de l'initialisation 
                    // en fontion du nombre de fois où on a cliqué sur l'écran
{
  switch(nbPoint)
  {
    case 0:
      X1 = mouseX;
      Y1 = mouseY;
      nbPoint++;
      break;
    case 1:
      X2 = mouseX;
      Y2 = mouseY;
      nbPoint++;
      break;
    case 2:
      X3 = mouseX;
      Y3 = mouseY;
      nbPoint++;
      break;
    case 3:
      X4 = mouseX;
      Y4 = mouseY;
      nbPoint++;
      break;
    case 4:
      nbPoint++;
      break;
    case 5:
      X5 = mouseX;
      Y5 = mouseY;
      nbPoint++;
      break;
    case 6:
      nbPoint++;
      break;
    default:
      println("Tous les points sont déjà sélectionnés");
      break;
  }
}



void keyPressed() // Cette fonction permet de changer la forme ou la couleur du dessin en fonction du bouton appuyé sur le pointeur
{
  if (afficheKeyCode)
  {
    println(keyCode);
  }
  switch(keyCode)
  {
    case boutonCoul: // On change la couleur
      if (selectCoul < 2)
      {
        selectCoul ++;
      }
      else
      {
        selectCoul = 0;
      }
      changeCouleur();
      pxPOI = 0; // On considère que si on change de couleur on veut dessiner à partir d'un nouvel endroit
      pyPOI = 0;
      break;
    case boutonForm : // On change la forme du dessin
      if (selectForm < 2)
      {
        selectForm ++;
      }
      else
      {
        selectForm = 0;
      }
      pxPOI = 0;
      pyPOI = 0;
      break;
    case boutonEffac : // On efface le dessin
      dessin = createGraphics(largeur, hauteur);
      dessin.beginDraw();
      dessin.background(255);
      dessin.endDraw();  
      pxPOI = 0;
      pyPOI = 0;
      break;
    case boutonReinit : // On recommence l'initialisation du programme
      nbPoint = 0;
      dessin.beginDraw();
      dessin.background(255);
      dessin.endDraw();
      ray = 0;
      initialise = false;
      break;
  }
}