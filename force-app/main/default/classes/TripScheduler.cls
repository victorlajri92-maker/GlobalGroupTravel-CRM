public class TripScheduler implements Schedulable {
    
    // Cette méthode est appelée automatiquement par Salesforce
    // à l'heure programmée (chaque jour à 6h)
    public void execute(SchedulableContext sc) {
        
        // On lance le batch de mise à jour des statuts
        TripStatusBatch statusBatch = new TripStatusBatch();
        Database.executeBatch((Database.Batchable<sObject>) statusBatch, 200);
        
        // On lance le batch d'annulation automatique
        TripCancellationBatch cancellationBatch = new TripCancellationBatch();
        Database.executeBatch((Database.Batchable<sObject>) cancellationBatch, 200);
        
        System.debug('TripScheduler lancé avec succès');
    }
}