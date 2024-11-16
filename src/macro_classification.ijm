run("Close All"); // Fermer les images déjà ouvertes avant de commencer l'analyse
erreur = false; //Indique s'il y a une erreur lors de l'analyse


//Intéraction avec l'utilisateur
dir_result = getDirectory("Entrez le dossier output qui contiendra les résultats"); // Dossier output résultat
dir = getDirectory("Merci ! Entrez à présent le dossier input contenant les images à analyser"); // Dossier input images
list = getFileList(dir);
title = "classification_skeleton"; // Nom par défaut du fichier de sorti
Dialog.create("Entrez le nom du ficher résultat"); // Boîte de dialogue avec l'utilisateur 
Dialog.addCheckbox("Afficher les images lors de l'analyse", false); // L'utilisateur choisi si les images s'affichent ou pas
Dialog.show();
affiche = Dialog.getCheckbox();
setBatchMode(!affiche); 


// Fonctions auxiliaires pour eviter d'écrire plusieurs fois les mêmes lignes de code
function fermer(img) { 
	// Cette fonction permet de fermer l'image voulu
	selectWindow(img);
	run("Close");
}

function pretraitement(){ 
	// Lorsque cette fonction est apellée, les étapes ci-dessous sont réalisés
	run("8-bit");
	run("Set Scale...", "distance=1 known=0.454 pixel=1 unit=µm global");
	run("Subtract Background...", "rolling=50");
	run("Enhance Contrast...", "saturated=0.1 normalize");
	run("Duplicate...", " "); 
}

function resultats(i){		
	// La classification est terminé
	selectWindow("Results");
	if (erreur){ 
		// Si une erreur est détectée dans l'analyse (donc erreur= true) afficher le message suivant
		showMessage("Des erreurs se sont produites lors de l'analyse, les résultats ne sont pas disponibles !");
	}else { 		
		fermer("Branch information");
		saveAs("Results", dir_result+title+i+".csv");
	}	
}


// Programme principal 
for (i=0; i<list.length; i=i+4) { // Parcours le dossier par lot de 4 images
   	if(endsWith(list[i], ".TIF")){ // Si l'extension de l'image est correcte l'analyse continue
   		
	   	//Image des Noyaux
	   	open(list[i]); 
	   	pretraitement(); // Noyaux avec prétraitement			
		setAutoThreshold("Default dark");//Default
		run("Convert to Mask");		
		run("Watershed");
		rename("h+"); // Noyaux avec seuillage								
									
		//Image des Oligodendrocytes
		open(list[i+1]);
		run("8-bit");
		run("Set Scale...", "distance=1 known=0.454 pixel=1 unit=µm global");
		run("Subtract Background...", "rolling=150");
		run("Enhance Contrast...", "saturated=0.35 normalize");
		run("Duplicate...", " "); 
		setAutoThreshold("Huang dark"); //Huang
		setOption("BlackBackground", false);
		run("Convert to Mask");
		rename("O4"); // Oligo avec seuillage
		imageCalculator("AND create", "h+","O4"); 
		run("Analyze Particles...", "size=50-100000 circularity=0.40-1.00 show=Masks exclude");
		run("Fill Holes"); 
		rename("h+O4");
		run("Duplicate...", " "); // Oligo seuillé + noyaux seuillé 

		// Addition noyaux + cytoplasme oligo
		imageCalculator("AND create", "h+","O4");
		run("Analyze Particles...", "size=60-400 circularity=0.40-1.00 show=Masks exclude");
		run("Fill Holes");
		rename("h+O4");
		
		//Fermer les images
		fermer("Result of h+");
		fermer("h+");
		
		//Effectuer un Voronoi sur l'image résultant de l'addition des noyaux et cytoplasme d'oligodendrocytes suivi du seuillage
		run("Voronoi");
		setAutoThreshold("Default dark");
		setThreshold(1, 1e30); 
		run("Convert to Mask");
		run("Invert");
		rename("voronoi h+O4");
	
		//Additionner l'image oligodendrocyte seuillé avec celle obtenus suite à Voronoi
		imageCalculator("AND create", "O4","voronoi h+O4");
		setOption("BlackBackground", false);
		run("Skeletonize"); // Obtenir le skelete des images
		run("Analyze Particles...", "size=50-3000 show=Masks");
		
		// Utiliser le plugin Analyze Skeleton (2D/3D)
		run("Analyze Skeleton (2D/3D)", "prune=none calculate show display");
	
		//Crée un fichier CSV par image analysée
		resultats(i); 
		 
		if(affiche){
			// Si l'utilisateur souhaite voir les images
			fermer("Result of O4");
			run("Tile"); // Aligne les images
			waitForUser("Analyser les images suivantes"); 
		}
		run("Close All");
	
	} else{ 
			// Si l'extension de l'image est incorrect afficher le message suivant et arrêter l'analyse
			showMessage("L'extension de l'image est incorrect");
			erreur=true; // indique la présence d'une erreur lors de l'analyse
			i = list.length; // i vaux la taille maximal du dossier pour sortir de la boucle for et donc sortir de l'analyse
	}	
}

// Si aucune erreur, afficher le message suivant
showMessage("La classification des oligodendrocytes est terminé !\n Les résultats sont présents dans les fichiers au format CSV");