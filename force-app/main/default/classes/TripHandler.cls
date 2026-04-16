public class TripHandler {
    
    // Cette méthode est appelée par le trigger OpportunityTrigger
    // Elle reçoit la liste des opportunités qui viennent d'être mises à jour
    public static void createTripFromOpportunity(List<Opportunity> newOpportunities) {
        
        // On crée une liste vide qui va stocker les voyages à créer
        List<Trip__c> tripsToCreate = new List<Trip__c>();
        
        // On parcourt chaque opportunité mise à jour
        for (Opportunity opp : newOpportunities) {
            
            // On vérifie que l'opportunité est bien "Closed Won"
            if (opp.StageName == 'Closed Won') {
                
                // On vérifie que les dates sont cohérentes AVANT de créer le Trip__c
                // Si End Date <= Start Date, on bloque directement sur l'Opportunity
                // avec un message d'erreur court et clair pour l'utilisateur
                if (opp.Start_Date__c != null && opp.End_Date__c != null
                    && opp.End_Date__c <= opp.Start_Date__c) {
                    
                    // addError() affiche le message directement sur l'Opportunity
                    // et bloque la sauvegarde sans message technique
                    opp.addError('La date de fin doit être postérieure à la date de début.');
                    
                    // On arrête tout de suite, pas besoin de continuer
                    return;
                }
                
                // On crée un nouveau voyage avec les infos de l'opportunité
                Trip__c newTrip = new Trip__c(
                    Name = 'Voyage - ' + opp.Name,
                    Status__c = 'A venir',
                    Destination__c = opp.Destination__c,
                    Start_Date__c = opp.Start_Date__c,
                    End_Date__c = opp.End_Date__c,
                    Number_of_Participants__c = opp.Number_of_Participants__c,
                    Total_Cost__c = opp.Amount,
                    Account__c = opp.AccountId,
                    Opportunity__c = opp.Id
                );
                
                // On ajoute ce voyage à notre liste
                tripsToCreate.add(newTrip);
            }
        }
        
        // Si notre liste n'est pas vide, on insère tous les voyages en une seule fois
        // C'est la bonne pratique Salesforce : jamais de DML dans une boucle !
        if (!tripsToCreate.isEmpty()) {
            insert tripsToCreate;
        }
    }
}