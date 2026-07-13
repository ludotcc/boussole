# DCF_001 — Organisation Parent

**Projet :** Boussole

**Module :** Organisation Parent

**Version :** 1.0

**Statut :** Conception validée

**Dernière mise à jour :** 11 juillet 2026

---

# 1. Objectif

L'espace **Organisation Parent** est un outil d'organisation personnelle destiné à réduire durablement la charge mentale des parents.

Il ne cherche pas à rendre le parent plus productif.

Il l'aide à prendre les bonnes décisions, au bon moment.

Chaque ouverture de cette page doit permettre au parent de répondre immédiatement à deux questions essentielles :

* **Qu'est-ce que je dois faire aujourd'hui ?**
* **Qu'est-ce que je ne dois pas oublier ?**

Le parent doit quitter cette page avec un esprit plus léger qu'en y entrant.

---

# 2. Philosophie

L'espace Organisation respecte entièrement la philosophie de Boussole.

Le parent reste toujours maître de ses décisions.

L'application accompagne.

Elle ne décide jamais.

L'objectif n'est pas de créer une application de gestion de tâches.

L'objectif est de créer un assistant d'organisation familiale bienveillant.

---

# 3. Vision

La matrice d'Eisenhower constitue le cœur de cette fonctionnalité.

Elle n'est jamais remplacée.

Elle est considérée comme un outil de réflexion.

Chaque nouvelle tâche est analysée grâce à cette matrice afin d'aider le parent à prendre une décision adaptée.

La matrice n'est donc pas une simple liste de tâches.

Elle est un outil de priorisation.

---

# 4. Les principes fondamentaux

## 4.1 Réduire la charge mentale

Chaque interaction avec cette fonctionnalité doit réduire la charge mentale du parent.

Même lorsqu'aucune tâche n'est terminée.

Exemples :

* planifier une tâche ;
* découper une tâche ;
* déléguer une tâche ;
* supprimer une tâche devenue inutile.

Toutes ces actions sont considérées comme des progrès.

---

## 4.2 Ne jamais culpabiliser

L'application ne doit jamais rappeler au parent qu'il est "en retard".

Les notions suivantes ne sont jamais mises en avant :

* nombre de jours de retard ;
* date de création d'une tâche ;
* nombre de rappels envoyés ;
* échéance dépassée ;
* statistiques anxiogènes.

Les échéances servent uniquement à organiser.

Jamais à culpabiliser.

---

## 4.3 Valoriser les progrès

La réussite ne correspond pas uniquement à une tâche terminée.

Boussole valorise également :

* une tâche commencée ;
* une tâche planifiée ;
* une sous-étape terminée ;
* une bonne délégation ;
* une tâche abandonnée lorsqu'elle n'est plus utile.

Chaque bonne décision représente un progrès.

---

## 4.4 La simplicité avant tout

Le parent ne doit jamais être submergé d'informations.

Chaque écran doit rester clair.

Chaque information affichée doit avoir une utilité immédiate.

---

# 5. Parcours mental du parent

Les observations montrent que le parcours naturel est le suivant :

1. consulter immédiatement les tâches **Urgentes & Importantes** ;
2. identifier les tâches importantes pouvant être planifiées afin de libérer son esprit ;
3. consulter les tâches terminées afin de constater les progrès réalisés ;
4. retourner à son activité.

L'interface devra respecter ce fonctionnement naturel.

Elle ne devra jamais tenter de le modifier.

---

# 6. Les objets métier

## 6.1 La tâche

La tâche est l'élément principal de cette fonctionnalité.

Elle possède :

* un titre ;
* une description (optionnelle) ;
* un quadrant Eisenhower ;
* un niveau d'importance ;
* un état ;
* des sous-étapes ;
* une échéance (optionnelle) ;
* un ou plusieurs rappels (optionnels).

Des évolutions futures permettront également :

* d'attribuer un responsable ;
* d'associer un projet.

---

## 6.2 Les sous-étapes

Une tâche peut être découpée en plusieurs sous-étapes.

L'objectif est de rendre une tâche importante moins intimidante.

Les sous-étapes permettent d'avancer progressivement.

Chaque sous-étape réalisée constitue une petite victoire.

Les sous-étapes restent volontairement simples.

Elles ne possèdent pas leur propre logique métier.

---

## 6.3 Les rappels

Le rappel est un compagnon de mémoire.

Il ne représente jamais une alerte.

Son objectif est simplement de remettre une information devant le parent au moment opportun.

Le rappel est totalement indépendant de l'échéance.

Une tâche peut :

* posséder une échéance sans rappel ;
* posséder un rappel sans échéance ;
* posséder plusieurs rappels.

---

## 6.4 L'échéance

Une échéance représente uniquement une information d'organisation.

Elle n'est jamais utilisée pour générer du stress.

Aucune notion de retard ne devra apparaître dans l'application.

---

## 6.5 Les encouragements

Les encouragements accompagnent le parent.

Ils célèbrent les bonnes décisions.

Ils ne récompensent jamais la performance.

Exemples :

* « Parfait, tu n'as plus besoin d'y penser pour le moment. »
* « Une étape de faite. Tu avances. »
* « Bonne décision. Tu viens d'alléger ta charge mentale. »

---

# 7. Cycle de vie d'une tâche

Chaque tâche suit le cycle suivant :

Idée

↓

Classement dans la matrice

↓

Découpage éventuel en sous-étapes

↓

Planification éventuelle

↓

Début

↓

Progression

↓

Terminée

↓

Historique

Une tâche peut également :

