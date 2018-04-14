Program battaille_navale;

uses crt;

CONST 
	MIN_L=1;
	MAX_L=50;
	MIN_C=1;
	MAX_C=50;
	NB_BATEAU=2;
	MAX_CASE=5;

//type ENUMERATION
TYPE 
	bool=(VRAI,FAUX);
	pos_Bateau=(Hor,Vert,diag);
	etat_Bateau=(touche,coule);
	etat_Flotte=(operationelle,sombre);
	etat_Joueur=(gagne,perdu);


//type de case de bateau représente les points de vie des bateaux, contient leur coordonnées
TYPE
	celule = RECORD
		ligne :INTEGER;
		colonne :INTEGER;
		END;

//type de bateau composé de celules
TYPE
	bateau = RECORD
		NCase: ARRAY [1..MAX_CASE] OF celule;
		mort: bool;
		END;

//type de flotte composé de bateaux
TYPE
	flotte = RECORD
		Nbateau: ARRAY [1..NB_BATEAU] OF bateau;
		ordre:INTEGER;
		detruit:bool;
		END;



//procédure qui créer une celule avec les coordonnées donnée
PROCEDURE crea_Celule (l,c:INTEGER;VAR mcase:celule);
	BEGIN
		mcase.ligne:=l;
		mcase.colonne:=c;
	END;

//fonction qui compare si 2 cases sont identique
FUNCTION comp_Case (mcase,tcase:celule):bool;
	VAR 
		okay:bool;
	BEGIN
		okay:=FAUX;
		IF ((mcase.ligne=tcase.ligne) AND (mcase.colonne=tcase.colonne)) THEN
			okay:=VRAI;
	END;


//fonction qui créer un bateau en lui donnant 1 celule et une taille
FUNCTION crea_Bateau (mcase:celule; taille:INTEGER):bateau;
	VAR
		res:bateau;
		pos:INTEGER;
		i:INTEGER;
		position_bat:pos_Bateau;
	BEGIN
		pos:=random(3)+1;
		position_bat:=(pos_Bateau(pos));//va donner aléatoirement une des 3 valeur, de l'énumération pos_bateau.
		res.mort:=FAUX;
		FOR i:=1 TO MAX_CASE DO
		BEGIN

			IF (i<=taille) THEN
			BEGIN
				(res.NCase[i].ligne):=mcase.ligne;
				(res.NCase[i].colonne):=mcase.colonne
			END
			ELSE
			BEGIN
				res.NCase[i].ligne:=-1;
				res.NCase[i].colonne:=-1;
			END;





			IF (position_bat=Hor) THEN
			BEGIN
				mcase.colonne:=mcase.colonne+1;
			END
			ELSE IF (position_bat=vert) THEN
					BEGIN
						mcase.ligne:=mcase.ligne+1
					END
			ELSE
			BEGIN 
				mcase.ligne:=mcase.ligne+1;
				mcase.colonne:=mcase.colonne+1;
			END;

		END;

		crea_Bateau:=res;
	END;	

//fonction qui compare chaque case d'un bateau donnée
FUNCTION control_Bateau ( VAR mbat:bateau; mcase:celule;attaque:bool):bool;
	VAR
		Ebateau:etat_Bateau;
		i:INTEGER;
		okay:bool;
		caseVide, caseToucher:celule;
		toucher, vide:INTEGER;
	BEGIN
		okay:=FAUX;
		i:=1;
		caseVide.ligne:=-1;
		caseVide.colonne:=-1;
		toucher:=0;
		caseToucher.ligne:=-2;
		caseToucher.colonne:=-2;
		REPEAT
			IF (comp_Case(mbat.NCase[i],mcase)=VRAI) THEN
				okay:=VRAI;


			i:=i+1;
		UNTIL ((comp_Case(mbat.NCase[i],caseVide)=VRAI) OR (i=MAX_CASE) OR (okay=VRAI));

		//si en phase d'attaque 
		IF (attaque=VRAI) THEN
		BEGIN
			//si les 2 cases sont identiques donc toucher
			IF (okay=VRAI) THEN
			BEGIN
				mbat.NCase[i]:=caseToucher;
				WRITELN (etat_Bateau(1));

				//si toutes les cases du bateau sont touché
				FOR i:=1 TO MAX_CASE DO
				BEGIN
					IF (comp_Case(mbat.NCase[i],caseToucher)=VRAI) THEN
						toucher:=toucher+1; 

					IF (comp_Case(mbat.NCase[i],caseVide)=VRAI) THEN
						vide:=vide+1;
				END;  

				//si toute les cases sont toucher alors c'est égale à max cases
				IF ((vide+toucher)=MAX_CASE) THEN
				BEGIN
					WRITELN (etat_Bateau(2));
					mbat.mort:=VRAI;
				END;

			END
			ELSE
			BEGIN
				WRITELN ('rater');
			END;
		END;


		control_Bateau:=okay;
	END;

