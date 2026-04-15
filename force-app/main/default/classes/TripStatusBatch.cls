global class TripStatusBatch implements Database.Batchable<sObject> {
    
    // Chaque matin, Salesforce vérifie tous les voyages et met à jour leur statut automatiquement
    // ETAPE 1 : start() - On récupère TOUS les voyages
    // qui ne sont pas annulés car on doit vérifier leur statut
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        return Database.getQueryLocator([
            SELECT Id, Status__c, Start_Date__c, End_Date__c
            FROM Trip__c
            WHERE Status__c != 'Annulé'
        ]);
    }
    
    // ETAPE 2 : execute() - On vérifie les dates et on met à jour le statut
    global void execute(Database.BatchableContext bc, List<Trip__c> trips) {
        
        // On récupère la date d'aujourd'hui
        Date today = Date.today();
        
        // On crée une liste vide pour stocker les voyages à mettre à jour
        List<Trip__c> tripsToUpdate = new List<Trip__c>();
        
        // On parcourt chaque voyage
        for (Trip__c trip : trips) {
            
            // On stocke l'ancien statut pour comparer après
            String oldStatus = trip.Status__c;
            
            // RÈGLE 1 : Si aujourd'hui est avant la date de début → "A venir"
            if (today < trip.Start_Date__c) {
                trip.Status__c = 'A venir';
            }
            
            // RÈGLE 2 : Si aujourd'hui est entre début et fin → "En cours"
            else if (today >= trip.Start_Date__c && today <= trip.End_Date__c) {
                trip.Status__c = 'En cours';
            }
            
            // RÈGLE 3 : Si aujourd'hui est après la date de fin → "Terminé"
            else if (today > trip.End_Date__c) {
                trip.Status__c = 'Terminé';
            }
            
            // On ajoute le voyage à la liste seulement si le statut a changé
            if (trip.Status__c != oldStatus) {
                tripsToUpdate.add(trip);
            }
        }
        
        // On met à jour tous les voyages en une seule opération
        if (!tripsToUpdate.isEmpty()) {
            update tripsToUpdate;
        }
    }
    
    // ETAPE 3 : finish() - On log la fin du batch
    global void finish(Database.BatchableContext bc) {
        System.debug('TripStatusBatch terminé avec succès');
    }
}