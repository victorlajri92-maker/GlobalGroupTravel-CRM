public class TripCancellationBatch implements Database.Batchable<sObject> {
    
    // ETAPE 1 : start() - Salesforce appelle cette méthode en premier
    // Elle définit QUELS enregistrements on veut traiter
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        // On calcule la date dans 7 jours
        Date sevenDaysFromNow = Date.today().addDays(7);
        
        // On récupère tous les voyages qui :
        // - commencent dans exactement 7 jours
        // - ont moins de 10 participants
        // - ne sont pas déjà annulés
        return Database.getQueryLocator([
            SELECT Id, Status__c, Number_of_Participants__c, Start_Date__c
            FROM Trip__c
            WHERE Start_Date__c = :sevenDaysFromNow
            AND Number_of_Participants__c < 10
            AND Number_of_Participants__c != null
            AND Status__c != 'Annulé'
        ]);
    }
    
    // ETAPE 2 : execute() - Salesforce appelle cette méthode pour chaque lot
    // Elle définit QUOI faire avec les enregistrements récupérés
    public void execute(Database.BatchableContext bc, List<Trip__c> trips) {
        
        // On crée une liste vide pour stocker les voyages à mettre à jour
        List<Trip__c> tripsToUpdate = new List<Trip__c>();
        
        // On parcourt chaque voyage
        for (Trip__c trip : trips) {
            
            // On change le statut à "Annulé"
            trip.Status__c = 'Annulé';
            
            // On ajoute le voyage à notre liste
            tripsToUpdate.add(trip);
        }
        
        // On met à jour tous les voyages en une seule opération
        if (!tripsToUpdate.isEmpty()) {
            update tripsToUpdate;
        }
    }
    
    // ETAPE 3 : finish() - Salesforce appelle cette méthode à la fin
    // On peut l'utiliser pour envoyer un email ou logger des infos
    public void finish(Database.BatchableContext bc) {
        System.debug('TripCancellationBatch terminé avec succès');
    }
}