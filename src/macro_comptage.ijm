run("Close All"); // Fermer les images déjà ouvertes avant de commencer l'analyse

/***********************************/
/* Interaction avec l'utilisateur  */
/***********************************/

//Entrez le dossier output qui contiendra les résultats
dir_result = getDirectory("Bonjour ! Entrez le dossier output qui contiendra les résultats"); 

// Boîte de dialogue :  Choisir le nom du fichier au format CSV qui contiendra les résultats et si on souhaite visualiser les images lors de l'analyse
title = "resultat";
image_n=0;
Dialog.create("Merci ! Entrez à présent vos choix");
Dialog.addString("Nom du fichier qui sera créé et contiendra les résultats", title);
Dialog.addNumber("Ouvrir à partir de lu lot d'image ",image_n);
Dialog.addCheckbox("Afficher les images lors de l'analyse", false);
Dialog.show();
title = Dialog.getString();
affiche = Dialog.getCheckbox();
image_n = Dialog.getNumber();

//Indique s'il y a une erreur lors de l'analyse
erreur = false;

//Entrez le dossier input contenant les images à analyser
dir = getDirectory("Merci ! Entrez à présent le dossier input contenant les images à analyser"); 
list = getFileList(dir);

setBatchMode(!affiche); // Afficher ou non les images pendant le process

/*************************/
/* Fonctions auxiliaires */
/*************************/

function pretraitement(){
	run("Set Scale...", "distance=1 known=0.454 pixel=1 unit=µm global"); 
	run("Median...", "radius=3");	
}

function seuillage() { 
	run("Duplicate...", " "); 
	setAutoThreshold("Otsu dark");
	run("Convert to Mask");
}

function mesure(img) { //img : image avec seuillage
	selectWindow(img);
	run("Set Measurements...", "area limit display redirect=p_h+ decimal=2");
	run("Analyze Particles...", "size=45-300 circularity=0.00-1.00 show=Masks summarize"); //30
}

function fermer(img) { 
	selectWindow(img);
	run("Close");
}

/************************/
/* Programme principal  */
/************************/
if ( image_n >= 0 && image_n <list.length){ // Vérifier si le numéro entrer par l'utilisateur est correct
	i=image_n;

	for (i=i; i<list.length; i=i+4) { // Pour chaque lot de quatre images		
		
		if(endsWith(list[i], ".TIF")){ // Vérifier que l'extension de l'image est au format TIF pour lancer l'analyse sinon l'analyse s'arrête
			
			/*Comptage des noyaux
			 * Ouvrir l'image à traiter et réaliser un prétraitement qui permet une mise à l'échelle, 
			 * Ajout de la saturation
			 * Réaliser un seuillage suivi d'un watershed 
			 * Enfin réaliser une mesure des objets (=noyau) présentent
			*/
			 
			open(list[i]); 
			rename("p_h+"); 
			pretraitement();
			run("Enhance Contrast...", "saturated=0.35");
			run("Apply LUT");
			seuillage();
			run("Watershed");
			rename("h+");		
			mesure("h+"); 	
											
			/*Comptage des oligodendrocytes
			 * Comme précédement réaliser un prétraitement
			 * Ajout de la saturation
			 * Réaliser un convolve pour améliorer la détection des contours des cellules
			 * Réaliser le seuillage et compléter les trous avec Fill Holes
			 * Utiliser imageCalculator pour additionner l'image avec seuillage des oligodendrocytes et celle des noyaux
			 * Réaliser une mesure des objets (=oligodendrocytes) présentent
			*/
			 	
			open(list[i+1]); 
			rename("p_O4");
			pretraitement();
			run("Enhance Contrast...", "saturated=0.1");
			run("Apply LUT");		
			run("Convolve...", "text1=[-1 -1 -1 -1 -1\n-1 -1 -1 -1 -1\n-1 -1 27 -1 -1\n-1 -1 -1 -1 -1\n-1 -1 -1 -1 -1\n] normalize");	
			seuillage();
			run("Fill Holes");
			rename("O4");
			imageCalculator("AND create", "h+","O4");	
			rename("O4");	
			run("Set Measurements...", "area limit display redirect=p_h+ decimal=2");
			run("Analyze Particles...", "size=28-300 circularity=0.00-1.00 show=Masks summarize");
													
			/*Comptage des astrocytes
			 * Comme précédement réaliser un prétraitement 
			 * Ajout de la saturation
			 * Réaliser un convolve pour améliorer la détection des contours des cellules
			 * Réaliser le seuillage et compléter les trous avec Fill Holes
			 * Utiliser imageCalculator pour additionner l'image des astrocytes et celle des noyaux
			 * Réaliser une mesure des objets (=astrocytes) présentent
			*/ 
			 
			open(list[i+2]); 
			rename("p_GFAP");
			pretraitement();	
			run("Enhance Contrast...", "saturated=0.2");
			run("Apply LUT");
			run("Convolve...", "text1=[-1 -1 -1 -1 -1\n-1 -1 -1 -1 -1\n-1 -1 27 -1 -1\n-1 -1 -1 -1 -1\n-1 -1 -1 -1 -1\n] normalize");
			seuillage();
			run("Fill Holes");
			rename("GFAP");	
			imageCalculator("AND create", "h+","GFAP");		
			rename("GFAP");
			run("Set Measurements...", "area limit display redirect=p_h+ decimal=2"); 
			run("Analyze Particles...", "size=20-300 circularity=0.00-1.00 show=Masks summarize");
			
			/****************/
			/* Mise en page */
			/****************/
			
			// Si l'utilisateur souhaite voir les image
			if(affiche){
				run("Tile"); // Aligner les images pour les comparer plus facilement
				waitForUser("Analyser les images suivantes"); // Demander à l'utilisateur s'il veux poursuivre l'analyse des 4 prochaines images présente dans le dossier
			}			
			run("Close All"); 
				
		} else{ // Si l'extension de l'image n'est pas correct ce message s'affiche 
			showMessage("L'extension de l'image est incorrect");
			erreur=true;
		}	
	}
}

else { //Si le numéro de l'image entrer par l'utilisateur est incorrect, la macro s'arrête
	showMessage("Le numéro d'image entrer est incorrect");
	erreur=true;
}


//S'il n'y a pas d'erreur lors de l'analyse alors les résultats sont enregistrés
if (!erreur){
	showMessage("Le comptage des noyaux et cellules pour chaque image du dossier est terminé !\n Les résultats sont présent dans le fichier "+title+".csv");
	Table.sort("Slice");
	saveAs("Results", dir_result+title+".csv"); //Sauvegarder les résultats dans un fichier au format CSV
	//Ouvrir le fichier au format CSV avec python pour calculer le rapport (et réaliser la classification k-means)
}
