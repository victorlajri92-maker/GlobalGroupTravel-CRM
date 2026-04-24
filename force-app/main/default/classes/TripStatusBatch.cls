global class TripStatusBatch implements Database.Batchable<sObject> {
    
    // ETAPE 1 : start() - On récupère UNIQUEMENT les voyages
    // dont le statut est INCORRECT par rapport aux dates actuelles
    // On exclut les voyages dont le statut est déjà correct
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        Date today = Date.today();
        
        return Database.getQueryLocator([
            SELECT Id, Status__c, Start_Date__c, End_Date__c
            FROM Trip__c
            WHERE Status__c != 'Annulé'
            AND (
                // Cas 1 : statut "A venir" mais la date de début est déjà passée
                // → devrait être "En cours" ou "Terminé"
                (Status__c = 'A venir' AND Start_Date__c <= :today)
                OR
                // Cas 2 : statut "En cours" mais la date de fin est déjà passée
                // → devrait être "Terminé"
                (Status__c = 'En cours' AND End_Date__c < :today)
                OR
                // Cas 3 : statut "En cours" mais la date de début est dans le futur
                // → devrait être "A venir"
                (Status__c = 'En cours' AND Start_Date__c > :today)
                OR
                // Cas 4 : statut "Terminé" mais la date de fin n'est pas encore passée
                // → devrait être "A venir" ou "En cours"
                (Status__c = 'Terminé' AND End_Date__c >= :today)
            )
        ]);
    }
    
    // ETAPE 2 : execute() - On met à jour le statut selon les dates
    global void execute(Database.BatchableContext bc, List<Trip__c> trips) {
        
        Date today = Date.today();
        List<Trip__c> tripsToUpdate = new List<Trip__c>();
        
        for (Trip__c trip : trips) {
            
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