* être déléguée ;
* être replanifiée ;
* être abandonnée lorsqu'elle n'a plus d'intérêt.

---

# 8. Les quadrants

## Urgent & Important

Mission :

Identifier immédiatement les véritables priorités.

Le parent doit savoir instantanément par quoi commencer.

---

## Important & Pas urgent

Mission :

Repérer les tâches pouvant être planifiées.

Le parent ne planifie pas uniquement pour organiser son agenda.

Il planifie afin de libérer son esprit.

Cette catégorie devra permettre, en quelques actions seulement, de créer un événement dans :

* l'agenda personnel ;
* ou l'agenda familial.

Une fois planifiée, une tâche devra indiquer clairement qu'elle est désormais organisée.

---

## Pas urgent & Important (À déléguer)

Mission :

Identifier les tâches pouvant être confiées à une autre personne.

Une future évolution permettra d'attribuer ces tâches :

* à un parent ;
* à un enfant ;
* ou à un autre membre de la famille.

---

## Pas urgent & Pas important

Mission :

Prendre conscience qu'une tâche peut parfois être supprimée.

Supprimer une tâche inutile constitue également une bonne décision.

---

# 9. Les cartes

Une carte doit rester très légère visuellement.

Toujours visibles :

* le titre ;
* la progression ;
* le niveau d'importance.

Jamais visibles :

* la date de création ;
* l'ancienneté ;
* le retard ;
* le nombre de rappels ;
* les statistiques négatives.

Une carte ne doit jamais provoquer un sentiment de culpabilité.

---

# 10. Les rappels

Les rappels utilisent toujours un vocabulaire positif.

Exemples :

* « Tu avais prévu d'y penser aujourd'hui. »
* « Un bon moment pour avancer sur cette tâche. »
* « Tu peux reprendre là où tu t'étais arrêté. »

Ils ne doivent jamais afficher :

* « En retard » ;
* « Échéance dépassée » ;
* « Dernière relance ».

---

# 11. Les notifications

Les notifications suivent la même philosophie.

Elles accompagnent.

Elles ne mettent jamais la pression.

L'objectif est de ramener doucement l'information au bon moment.

Jamais de créer un sentiment d'urgence artificielle.

---

# 12. Valorisation des progrès

L'espace Organisation valorise toutes les bonnes décisions.

Sont considérés comme des progrès :

* créer une tâche ;
* commencer une tâche ;
* réaliser une sous-étape ;
* planifier une tâche ;
* déléguer une tâche ;
* supprimer une tâche devenue inutile.

Le parent doit avoir le sentiment d'avancer, même lorsqu'une tâche importante n'est pas encore terminée.

---

# 13. Interface utilisateur

La matrice d'Eisenhower reste la porte d'entrée.

La hiérarchie visuelle devra naturellement attirer le regard vers :

1. Urgent & Important
2. Important & Pas urgent
3. À déléguer
4. À abandonner

Les tâches terminées restent consultables.

Leur consultation participe au sentiment d'avancement.

L'interface devra privilégier :

* une lecture immédiate ;
* peu d'informations simultanées ;
* une hiérarchie visuelle forte ;
* des couleurs douces ;
* aucune surcharge.

---

# 14. Intégration avec Boussole

Cette fonctionnalité devra communiquer avec :

* Agenda personnel
* Agenda familial
* Notifications
* Historique
* Futur système de récompenses
* Futur système de réparation

La planification d'une tâche devra pouvoir créer automatiquement un événement dans l'agenda choisi.

---

# 15. Ce que cette fonctionnalité n'est pas

L'espace Organisation n'est pas :

* Todoist ;
* Notion ;
* Trello ;
* Microsoft To Do ;
* Google Tasks ;
* un agenda professionnel.

Il s'agit d'un assistant d'organisation familiale.

---

# 16. Vision long terme

À terme, cet espace deviendra le véritable tableau de bord personnel du parent.

Il regroupera progressivement :

* l'organisation personnelle ;
* les projets familiaux ;
* la liste de courses ;
* les rappels importants ;
* les futurs bilans.

Son objectif restera toujours identique :

**Réduire durablement la charge mentale des parents.**

---

# 17. Décisions produit validées

Les décisions suivantes sont considérées comme définitives :

✅ La matrice d'Eisenhower reste la porte d'entrée.

✅ Les dates de création ne sont jamais affichées.

✅ Les retards ne sont jamais affichés.

✅ Les relances ne sont jamais affichées.

✅ Les échéances restent disponibles mais servent uniquement à organiser.

✅ Les rappels utilisent toujours un langage bienveillant.

✅ Les tâches peuvent être découpées en sous-étapes.

✅ Les progrès sont valorisés avant la tâche terminée.

✅ Les tâches terminées restent consultables afin de renforcer le sentiment d'avancement.

✅ Chaque interaction avec cette fonctionnalité doit diminuer la charge mentale du parent.

✅ L'objectif n'est pas d'augmenter la productivité du parent mais de lui apporter de la clarté, de la sérénité et une meilleure organisation au quotidien.

---

# Conclusion

L'espace **Organisation Parent** n'a pas vocation à gérer davantage de tâches.

Il a vocation à aider les parents à prendre les bonnes décisions, au bon moment, tout en respectant leur fonctionnement, leur rythme et leur charge mentale.

Chaque évolution future de cette fonctionnalité devra respecter cette philosophie.

Si une évolution augmente la complexité, la culpabilité ou la pression ressentie, elle ne correspond pas à la vision de Boussole et devra être repensée.
