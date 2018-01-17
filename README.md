# augmented_reality_painting

<p>Pour utiliser ce programme, il faut installer Processing (disponible à cette adresse : https://processing.org/download/).</p>

<p>Ce programme a été réalisé dans le cadre de mon projet de 1ère année en école d'ingénieur à l'ISIMA (Institut Supérieur d'Informatique, de Modélisation et de leurs Applications) à Aubière, et encadré par Mr E. Mesnard, professeur de RV, RA et Systèmes Embarqués.</p>

<p>L'objectif de ce projet consiste à pointer un laser sur un mur afin de garder la trace de celui-ci comme si nous dessinons sur le mur. Pour cela, une webcam filme le laser sur le mur, le programme le détecte et traite les données afin de pouvoir reprojeter en direct sur le mur les dessin fait par l'utilisateur.</p>

###Guide d'utilisation : 
* 1ère étape : Avant d'éxécuter le programme, il faut choisir le mode de détection sur la 2ème ligne de code. (Par défaut, la détection du laser se fait sur un seul pixel).

* 2ème étape : Une fois le programme lancé, il faut sélectionner dans l'image les 4 coins correspondant aux 4 angles du projecteur afin de pouvoir délimiter la zone d'utilisation.

* 3ème étape : Enfin, il faut pointer le laser sur l'image, cliquer sur l'écran afin de figer l'image et cliquer sur le laser afin de pouvoir définir une couleur de référence.