//Fonction qui compare chaque bateau d'une flotte donnée
FUNCTION control_flotte (VAR mflotte:flotte; mcase:celule;attaque:bool):bool;
	VAR
		i:INTEGER;
		okay:bool;
	BEGIN
		okay:=FAUX;
		REPEAT
			IF (control_Bateau(mflotte.Nbateau[i],mcase,attaque)=VRAI) THEN
				okay:=VRAI;


			i:=i+1;
		UNTIL ((okay=VRAI) OR (i=NB_BATEAU));

		control_flotte:=okay;
	END;


//Procedure qui initialise la flotte d'un joueur
PROCEDURE init_flotte (VAR mflotte:flotte);
	VAR
		mcase:celule;
		i:INTEGER;
		posligne, poscolonne, taillebateau: INTEGER;
	BEGIN
		FOR i:=1 TO NB_BATEAU DO
		BEGIN
			posligne:=random(MAX_L)+1;
			poscolonne:=random(MAX_C)+1;
			taillebateau:=random(MAX_CASE)+1;
			crea_Celule(posligne,poscolonne,mcase);
			mflotte.Nbateau[i]:=crea_Bateau(mcase,taillebateau);
		END;
	END;



//BUT: transférer la bonne flotte celon le tour de jeu
//ENTREES: les 2 flottes de joueur, et le tour de jeu
//SORTIES: la flotte qui correspond au tour de jeu
FUNCTION quel(joueur1,joueur2: flotte;NBT: INTEGER):flotte;
VAR joueur: flotte;
BEGIN
	joueur:=joueur1;
	//si le tour est paire, c'est le joueur numéros 2 qui joue
	If (NBT MOD 2 = 0) THEN
		joueur:=joueur2;

	quel:=joueur;
END;



VAR
	joueur1, joueur2, joueur: flotte;
	okay, attaque:bool;
	NBT,x,y,i:INTEGER;
	choix:celule;
	couler:celule;
	Eflotte:etat_Flotte;

BEGIN
	RANDOMIZE;
	okay:=FAUX;
	attaque:=FAUX;
	x:=0;
	y:=1;
	NBT:=1;
	joueur1.ordre:=1;
	joueur2.ordre:=2;
	joueur1.detruit:=FAUX;
	joueur2.detruit:=FAUX;
	//initialisation des flottes des joueurs
	//initialise la flotte du joueur 1 en vérifiant que aucune case ne coincide avec les bateaux de la même flotte
	REPEAT
		REPEAT
			init_flotte (joueur1);
			IF ((control_flotte(joueur1,joueur1.Nbateau[i].NCase[y],attaque))=VRAI) THEN
				okay:=VRAI;

			y:=y+1;
		UNTIL (okay=VRAI) OR (y=MAX_CASE);
		IF (okay=FAUX) THEN
			x:=x+1
		ELSE
			x:=0;

	UNTIL (x=2);

	//initialise la flotte du joueur 2 en vérifiant que aucune case ne conincide avec les bateaux de la même flotte
	REPEAT
		REPEAT
			init_flotte (joueur2);
			IF ((control_flotte (joueur2,joueur2.Nbateau[i].NCase[y],attaque))=VRAI) THEN
			BEGIN
				okay:=VRAI;
			END;

			y:=y+1;
		UNTIL (okay=VRAI) OR (y=MAX_CASE);
		IF (okay=FAUX) THEN
			x:=x+1
		ELSE
			x:=0;

	UNTIL (x=2);

	joueur:=quel(joueur1,joueur2,NBT);
	attaque:=VRAI;
	crea_Celule(-2,-2,couler);

	//boucle du jeu
	REPEAT
		
		WRITELN ('tour numero',NBT);
		WRITELN ('tour du joueur',joueur.ordre);
		WRITELN ('donne une case à attaquer, la coordonnées x, puis y');
		READLN (choix.ligne,choix.colonne);
		NBT:=NBT+1;
		joueur:=quel(joueur1,joueur2,NBT);
		control_flotte(joueur,choix,attaque);

		IF ((joueur.Nbateau[1].mort=VRAI) AND (joueur.Nbateau[2].mort=VRAI)) THEN
		BEGIN
			WRITELN (etat_Flotte(2));
			joueur.detruit:=VRAI;
		END;
	UNTIL (joueur.detruit=VRAI);

	IF (joueur.ordre=1) THEN
		WRITELN ('joueur 2 gagne en : ",NBT," tours')
	ELSE
		WRITELN ('joueur 1 gagne en : ",NBT," tours');

END.